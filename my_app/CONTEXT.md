# 🚀 FICHE CONTEXTUELLE DU PROJET : HABITU
Date de la Synthèse : 2025-12-07
Statut : MVP (Minimum Viable Product) en Planification

---

## 1. VISION ET CONTEXTE STRATÉGIQUE

### 1.1 Le Problème et la Solution Unique

| Catégorie | Description |
| :--- | :--- |
| **Problème** | Les applications de suivi d'habitudes occidentales échouent sur le marché africain car elles sont basées sur l'individualisme radical. |
| **Solution (ADN)** | **HABITU** fusionne la discipline personnelle (`HABIT`) avec la responsabilité communautaire et l'interdépendance (`UBUNTU`). |
| **Slogan** | **HABITU — Grandir Ensemble.** |
| **Public Cible** | Jeunes Professionnels, Étudiants, et Commerçants africains (marchés Mobile-First : Dakar, Lagos, Nairobi, etc.). |

### 1.2 Identité de Marque et Nomenclature Culturelle

| Élément | Signification | Rôle dans l'App |
| :--- | :--- | :--- |
| **HABITU** | HABIT + UBUNTU (Philosophie bantoue). | Nom du Produit. |
| **Le Baobab** | Symbole de longévité et de rassemblement. | Indicateur visuel de croissance et de progression individuelle (remplace la barre de progression). |
| **Le Cercle** | Évocation de la réunion communautaire (Tontines, Chamas). | Le Groupe de Responsabilité. |
| **Imara** | Swahili pour "Solide/Ferme". | Statut de Constance (Streak) et succès collectif. |

---

## 2. SPÉCIFICATIONS FONCTIONNELLES CLÉS (MVP CORE)

Les fonctionnalités critiques doivent valider notre proposition de valeur unique.

### 2.1 Moteur d'Habitudes et UX (SF-02)

* **SF-02.1 Validation :** Geste simple **"Swipe"** (Glissement) pour la validation (optimisé pour une main).
* **SF-02.2 Résilience :** Fonctionnement strict **Offline-First**. L'enregistrement est instantané en local (SQLite), la synchronisation est en arrière-plan (deltas).

### 2.2 Le Cœur Communautaire (SF-03)

* **SF-03.2 Visualisation :** Représentation du Cercle comme un **anneau graphique**. Un échec (un membre manquant) doit **briser visiblement l'anneau** (ligne rouge), exploitant la pression sociale positive.
* **SF-03.3 Nudge :** Bouton d'action directe pour envoyer un rappel pré-écrit (Coup de Coude) aux retardataires **via WhatsApp**, utilisant le numéro de téléphone collecté.

### 2.3 Onboarding et Qualification Détaillée (SF-01)

* **Authentification (SF-01.1) :** Supporte **Numéro de Téléphone (OTP via WhatsApp)** et **Google Sign-In**.
* **Qualification Post-Auth (PM Décision) :** L'utilisateur doit répondre à **3-5 questions rapides** pour collecter des données manquantes (`Sexe`, `Ville`, `Objectif Urgent`, `Friction Principale`) qui sont des inputs pour l'IA.
* **Recommandation IA (SF-01.2) :** Une **Fonction Edge (Serverless)** utilise les données de qualification pour générer **3 habitudes pertinentes** et un **Nom de Cercle** pour l'utilisateur, qu'il valide ou modifie.

---

## 3. ARCHITECTURE TECHNIQUE ET GESTION DES RISQUES

| Composant | Technologie Choisie | Rationale PM / Mitigation |
| :--- | :--- | :--- |
| **Frontend** | **Flutter** (Dart) | Performance native sur Android à faible RAM (1GB), code unique (iOS/Android). |
| **Stratégie de Données** | **PowerSync + SQLite** | Permet une base de données relationnelle locale nécessaire pour les Cercles (Offline-First). Réduit drastiquement la consommation de Data (Delta Sync). |
| **Backend / BaaS** | **Supabase** (PostgreSQL, Auth, Edge Functions) | Base de données puissante, Auth simple, utilisation des Edge Functions pour le moteur de recommandation IA côté serveur. |
| **Paiement (SF-06.2)** | **Mobile Money (MoMo/M-Pesa/Wave)** via Flutterwave/Paystack. | **Risque :** Abandon dû à la friction. **Mitigation :** Flux de paiement conçu pour la résilience (gestion des timeouts et des Push/USSD). |
| **UX/UI Fragmentation** | Design **Mobile-First Minimaliste**. | **Risque :** Débordement sur petits écrans (Tecno/Infinix). **Mitigation :** Les actions critiques sont dans une **Barre de Navigation Inférieure Fixe**. Tests sur les "Golden Devices" (low-end Android). |

---

## 4. MODÈLE ÉCONOMIQUE ET CROISSANCE

### 4.1 Modèle Freemium (SF-06.1)

* **Free Tier :** 3 habitudes max, 1 Cercle, Statistiques de base (Baobab).
* **Premium :** Habitudes Illimitées, Cercles Illimités, **Le Conseil des Sages (Analytique IA Préventive)** – incluant l'**Analyse de Risque du Cercle** (prévoir qui va échouer) et Benchmarking Ubuntu.

### 4.2 Stratégie d'Acquisition (PM Décision)

* **Canal Prioritaire :** **TikTok** (Utilisation du contenu organique, non publicitaire).
* **Moteur Viral :** Lancement du **#HabituCercleChallenge** pour exploiter la "Honte Positive" et pousser l'utilisateur à cliquer sur **"Invite un ami dans le Cercle"** (SF-03.1) dès l'onboarding.

---

**FIN DU BRIEF CONTEXTUEL**