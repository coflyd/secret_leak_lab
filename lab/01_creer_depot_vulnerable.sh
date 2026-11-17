#!/usr/bin/env bash
# Étape 1 : reproduire l'erreur.
# Crée un dépôt local dans lequel un faux secret est ajouté, puis "supprimé".
set -euo pipefail
source "$(dirname "$0")/common.sh"

titre "Création du dépôt de démonstration dans demo/"
rm -rf "$DEMO_DIR"
mkdir -p "$DEMO_DIR"
cd "$DEMO_DIR"
git init --quiet
git config user.name "Demo"
git config user.email "demo@example.invalid"

titre "Commit 1 : une application qui appelle une API"
cat > app.js <<'EOF'
const { API_KEY } = require("./config");

async function genererRecettes(ingredients) {
    const reponse = await fetch("https://api.example.invalid/recipes", {
        method: "POST",
        headers: { Authorization: `Bearer ${API_KEY}` },
        body: JSON.stringify({ ingredients }),
    });
    return reponse.json();
}

module.exports = { genererRecettes };
EOF
git add app.js
git commit --quiet -m "Ajout de l'appel à l'API de recettes"

titre "Commit 2 : l'erreur, la clé est écrite en dur dans le code"
FAUX_JETON="$(generer_faux_jeton)"
cat > config.js <<EOF
module.exports = {
    API_KEY: "${FAUX_JETON}",
};
EOF
git add config.js
git commit --quiet -m "Configuration de l'API"

titre "Commit 3 : la fausse correction, la clé est retirée du fichier"
cat > config.js <<'EOF'
module.exports = {
    API_KEY: process.env.API_KEY,
};
EOF
echo ".env" > .gitignore
git add config.js .gitignore
git commit --quiet -m "Déplacement de la clé dans une variable d'environnement"

titre "Résultat"
git log --oneline
echo
echo "Le fichier config.js actuel ne contient plus aucune clé :"
cat config.js
echo
echo "Pourtant, le commit 2 existe toujours. Lancez lab/02_detecter.sh pour le prouver."
