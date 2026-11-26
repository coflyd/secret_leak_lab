# Secrets dans l'historique git : détecter, corriger, prévenir

Un laboratoire reproductible qui montre pourquoi supprimer une clé d'API d'un fichier ne suffit pas, comment la retrouver dans l'historique d'un dépôt, comment corriger la fuite et comment l'empêcher de se reproduire.

## Contexte

En auditant mes propres dépôts GitHub, j'ai découvert qu'une clé d'API était restée lisible dans l'historique d'un projet d'équipe universitaire. La clé avait été retirée du code, mais elle restait accessible à toute personne capable de parcourir les anciens commits. J'ai signalé la fuite pour que la clé soit révoquée, puis j'ai construit ce laboratoire pour comprendre le problème en profondeur.

Le cas réel n'est pas reproduit ici. Toute la démonstration se fait sur un dépôt local, avec un faux jeton généré à l'exécution.

## Pourquoi c'est un problème

Git conserve chaque version de chaque fichier. Quand un secret est retiré dans un nouveau commit, l'ancien commit le contient toujours. Sur un dépôt public, n'importe qui peut le lire, et des robots parcourent GitHub en permanence pour récolter ces clés. Une clé d'API volée peut servir à consommer des services payants aux frais de son propriétaire ou à accéder à ses données.

## Démarche

| Étape | Script | Ce que l'on démontre |
|---|---|---|
| 1. Reproduire | `lab/01_creer_depot_vulnerable.sh` | Une clé est ajoutée puis retirée : le code actuel paraît propre. |
| 2. Détecter | `lab/02_detecter.sh` | La clé reste visible dans l'historique, d'abord avec git, puis avec gitleaks. |
| 3. Corriger | `lab/03_corriger.sh` | La révocation passe en premier, puis git filter-repo efface la clé de tous les commits. |
| 4. Prévenir | `lab/04_prevenir.sh` | Un hook pre-commit bloque tout nouveau commit contenant un secret. |

## Prérequis

Le laboratoire fonctionne sous macOS et Linux, avec git, gitleaks et git filter-repo.

```bash
brew install gitleaks git-filter-repo
```

## Utilisation

Lancez les scripts dans l'ordre, depuis la racine du projet.

```bash
bash lab/01_creer_depot_vulnerable.sh
bash lab/02_detecter.sh
bash lab/03_corriger.sh
bash lab/04_prevenir.sh
```

Le dépôt de démonstration est créé dans le dossier `demo/`, qui est exclu du suivi git. Relancer l'étape 1 le recrée à neuf.

## Rapport

Le rapport d'incident complet se trouve dans [docs/rapport_incident.md](docs/rapport_incident.md).

## Références

1. [Documentation de gitleaks](https://github.com/gitleaks/gitleaks)
2. [Documentation de git filter-repo](https://github.com/newren/git-filter-repo)
3. [GitHub : supprimer des données sensibles d'un dépôt](https://docs.github.com/fr/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)
4. [GitHub : protection des envois et analyse des secrets](https://docs.github.com/fr/code-security/secret-scanning/introduction/about-secret-scanning)
5. [OWASP : Secrets Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)
