#!/usr/bin/env bash
# Fonctions partagées par les scripts du laboratoire.

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$LAB_DIR")"
DEMO_DIR="$PROJECT_DIR/demo"

# Motif d'un jeton GitHub personnel (format public et documenté).
TOKEN_REGEX='ghp_[0-9A-Za-z]{36}'

titre() {
    printf '\n\033[1m%s\033[0m\n' "$1"
}

verifier_outil() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "L'outil $1 est introuvable. Installation : $2"
        exit 1
    fi
}

verifier_demo() {
    if [ ! -d "$DEMO_DIR/.git" ]; then
        echo "Le dépôt de démonstration n'existe pas. Lancez d'abord lab/01_creer_depot_vulnerable.sh"
        exit 1
    fi
}

# Gitleaks a changé de syntaxe en version 8.19 : on choisit la bonne.
gitleaks_historique() {
    if gitleaks git --help >/dev/null 2>&1; then
        gitleaks git --redact --verbose "$1"
    else
        gitleaks detect --source "$1" --redact --verbose
    fi
}

gitleaks_commande_precommit() {
    if gitleaks git --help >/dev/null 2>&1; then
        echo "gitleaks git --pre-commit --staged --redact --verbose"
    else
        echo "gitleaks protect --staged --redact --verbose"
    fi
}

# Génère un faux jeton au moment de l'exécution.
# Le préfixe est découpé pour que ce fichier ne contienne jamais
# de chaîne ressemblant à un vrai secret.
generer_faux_jeton() {
    local prefixe="gh""p_"
    local corps
    corps="$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 36)"
    echo "${prefixe}${corps}"
}
