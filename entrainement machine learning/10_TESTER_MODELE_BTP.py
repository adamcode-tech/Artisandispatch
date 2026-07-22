"""
=============================================================================
    TESTER LE MODÈLE BERT NER FINE-TUNÉ (BTP)

    Charge le modèle entraîné depuis models/ et extrait les entités
    de n'importe quelle description de travaux.

    Usage :
        python 10_TESTER_MODELE_BTP.py
        (puis tape tes propres phrases, ou 'q' pour quitter)
=============================================================================
"""

import json
import torch
from transformers import DistilBertTokenizer, DistilBertForTokenClassification

print("\n" + "="*70)
print("🏗️  TESTEUR DU MODÈLE BERT NER - EXTRACTION D'ENTITÉS BTP")
print("="*70)

# ---------------------------------------------------------------------------
# 1. Charger le modèle, le tokenizer et les mappings
# ---------------------------------------------------------------------------
MODEL_PATH = "/Users/manelarras/entrainement machine learning/models"
MAX_LENGTH = 128

print("\n⏳ Chargement du modèle...")

tokenizer = DistilBertTokenizer.from_pretrained(MODEL_PATH)
model = DistilBertForTokenClassification.from_pretrained(MODEL_PATH)
model.eval()  # mode évaluation (pas d'entraînement)

# Charger les vrais noms d'entités (le config.json a des noms génériques)
with open(f"{MODEL_PATH}/label_mappings.json", "r", encoding="utf-8") as f:
    mappings = json.load(f)
id2label = {int(k): v for k, v in mappings["id2label"].items()}

print("✓ Modèle chargé !")
print(f"✓ Entités reconnues : {[v for v in id2label.values() if v != 'O']}")


# ---------------------------------------------------------------------------
# 2. Fonction d'extraction des entités
# ---------------------------------------------------------------------------
def extraire_entites(texte):
    """Prend une phrase, retourne les entités BTP trouvées."""

    # Tokenizer le texte
    enc = tokenizer(
        texte,
        max_length=MAX_LENGTH,
        padding="max_length",
        truncation=True,
        return_tensors="pt",
    )

    # Prédiction (pas de calcul de gradient = plus rapide)
    with torch.no_grad():
        outputs = model(input_ids=enc["input_ids"], attention_mask=enc["attention_mask"])
        predictions = torch.argmax(outputs.logits, dim=2)[0]

    # Décoder : associer chaque token à son label prédit
    tokens = tokenizer.convert_ids_to_tokens(enc["input_ids"][0])
    pred_ids = [int(p) for p in predictions]

    entites = {}
    i = 0
    while i < len(tokens):
        token = tokens[i]
        label = id2label.get(pred_ids[i], "O")

        # Ignorer les tokens spéciaux et les "O" (rien)
        if token in ["[CLS]", "[SEP]", "[PAD]"] or label == "O":
            i += 1
            continue

        # Le label est du type "B-TYPE_TRAVAIL" -> on garde "TYPE_TRAVAIL"
        type_entite = label.split("-")[1]

        # Recoller le mot complet : on part du token B- et on ajoute
        # tous les sous-morceaux qui suivent (ceux qui commencent par ##)
        mot = token.replace("##", "")
        j = i + 1
        while j < len(tokens) and tokens[j].startswith("##"):
            mot += tokens[j].replace("##", "")
            j += 1

        entites.setdefault(type_entite, []).append(mot)
        i = j  # on saute les morceaux déjà recollés

    return entites


# ---------------------------------------------------------------------------
# 3. Tester sur des exemples pré-définis
# ---------------------------------------------------------------------------
exemples = [
    "Remplacement toiture 150m² ardoise, désamiantage, budget 25000€",
    "Électricité 4 pièces, mise aux normes, équipe de 3 personnes",
    "Maçonnerie extension 80m² béton, 35 jours",
    "Peinture intérieure 200m², budget 8000€",
    "Charpente bois, isolation thermique, 60 jours",
]

print("\n" + "="*70)
print("📋 TEST SUR DES EXEMPLES")
print("="*70)

for exemple in exemples:
    print(f"\n📝 « {exemple} »")
    entites = extraire_entites(exemple)
    if entites:
        for type_entite, mots in entites.items():
            print(f"   • {type_entite:20} → {' '.join(mots)}")
    else:
        print("   (aucune entité détectée)")


# ---------------------------------------------------------------------------
# 4. Mode interactif : teste tes propres phrases
# ---------------------------------------------------------------------------
print("\n" + "="*70)
print("✍️  MODE INTERACTIF")
print("="*70)
print("Tape une description de travaux (ou 'q' pour quitter) :\n")

while True:
    try:
        phrase = input("👉 ")
    except (EOFError, KeyboardInterrupt):
        break

    if phrase.strip().lower() in ["q", "quit", "quitter", "exit"]:
        break
    if not phrase.strip():
        continue

    entites = extraire_entites(phrase)
    if entites:
        for type_entite, mots in entites.items():
            print(f"   • {type_entite:20} → {' '.join(mots)}")
    else:
        print("   (aucune entité détectée)")
    print()

print("\n👋 Au revoir !")
