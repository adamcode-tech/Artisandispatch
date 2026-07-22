# Dockerfile pour fine-tuning BERT sur Railway
FROM python:3.10-slim

# Définir le répertoire de travail
WORKDIR /app

# Copier les requirements
COPY requirements_railway.txt .

# Installer les dépendances
RUN pip install --no-cache-dir -r requirements_railway.txt

# Copier les fichiers du projet
COPY data/ ./data/
COPY 09_BERT_BTP_NER_FineTuning_FIXED.py .
COPY create_btp_ner_dataset.py .

# Créer le répertoire models
RUN mkdir -p models

# Lancer le script d'entraînement
CMD ["python", "09_BERT_BTP_NER_FineTuning_FIXED.py"]
