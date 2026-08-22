#!/usr/bin/env bash
# create-react-app.sh — scaffold a Vite + React + Tailwind project with optional extras
#
# Usage:
#   ./create-react-app.sh my-app
#   ./create-react-app.sh my-app --icons --router --axios
#   ./create-react-app.sh my-app --all
#
# Optional flags:
#   --icons     install lucide-react (icon library)
#   --router    install react-router-dom
#   --axios     install axios (HTTP client)
#   --state     install zustand (lightweight state management)
#   --all       shorthand for all of the above
#   --npm | --pnpm | --yarn   pick package manager (default: npm)
#
# Requires: node + npm (or pnpm/yarn) on PATH.

set -euo pipefail

# ---------- defaults ----------
PROJECT_NAME=""
PKG_MANAGER="npm"
WANT_ICONS=false
WANT_ROUTER=false
WANT_AXIOS=false
WANT_STATE=false

# ---------- helpers ----------
info()  { echo -e "\033[1;34m==>\033[0m $1"; }
ok()    { echo -e "\033[1;32m✓\033[0m $1"; }
err()   { echo -e "\033[1;31mError:\033[0m $1" >&2; }

usage() {
    grep '^#' "$0" | sed 's/^# \{0,1\}//' | sed '1d'
    exit 1
}

# ---------- parse args ----------
if [ $# -eq 0 ]; then
    usage
fi

for arg in "$@"; do
    case "$arg" in
        --icons)  WANT_ICONS=true ;;
        --router) WANT_ROUTER=true ;;
        --axios)  WANT_AXIOS=true ;;
        --state)  WANT_STATE=true ;;
        --all)    WANT_ICONS=true; WANT_ROUTER=true; WANT_AXIOS=true; WANT_STATE=true ;;
        --npm)    PKG_MANAGER="npm" ;;
        --pnpm)   PKG_MANAGER="pnpm" ;;
        --yarn)   PKG_MANAGER="yarn" ;;
        -h|--help) usage ;;
        --*) err "Unknown flag: $arg"; usage ;;
        *)
            if [ -z "$PROJECT_NAME" ]; then
                PROJECT_NAME="$arg"
            else
                err "Unexpected argument: $arg"
                usage
            fi
            ;;
    esac
done

if [ -z "$PROJECT_NAME" ]; then
    err "You must provide a project name."
    usage
fi

if [ -d "$PROJECT_NAME" ]; then
    err "Folder '$PROJECT_NAME' already exists."
    exit 1
fi

# ---------- check tooling ----------
if ! command -v node >/dev/null 2>&1; then
    err "Node.js is not installed or not on PATH. Install it from https://nodejs.org"
    exit 1
fi

if ! command -v "$PKG_MANAGER" >/dev/null 2>&1; then
    err "$PKG_MANAGER is not installed or not on PATH."
    exit 1
fi

# ---------- scaffold with Vite ----------
info "Creating Vite + React project '$PROJECT_NAME'..."
case "$PKG_MANAGER" in
    npm)  npm create vite@latest "$PROJECT_NAME" -- --template react ;;
    pnpm) pnpm create vite "$PROJECT_NAME" --template react ;;
    yarn) yarn create vite "$PROJECT_NAME" --template react ;;
esac

cd "$PROJECT_NAME"

# ---------- install base deps ----------
info "Installing base dependencies..."
case "$PKG_MANAGER" in
    npm)  npm install ;;
    pnpm) pnpm install ;;
    yarn) yarn install ;;
esac

# ---------- Tailwind CSS (v4, Vite plugin approach) ----------
info "Installing Tailwind CSS..."
case "$PKG_MANAGER" in
    npm)  npm install tailwindcss @tailwindcss/vite ;;
    pnpm) pnpm add tailwindcss @tailwindcss/vite ;;
    yarn) yarn add tailwindcss @tailwindcss/vite ;;
esac

info "Configuring Tailwind in vite.config.js..."
cat > vite.config.js <<'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  plugins: [react(), tailwindcss()],
})
EOF

info "Adding Tailwind import to src/index.css..."
echo '@import "tailwindcss";' > src/index.css

# ---------- optional extras ----------
EXTRA_PKGS=()
$WANT_ICONS  && EXTRA_PKGS+=("lucide-react")
$WANT_ROUTER && EXTRA_PKGS+=("react-router-dom")
$WANT_AXIOS  && EXTRA_PKGS+=("axios")
$WANT_STATE  && EXTRA_PKGS+=("zustand")

if [ ${#EXTRA_PKGS[@]} -gt 0 ]; then
    info "Installing extras: ${EXTRA_PKGS[*]}"
    case "$PKG_MANAGER" in
        npm)  npm install "${EXTRA_PKGS[@]}" ;;
        pnpm) pnpm add "${EXTRA_PKGS[@]}" ;;
        yarn) yarn add "${EXTRA_PKGS[@]}" ;;
    esac
fi

# ---------- summary ----------
echo
ok "Project '$PROJECT_NAME' is ready."
echo "  - React + ReactDOM (via Vite)"
echo "  - Tailwind CSS"
$WANT_ICONS  && echo "  - lucide-react (icons)"
$WANT_ROUTER && echo "  - react-router-dom"
$WANT_AXIOS  && echo "  - axios"
$WANT_STATE  && echo "  - zustand (state management)"
echo
echo "Next steps:"
echo "  cd $PROJECT_NAME"
echo "  $PKG_MANAGER run dev"
