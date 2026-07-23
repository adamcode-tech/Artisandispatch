"""
=============================================================================
    PROJET 14 : SUIVI D'EXPÉRIENCES AVEC MLflow

    On entraîne PLUSIEURS versions d'un modèle qui prédit la durée
    d'un chantier (en jours), avec des hyperparamètres différents.
    MLflow trace TOUT automatiquement : params, métriques, modèle.

    Ensuite : `mlflow ui` → un tableau comparatif de tous les runs.
=============================================================================
"""

import numpy as np
import pandas as pd
import mlflow
import mlflow.sklearn
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score

print("\n" + "="*70)
print("PROJET 14 : SUIVI D'EXPÉRIENCES AVEC MLflow")
print("="*70)

# ---------------------------------------------------------------------------
# 1. Créer un dataset synthétique : prédire la durée d'un chantier
# ---------------------------------------------------------------------------
print("\n📊 Génération d'un dataset BTP (durée de chantier)...")

np.random.seed(42)
n = 800

surface = np.random.randint(20, 500, n)          # m²
nb_ouvriers = np.random.randint(1, 8, n)         # nombre d'ouvriers
type_travail = np.random.randint(0, 5, n)        # 0=peinture ... 4=maçonnerie
complexite = np.random.randint(1, 4, n)          # 1=simple, 3=complexe

# La "vraie" durée dépend de ces facteurs (+ un peu de bruit)
duree = (
    surface * 0.15
    + type_travail * 8
    + complexite * 10
    - nb_ouvriers * 4
    + np.random.normal(0, 5, n)
)
duree = np.clip(duree, 1, None)  # au moins 1 jour

X = pd.DataFrame({
    "surface": surface,
    "nb_ouvriers": nb_ouvriers,
    "type_travail": type_travail,
    "complexite": complexite,
})
y = duree

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
print(f"✓ {n} chantiers générés ({len(X_train)} train / {len(X_test)} test)")

# ---------------------------------------------------------------------------
# 2. Définir l'experiment MLflow
# ---------------------------------------------------------------------------
# RÈGLE D'OR : on fixe explicitement OÙ MLflow écrit (la même base que l'UI lira)
mlflow.set_tracking_uri("sqlite:///mlflow.db")
mlflow.set_experiment("prediction-duree-chantier")
print("\n✓ Experiment MLflow : 'prediction-duree-chantier'")

# ---------------------------------------------------------------------------
# 3. Les 6 versions à tester (hyperparamètres différents)
# ---------------------------------------------------------------------------
configurations = [
    {"n_estimators": 10,  "max_depth": 3},
    {"n_estimators": 50,  "max_depth": 5},
    {"n_estimators": 100, "max_depth": 10},
    {"n_estimators": 200, "max_depth": 15},
    {"n_estimators": 300, "max_depth": 20},
    {"n_estimators": 500, "max_depth": None},
]

print(f"\n🔬 Entraînement de {len(configurations)} versions...\n")

resultats = []

for i, config in enumerate(configurations, 1):
    # UN RUN = UN ENTRAÎNEMENT tracé par MLflow
    with mlflow.start_run(run_name=f"version_{i}"):

        # a) Entraîner le modèle
        model = RandomForestRegressor(
            n_estimators=config["n_estimators"],
            max_depth=config["max_depth"],
            random_state=42,
        )
        model.fit(X_train, y_train)

        # b) Évaluer
        y_pred = model.predict(X_test)
        mae = mean_absolute_error(y_test, y_pred)
        rmse = np.sqrt(mean_squared_error(y_test, y_pred))
        r2 = r2_score(y_test, y_pred)

        # c) TRACER dans MLflow : params + métriques + modèle
        mlflow.log_param("n_estimators", config["n_estimators"])
        mlflow.log_param("max_depth", config["max_depth"])
        mlflow.log_metric("MAE", mae)
        mlflow.log_metric("RMSE", rmse)
        mlflow.log_metric("R2", r2)
        mlflow.sklearn.log_model(model, "model")

        resultats.append({**config, "MAE": mae, "R2": r2})
        print(f"  Version {i} : n_est={config['n_estimators']:>3}, "
              f"depth={str(config['max_depth']):>4}  →  "
              f"MAE={mae:.2f}j  R²={r2:.3f}")

# ---------------------------------------------------------------------------
# 4. Résumé
# ---------------------------------------------------------------------------
print("\n" + "="*70)
print("RÉSUMÉ")
print("="*70)

df = pd.DataFrame(resultats).sort_values("R2", ascending=False)
print("\nClassement par R² (meilleur en haut) :\n")
print(df.to_string(index=False))

best = df.iloc[0]
print(f"\n🏆 MEILLEURE VERSION : n_estimators={int(best['n_estimators'])}, "
      f"max_depth={best['max_depth']}  (R²={best['R2']:.3f}, MAE={best['MAE']:.2f}j)")

print("\n" + "="*70)
print("✅ TOUS LES RUNS SONT TRACÉS DANS MLflow !")
print("="*70)
print("""
👉 Pour VOIR le tableau comparatif dans ton navigateur, lance :

     mlflow ui

   puis ouvre http://127.0.0.1:5000 dans ton navigateur.

   Tu verras les 6 runs côte à côte : coche-les et clique "Compare"
   pour comparer params et métriques visuellement.
""")
