"""
=============================================================================
    PROJET 10 : FINE-TUNING BERT POUR NER (VERSION SIMPLIFIÉE)

    Objectif : Entraîner DistilBERT à extraire automatiquement
    les infos clés des descriptions de travaux de construction

    Input : "Remplacement toiture 150m² ardoise, désamiantage, 25000€"
    Output: TYPE_TRAVAIL=Toiture, SURFACE=150m², MATERIAU=Ardoise, etc.
=============================================================================
"""

import json
import torch
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from tqdm import tqdm
import warnings
warnings.filterwarnings('ignore')

from transformers import (
    DistilBertTokenizer,
    DistilBertForTokenClassification,
    AdamW,
    get_linear_schedule_with_warmup
)
from torch.utils.data import DataLoader, Dataset
from sklearn.metrics import accuracy_score, f1_score, classification_report, confusion_matrix
import seaborn as sns

print("\n" + "="*80)
print("PROJET 10 : FINE-TUNING BERT POUR NER - EXTRACTION D'ENTITÉS BTP")
print("="*80)

# ============================================================================
# ÉTAPE 0 : CONFIGURATION
# ============================================================================

print("\n⚙️ CONFIGURATION")

DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print(f"Device : {DEVICE}")

CONFIG = {
    'model_name': 'distilbert-base-uncased',
    'max_length': 128,
    'batch_size': 16,
    'epochs': 5,
    'learning_rate': 2e-5,
    'warmup_steps': 500,
    'weight_decay': 0.01,
}

print(f"Hyperparamètres : {CONFIG}")

# ============================================================================
# ÉTAPE 1 : CHARGER LE DATASET
# ============================================================================

print("\n" + "="*80)
print("ÉTAPE 1 : CHARGER LE DATASET NER")
print("="*80)

with open('/Users/manelarras/entrainement machine learning/data/ner_dataset.json', 'r', encoding='utf-8') as f:
    dataset_raw = json.load(f)

dataset = dataset_raw['dataset']
print(f"\n✓ Dataset chargé : {len(dataset)} exemples")
print(f"  Entités : {', '.join(dataset_raw['metadata']['entity_types'])}")

# Créer les mappings label ↔ id
ENTITY_TYPES = dataset_raw['metadata']['entity_types']

label2id = {'O': 0}
id2label = {0: 'O'}

label_id = 1
for entity in ENTITY_TYPES:
    label2id[f'B-{entity}'] = label_id
    id2label[label_id] = f'B-{entity}'
    label_id += 1

print(f"\n✓ Label mappings créés : {len(label2id)} labels possibles")

# ============================================================================
# ÉTAPE 2 : PRÉPARER LES TOKENS ET LABELS (VERSION SIMPLIFIÉE)
# ============================================================================

print("\n" + "="*80)
print("ÉTAPE 2 : PRÉPARER LES TOKENS ET LABELS")
print("="*80)

tokenizer = DistilBertTokenizer.from_pretrained(CONFIG['model_name'])
print(f"\n✓ Tokenizer chargé : {CONFIG['model_name']}")

# VERSION SIMPLIFIÉE : Marquer simplement les débuts d'entités
prepared_data = []

print("\n⏳ Préparation des données...")

for idx, example in enumerate(tqdm(dataset)):
    text = example['text']
    entities = example['entities']

    # Tokenize SANS offset_mapping
    encoding = tokenizer(
        text,
        max_length=CONFIG['max_length'],
        padding='max_length',
        truncation=True,
        return_tensors='pt',
    )

    # Créer les labels
    labels = torch.full((1, CONFIG['max_length']), -100, dtype=torch.long)

    # Marquer les tokens de manière simple :
    # On regarde les tokens et on assigne les labels basiquement
    tokens = tokenizer.convert_ids_to_tokens(encoding['input_ids'][0])

    # Initialiser tous les tokens comme "Outside" (O)
    current_labels = [label2id['O']] * len(tokens)

    # Marquer les tokens qui correspondent aux entités
    for entity_type, entity_value in entities.items():
        # Tokenize l'entité seule
        entity_tokens = tokenizer.tokenize(entity_value.lower())

        # Chercher la séquence dans les tokens
        for i in range(len(tokens) - len(entity_tokens) + 1):
            match = True
            for j, entity_token in enumerate(entity_tokens):
                token_match = tokens[i + j].lower().replace('##', '')
                entity_token_match = entity_token.lower().replace('##', '')

                if token_match != entity_token_match:
                    match = False
                    break

            if match:
                # Marquer comme l'entité
                current_labels[i] = label2id.get(f'B-{entity_type}', label2id['O'])
                break

    # Ignorer [CLS] et [SEP]
    current_labels[0] = -100
    for i in range(len(current_labels) - 1, -1, -1):
        if tokens[i] == '[SEP]':
            current_labels[i] = -100
            break

    # Ignorer les tokens de padding
    for i in range(len(current_labels)):
        if tokens[i] == '[PAD]':
            current_labels[i] = -100

    labels = torch.tensor([current_labels], dtype=torch.long)

    prepared_data.append({
        'input_ids': encoding['input_ids'],
        'attention_mask': encoding['attention_mask'],
        'labels': labels,
        'text': text
    })

print(f"\n✓ Données préparées : {len(prepared_data)} exemples")

# ============================================================================
# ÉTAPE 3 : CRÉER LES DATALOADERS
# ============================================================================

print("\n" + "="*80)
print("ÉTAPE 3 : CRÉER LES DATALOADERS")
print("="*80)

# Splitter train/val/test
train_size = int(0.7 * len(prepared_data))
val_size = int(0.15 * len(prepared_data))
test_size = len(prepared_data) - train_size - val_size

train_data = prepared_data[:train_size]
val_data = prepared_data[train_size:train_size + val_size]
test_data = prepared_data[train_size + val_size:]

class NERDataset(Dataset):
    def __init__(self, data):
        self.data = data

    def __len__(self):
        return len(self.data)

    def __getitem__(self, idx):
        item = self.data[idx]
        return {
            'input_ids': item['input_ids'].squeeze(),
            'attention_mask': item['attention_mask'].squeeze(),
            'labels': item['labels'].squeeze()
        }

train_dataset = NERDataset(train_data)
val_dataset = NERDataset(val_data)
test_dataset = NERDataset(test_data)

train_loader = DataLoader(train_dataset, batch_size=CONFIG['batch_size'], shuffle=True)
val_loader = DataLoader(val_dataset, batch_size=CONFIG['batch_size'], shuffle=False)
test_loader = DataLoader(test_dataset, batch_size=CONFIG['batch_size'], shuffle=False)

print(f"\n✓ DataLoaders créés :")
print(f"  Train : {len(train_data)} exemples ({len(train_loader)} batches)")
print(f"  Val   : {len(val_data)} exemples ({len(val_loader)} batches)")
print(f"  Test  : {len(test_data)} exemples ({len(test_loader)} batches)")

# ============================================================================
# ÉTAPE 4 : CHARGER LE MODÈLE PRÉ-ENTRAÎNÉ
# ============================================================================

print("\n" + "="*80)
print("ÉTAPE 4 : CHARGER LE MODÈLE DISTILBERT")
print("="*80)

model = DistilBertForTokenClassification.from_pretrained(
    CONFIG['model_name'],
    num_labels=len(label2id),
)
model.to(DEVICE)

print(f"\n✓ Modèle chargé : DistilBERT")
print(f"  Nombre de labels : {len(label2id)}")

# Compter les paramètres
total_params = sum(p.numel() for p in model.parameters())
trainable_params = sum(p.numel() for p in model.parameters() if p.requires_grad)
print(f"  Paramètres totaux : {total_params:,}")
print(f"  Paramètres traînables : {trainable_params:,}")

# ============================================================================
# ÉTAPE 5 : CONFIGURATION DE L'OPTIMISEUR
# ============================================================================

print("\n" + "="*80)
print("ÉTAPE 5 : CONFIGURATION DE L'OPTIMISEUR")
print("="*80)

optimizer = AdamW(model.parameters(), lr=CONFIG['learning_rate'], weight_decay=CONFIG['weight_decay'])

total_steps = len(train_loader) * CONFIG['epochs']
scheduler = get_linear_schedule_with_warmup(
    optimizer,
    num_warmup_steps=CONFIG['warmup_steps'],
    num_training_steps=total_steps
)

print(f"\n✓ Optimiseur : AdamW")
print(f"  Learning rate : {CONFIG['learning_rate']}")
print(f"  Total steps : {total_steps}")

# ============================================================================
# ÉTAPE 6 : FONCTION DE TRAINING
# ============================================================================

def train_epoch(model, train_loader, optimizer, scheduler, device):
    """Entraîner une epoch"""
    model.train()
    total_loss = 0
    num_batches = 0

    for batch in tqdm(train_loader, desc="Training"):
        optimizer.zero_grad()

        input_ids = batch['input_ids'].to(device)
        attention_mask = batch['attention_mask'].to(device)
        labels = batch['labels'].to(device)

        outputs = model(
            input_ids=input_ids,
            attention_mask=attention_mask,
            labels=labels
        )

        loss = outputs.loss
        loss.backward()

        torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)

        optimizer.step()
        scheduler.step()

        total_loss += loss.item()
        num_batches += 1

    return total_loss / num_batches

# ============================================================================
# ÉTAPE 7 : FONCTION D'ÉVALUATION
# ============================================================================

def evaluate(model, eval_loader, device):
    """Évaluer le modèle"""
    model.eval()
    all_preds = []
    all_labels = []

    with torch.no_grad():
        for batch in tqdm(eval_loader, desc="Evaluating"):
            input_ids = batch['input_ids'].to(device)
            attention_mask = batch['attention_mask'].to(device)
            labels = batch['labels'].to(device)

            outputs = model(
                input_ids=input_ids,
                attention_mask=attention_mask,
            )

            logits = outputs.logits
            predictions = torch.argmax(logits, dim=2)

            all_preds.append(predictions.cpu().numpy())
            all_labels.append(labels.cpu().numpy())

    # Flatten et calculer metrics
    all_preds = np.concatenate(all_preds).flatten()
    all_labels = np.concatenate(all_labels).flatten()

    # Ignorer les labels -100 (padding)
    mask = all_labels != -100
    all_preds = all_preds[mask]
    all_labels = all_labels[mask]

    accuracy = accuracy_score(all_labels, all_preds)
    f1 = f1_score(all_labels, all_preds, average='weighted', zero_division=0)

    return accuracy, f1, all_labels, all_preds

# ============================================================================
# ÉTAPE 8 : FINE-TUNING
# ============================================================================

print("\n" + "="*80)
print("ÉTAPE 8 : FINE-TUNING DISTILBERT")
print("="*80)

print(f"\n🚀 Entraînement en cours... ({CONFIG['epochs']} epochs)\n")

train_losses = []
val_accuracies = []
val_f1s = []

for epoch in range(CONFIG['epochs']):
    print(f"\n{'='*80}")
    print(f"EPOCH {epoch + 1}/{CONFIG['epochs']}")
    print(f"{'='*80}")

    # Training
    train_loss = train_epoch(model, train_loader, optimizer, scheduler, DEVICE)
    train_losses.append(train_loss)
    print(f"\n✓ Train Loss : {train_loss:.4f}")

    # Validation
    val_accuracy, val_f1, _, _ = evaluate(model, val_loader, DEVICE)
    val_accuracies.append(val_accuracy)
    val_f1s.append(val_f1)
    print(f"✓ Val Accuracy : {val_accuracy:.4f}")
    print(f"✓ Val F1-Score : {val_f1:.4f}")

# ============================================================================
# ÉTAPE 9 : ÉVALUATION FINALE
# ============================================================================

print("\n" + "="*80)
print("ÉTAPE 9 : ÉVALUATION FINALE")
print("="*80)

test_accuracy, test_f1, test_labels, test_preds = evaluate(model, test_loader, DEVICE)

print(f"\n📊 RÉSULTATS FINAUX (Test Set) :")
print(f"  Accuracy : {test_accuracy:.4f} ({test_accuracy*100:.2f}%)")
print(f"  F1-Score : {test_f1:.4f}")

# ============================================================================
# ÉTAPE 10 : SAUVEGARDER LE MODÈLE
# ============================================================================

print("\n" + "="*80)
print("ÉTAPE 10 : SAUVEGARDER LE MODÈLE")
print("="*80)

model_path = '/Users/manelarras/entrainement machine learning/models/distilbert_btp_ner'
model.save_pretrained(model_path)
tokenizer.save_pretrained(model_path)

# Sauvegarder les mappings
with open(f'{model_path}/label_mappings.json', 'w') as f:
    json.dump({'label2id': label2id, 'id2label': {str(k): v for k, v in id2label.items()}}, f)

print(f"\n✓ Modèle sauvegardé : {model_path}")

# ============================================================================
# ÉTAPE 11 : TESTER EN PRODUCTION
# ============================================================================

print("\n" + "="*80)
print("ÉTAPE 11 : TESTER EN PRODUCTION")
print("="*80)

test_examples = [
    "Remplacement toiture 150m² ardoise, désamiantage, budget 25000€",
    "Électricité 4 pièces, mise aux normes, équipe de 3 personnes",
    "Maçonnerie extension 80m² béton, 35 jours",
    "Peinture intérieure 200m², 15 jours, budget 8000€",
    "Charpente bois, isolation thermique, 60 jours",
]

print("\n🔍 PRÉDICTIONS SUR EXEMPLES :\n")

model.eval()
for example in test_examples:
    print(f"Input : {example}")

    # Tokenize
    encoding = tokenizer(
        example,
        max_length=CONFIG['max_length'],
        padding='max_length',
        truncation=True,
        return_tensors='pt',
    )

    input_ids = encoding['input_ids'].to(DEVICE)
    attention_mask = encoding['attention_mask'].to(DEVICE)

    # Prédire
    with torch.no_grad():
        outputs = model(input_ids=input_ids, attention_mask=attention_mask)
        logits = outputs.logits
        predictions = torch.argmax(logits, dim=2)[0]

    # Décoder
    tokens = tokenizer.convert_ids_to_tokens(input_ids[0])
    pred_labels = [id2label.get(int(p), 'O') for p in predictions]

    # Extraire les entités
    entities_found = {}
    for token, label in zip(tokens, pred_labels):
        if token in ['[CLS]', '[SEP]', '[PAD]'] or label == 'O':
            continue

        entity_type = label.split('-')[1] if '-' in label else 'Unknown'
        if entity_type not in entities_found:
            entities_found[entity_type] = []

        clean_token = token.replace('##', '')
        entities_found[entity_type].append(clean_token)

    print(f"Entités trouvées :")
    if entities_found:
        for entity_type, values in entities_found.items():
            value_str = ''.join(values).replace('[PAD]', '').strip()
            if value_str:
                print(f"  • {entity_type} : {value_str}")
    else:
        print(f"  (Aucune entité détectée)")
    print()

# ============================================================================
# ÉTAPE 12 : GÉNÉRER LES GRAPHIQUES
# ============================================================================

print("\n" + "="*80)
print("ÉTAPE 12 : GÉNÉRER LES GRAPHIQUES")
print("="*80)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('BERT NER Fine-Tuning Results - Extraction d\'entités BTP', fontsize=16, fontweight='bold')

# 1. Training Loss
ax = axes[0, 0]
ax.plot(range(1, len(train_losses) + 1), train_losses, 'b-o', linewidth=2, markersize=8)
ax.set_xlabel('Epoch')
ax.set_ylabel('Loss')
ax.set_title('Training Loss')
ax.grid(True, alpha=0.3)

# 2. Validation Accuracy
ax = axes[0, 1]
ax.plot(range(1, len(val_accuracies) + 1), val_accuracies, 'g-o', linewidth=2, markersize=8)
ax.set_xlabel('Epoch')
ax.set_ylabel('Accuracy')
ax.set_title('Validation Accuracy')
ax.set_ylim([0, 1])
ax.grid(True, alpha=0.3)

# 3. Validation F1-Score
ax = axes[1, 0]
ax.plot(range(1, len(val_f1s) + 1), val_f1s, 'orange', marker='o', linewidth=2, markersize=8)
ax.set_xlabel('Epoch')
ax.set_ylabel('F1-Score')
ax.set_title('Validation F1-Score')
ax.set_ylim([0, 1])
ax.grid(True, alpha=0.3)

# 4. Confusion Matrix
ax = axes[1, 1]
cm = confusion_matrix(test_labels, test_preds)
if cm.shape[0] > 1:
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', ax=ax, cbar_kws={'label': 'Count'})
    ax.set_title('Confusion Matrix (Test Set)')
    ax.set_xlabel('Predicted Label')
    ax.set_ylabel('True Label')

plt.tight_layout()
plt.savefig('/Users/manelarras/entrainement machine learning/09_BERT_NER_Results.png', dpi=300, bbox_inches='tight')
print("\n✓ Graphique sauvegardé : 09_BERT_NER_Results.png")
plt.close()

# ============================================================================
# RÉSUMÉ FINAL
# ============================================================================

print("\n" + "="*80)
print("🎉 FINE-TUNING TERMINÉ !")
print("="*80)

print(f"""
📊 RÉSUMÉ FINAL :

1. DATASET
   ✓ Total exemples : 500
   ✓ Train : {len(train_data)} ({len(train_data)/500*100:.0f}%)
   ✓ Val   : {len(val_data)} ({len(val_data)/500*100:.0f}%)
   ✓ Test  : {len(test_data)} ({len(test_data)/500*100:.0f}%)

2. MODÈLE
   ✓ Architecture : DistilBERT
   ✓ Paramètres : {trainable_params:,}
   ✓ Labels : {len(label2id)}

3. ENTRAÎNEMENT
   ✓ Epochs : {CONFIG['epochs']}
   ✓ Learning rate : {CONFIG['learning_rate']}
   ✓ Batch size : {CONFIG['batch_size']}
   ✓ Loss finale : {train_losses[-1]:.4f}

4. RÉSULTATS FINAUX (Test Set)
   ✓ Accuracy : {test_accuracy*100:.2f}%
   ✓ F1-Score : {test_f1:.4f}

5. FICHIERS CRÉÉS
   ✓ Modèle sauvegardé : {model_path}
   ✓ Graphiques : 09_BERT_NER_Results.png

6. PROCHAINES ÉTAPES
   ✓ Utiliser le modèle pour extraire les entités en production
   ✓ Ajouter plus de données si besoin
   ✓ Affiner les hyperparamètres
   ✓ Intégrer à ton app BTP
""")

print("\n✅ Le modèle est prêt à être utilisé !")
print("="*80 + "\n")
