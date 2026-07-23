"""
=============================================================================
    TESTS AUTOMATIQUES DU MODÈLE (Projet 15 — CI/CD)

    Ce sont ces tests que le robot GitHub Actions va lancer AUTOMATIQUEMENT
    à chaque fois que tu modifies ton code.

    En ML, on ne teste pas "le code marche ?" mais aussi "le modèle est-il
    assez bon ?". Si un jour une modif fait chuter la précision, le test
    échoue et le robot bloque le déploiement. 🚨

    Lancer en local :  pytest tests/ -v
=============================================================================
"""

import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score, mean_absolute_error


def generer_donnees(n=400, seed=0):
    """Recrée le dataset BTP synthétique (durée de chantier)."""
    rng = np.random.default_rng(seed)
    surface = rng.integers(20, 500, n)
    nb_ouvriers = rng.integers(1, 8, n)
    type_travail = rng.integers(0, 5, n)
    complexite = rng.integers(1, 4, n)
    duree = (
        surface * 0.15 + type_travail * 8 + complexite * 10
        - nb_ouvriers * 4 + rng.normal(0, 5, n)
    )
    duree = np.clip(duree, 1, None)
    X = pd.DataFrame({
        "surface": surface,
        "nb_ouvriers": nb_ouvriers,
        "type_travail": type_travail,
        "complexite": complexite,
    })
    return X, duree


def test_le_modele_atteint_une_precision_correcte():
    """Le modèle doit expliquer au moins 70% de la variance (R² > 0.70).
    Si une modif fait chuter en dessous, ce test échoue → déploiement bloqué."""
    X, y = generer_donnees()
    X_tr, X_te, y_tr, y_te = train_test_split(X, y, test_size=0.2, random_state=0)

    model = RandomForestRegressor(n_estimators=100, max_depth=10, random_state=0)
    model.fit(X_tr, y_tr)

    r2 = r2_score(y_te, model.predict(X_te))
    assert r2 > 0.70, f"R² trop bas : {r2:.3f} (attendu > 0.70)"


def test_les_predictions_sont_positives():
    """Une durée de chantier ne peut JAMAIS être négative."""
    X, y = generer_donnees()
    model = RandomForestRegressor(n_estimators=50, random_state=0)
    model.fit(X, y)

    predictions = model.predict(X)
    assert (predictions > 0).all(), "Certaines durées prédites sont négatives !"


def test_lerreur_moyenne_est_raisonnable():
    """L'erreur moyenne (MAE) doit rester en dessous de 15 jours."""
    X, y = generer_donnees()
    X_tr, X_te, y_tr, y_te = train_test_split(X, y, test_size=0.2, random_state=0)

    model = RandomForestRegressor(n_estimators=100, max_depth=10, random_state=0)
    model.fit(X_tr, y_tr)

    mae = mean_absolute_error(y_te, model.predict(X_te))
    assert mae < 15, f"Erreur moyenne trop grande : {mae:.1f} jours (attendu < 15)"


def test_le_modele_predit_la_bonne_forme():
    """Le modèle doit renvoyer une prédiction par ligne d'entrée."""
    X, y = generer_donnees(n=100)
    model = RandomForestRegressor(n_estimators=20, random_state=0)
    model.fit(X, y)

    predictions = model.predict(X)
    assert len(predictions) == len(X), "Nombre de prédictions incorrect"
