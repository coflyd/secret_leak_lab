#!/usr/bin/env bash
# Étape 3 : corriger.
# La seule vraie correction est la révocation de la clé.
# La réécriture de l'historique vient ensuite, pour nettoyer.
set -uo pipefail
source "$(dirname "$0")/common.sh"
verifier_demo
verifier_outil git-filter-repo "brew install git-filter-repo"

titre "Action 1 : révoquer la clé"
echo "Dans un cas réel, on révoque d'abord la clé chez le fournisseur, puis on en crée une nouvelle."
echo "Tant que la clé fonctionne, toute personne qui l'a copiée peut l'utiliser."
echo "Ici, le jeton est faux : il n'y a rien à révoquer."

titre "Action 2 : réécrire l'historique pour effacer la clé de tous les commits"
REGLES="$(mktemp)"
echo "regex:${TOKEN_REGEX}==>CLE_SUPPRIMEE" > "$REGLES"
cd "$DEMO_DIR"
git filter-repo --replace-text "$REGLES" --force
rm -f "$REGLES"

titre "Vérification"
if git log -p --all | grep -qE "$TOKEN_REGEX"; then
    echo "La clé est encore présente dans l'historique."
    exit 1
fi
echo "La clé n'apparaît plus dans aucun commit. Contenu du commit 2 après nettoyage :"
git show HEAD~1:config.js

titre "Limites de cette correction"
echo "Sur un dépôt déjà publié, il faudrait encore pousser l'historique réécrit avec git push --force,"
echo "prévenir chaque collaborateur, car son clone local contient toujours l'ancien historique,"
echo "et demander à l'hébergeur de purger ses caches. Les copies déjà faites restent hors de contrôle."
echo "C'est pourquoi la révocation passe avant tout le reste."
