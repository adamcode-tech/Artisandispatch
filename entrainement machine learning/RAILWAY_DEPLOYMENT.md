# 🚀 DÉPLOIEMENT SUR RAILWAY

Guide pour exécuter le fine-tuning BERT sur Railway au lieu de ton Mac local.

---

## 📋 Prérequis

1. **Compte Railway** : https://railway.app/
2. **Git** installé localement
3. **Railway CLI** (optionnel mais recommandé)

---

## 🔧 SETUP RAILWAY

### Étape 1 : Préparer le projet Git

```bash
cd "/Users/manelarras/entrainement machine learning"

# Initialiser git si pas déjà fait
git init
git add .
git commit -m "Add BERT NER fine-tuning project for Railway deployment"
```

### Étape 2 : Connecter à Railway

**Option A : Via l'interface web (Plus facile)**

1. Va à https://railway.app/
2. Clique "Deploy from GitHub"
3. Connecte ton compte GitHub
4. Sélectionne le repo du projet
5. Railway détecte automatiquement le Dockerfile
6. Clique "Deploy"

**Option B : Via Railway CLI**

```bash
# Installer Railway CLI
npm install -g @railway/cli

# Login
railway login

# Créer un nouveau projet
railway init

# Deploy
railway up
```

---

## 📊 Configuration Railway

### Variables d'environnement (optionnel)

Railway → Project Settings → Environment Variables

```
PYTHONUNBUFFERED=1
```

### Ressources recommandées

- **Plan** : Free ou Pro (dépend de tes besoins)
- **RAM** : Minimum 2GB (idéal 4GB+)
- **CPU** : Standard suffit
- **Disk** : 10GB+ (pour les models)

---

## ⏱️ Temps d'exécution

```
Préparation          : ~30 secondes
Téléchargement deps  : ~2 minutes
Téléchargement BERT  : ~3 minutes
Fine-tuning (5 epochs): ~15-20 minutes
Sauvegarde + Graphiques: ~2 minutes
───────────────────────────────────
TOTAL                : ~25-30 minutes
```

---

## 🔍 Monitoring l'exécution

### Via Railway Dashboard

1. Va à ton projet Railway
2. Clique "Logs"
3. Vois les logs en temps réel

### Via Railway CLI

```bash
railway logs -f
```

---

## 📥 Récupérer les résultats

Une fois l'entraînement terminé, le modèle et les graphiques sont sauvegardés dans :

```
/app/models/distilbert_btp_ner/
/app/09_BERT_NER_Results.png
```

### Récupérer les fichiers

**Option 1 : Via Railway Dashboard**
- Clique "Connect"
- SSH dans le container
- Récupère les fichiers

**Option 2 : Via Git (si tu commits les résultats)**
- Ajoute les résultats à git
- Push vers ton repo
- Récupère depuis le repo

---

## 🐛 Troubleshooting

### ❌ Erreur : "No space left on device"

**Solution** :
- Railway a limité le disk (Free plan = 10GB)
- Utilise le plan Pro ou supprime les old builds

### ❌ Erreur : "ModuleNotFoundError"

**Solution** :
- Vérifier que requirements_railway.txt est complet
- Relancer le deploy

### ❌ Erreur : "OOM (Out Of Memory)"

**Solution** :
- Réduire batch_size dans le script (de 16 à 8)
- Utiliser Railway Pro (plus de RAM)

---

## ⚡ Script optimisé pour Railway

Le fichier `09_BERT_BTP_NER_FineTuning_FIXED.py` est déjà optimisé pour :
- ✅ Utiliser CPU efficacement
- ✅ Sauvegarder les résultats
- ✅ Générer les graphiques
- ✅ Pas de problème de mémoire

---

## 🎯 Prochaines étapes après l'entraînement

### 1. Sauvegarder le modèle
```bash
# Le modèle est dans : /app/models/distilbert_btp_ner/
# Railway peut le stocker ou tu peux le télécharger
```

### 2. Utiliser le modèle en production
```python
from transformers import pipeline

# Charger depuis Railway
model_path = "/app/models/distilbert_btp_ner"
nlp = pipeline("token-classification", model=model_path)

# Prédire
result = nlp("Remplacement toiture 150m² ardoise")
print(result)
```

### 3. Créer une API avec le modèle
```python
# Voir : 10_BERT_BTP_API.py (à créer si besoin)
from fastapi import FastAPI
from transformers import pipeline

app = FastAPI()
nlp = pipeline("token-classification", model="./models/distilbert_btp_ner")

@app.post("/extract")
def extract_entities(text: str):
    return nlp(text)
```

---

## 📞 Support Railway

- **Docs** : https://docs.railway.app/
- **Discord** : https://discord.gg/railway
- **Status** : https://status.railway.app/

---

## ✅ Checklist avant de déployer

- [ ] Git repository créé
- [ ] Dockerfile prêt
- [ ] requirements_railway.txt complet
- [ ] Compte Railway créé
- [ ] Données (data/) incluses
- [ ] Scripts Python prêts

---

## 🎉 C'est parti !

Une fois déployé sur Railway :
- ✅ Le script tournera sans intervention
- ✅ Tu peux éteindre ton ordi
- ✅ Le training se fera sur les serveurs Railway
- ✅ Les résultats seront accessibles après
- ✅ Zero down-time si ton Mac crash

**Avantages** :
- 🚀 Pas besoin de garder l'ordi allumé
- ⚡ Plus rapide qu'en local
- 📊 Logs en temps réel
- 💾 Sauvegarde automatique
