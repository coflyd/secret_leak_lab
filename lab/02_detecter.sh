#!/usr/bin/env bash
# Étape 2 : détecter le secret, d'abord à la main, puis avec gitleaks.
set -uo pipefail
source "$(dirname "$0")/common.sh"
verifier_demo
cd "$DEMO_DIR"

titre "Méthode 1 : chercher dans les fichiers actuels"
if grep -rnE "$TOKEN_REGEX" --exclude-dir=.git . ; then
    echo "Un secret est présent dans les fichiers actuels."
else
    echo "Aucun secret dans les fichiers actuels. Un audit superficiel s'arrêterait ici."
fi

titre "Méthode 2 : chercher dans tout l'historique avec git"
echo "Commande : git log -p --all -G '$TOKEN_REGEX'"
echo
git log -p --all -G "$TOKEN_REGEX" --format='Commit %h du %ad par %an : %s' --date=short \
    | grep -E "^Commit|^[+-].*ghp_" \
    | sed -E 's/(ghp_[0-9A-Za-z]{4})[0-9A-Za-z]{32}/\1****(masqué)/'
echo
echo "La clé apparaît dans l'historique : ajoutée dans un commit, retirée dans le suivant."

titre "Méthode 3 : analyse automatique avec gitleaks"
verifier_outil gitleaks "brew install gitleaks"
gitleaks_historique "$DEMO_DIR"
code=$?
echo
if [ "$code" -ne 0 ]; then
    echo "Gitleaks a trouvé au moins un secret (code de sortie $code)."
else
    echo "Gitleaks n'a rien trouvé."
fi
