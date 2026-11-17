#!/usr/bin/env bash
# Étape 4 : prévenir.
# Installe un hook pre-commit qui bloque tout commit contenant un secret.
set -uo pipefail
source "$(dirname "$0")/common.sh"
verifier_demo
verifier_outil gitleaks "brew install gitleaks"
cd "$DEMO_DIR"

titre "Installation du hook pre-commit"
HOOK=".git/hooks/pre-commit"
cat > "$HOOK" <<EOF
#!/usr/bin/env bash
# Bloque le commit si gitleaks trouve un secret dans les fichiers indexés.
$(gitleaks_commande_precommit) || {
    echo "Commit refusé : un secret a été détecté. Retirez-le avant de recommencer."
    exit 1
}
EOF
chmod +x "$HOOK"
echo "Hook installé dans $HOOK :"
cat "$HOOK"

titre "Test : tentative de commit d'une nouvelle clé"
cat > config.js <<EOF
module.exports = {
    API_KEY: "$(generer_faux_jeton)",
};
EOF
git add config.js
if git commit --quiet -m "Nouvelle configuration"; then
    echo "Le commit est passé : le hook n'a pas fonctionné."
    resultat=1
else
    echo "Le hook a bloqué le commit. Le secret n'est jamais entré dans l'historique."
    resultat=0
fi

titre "Remise en état du dépôt"
git reset --quiet HEAD config.js
git checkout --quiet -- config.js
git status --short
exit "$resultat"
