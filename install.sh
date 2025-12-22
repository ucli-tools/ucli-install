#!/bin/bash
# UCLI Tools Installer
# Usage: curl -fsSL https://install.ucli.tools | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

# Repository details
REPO_URL="https://github.com/ucli-tools/ucli"
INSTALL_DIR="${HOME}/.ucli"
REPO_DIR="${INSTALL_DIR}/ucli"

printf "${ORANGE}╔════════════════════════════════════════╗${NC}\n"
printf "${ORANGE}║    UCLI Tools Installer v1.0.0        ║${NC}\n"
printf "${ORANGE}╚════════════════════════════════════════╝${NC}\n"
printf "\n"

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

OS=$(detect_os)
printf "${BLUE}→ Detected OS: ${OS}${NC}\n"

# Check if curl is installed
if ! command -v curl > /dev/null 2>&1; then
    printf "${RED}✗ Error: curl is not installed${NC}\n"
    printf "Please install curl first:\n"
    case $OS in
        linux)
            printf "  Ubuntu/Debian: sudo apt-get install curl\n"
            printf "  Fedora: sudo dnf install curl\n"
            printf "  Arch: sudo pacman -S curl\n"
            ;;
        macos)
            printf "  macOS: brew install curl\n"
            ;;
        *)
            printf "  Please install curl using your package manager\n"
            ;;
    esac
    exit 1
fi

# Check if git is installed
if ! command -v git > /dev/null 2>&1; then
    printf "${RED}✗ Error: git is not installed${NC}\n"
    printf "Please install git first:\n"
    case $OS in
        linux)
            printf "  Ubuntu/Debian: sudo apt-get install git\n"
            printf "  Fedora: sudo dnf install git\n"
            printf "  Arch: sudo pacman -S git\n"
            ;;
        macos)
            printf "  macOS: brew install git\n"
            ;;
        *)
            printf "  Please install git using your package manager\n"
            ;;
    esac
    exit 1
fi

# Check if make is installed
if ! command -v make > /dev/null 2>&1; then
    printf "${RED}✗ Error: make is not installed${NC}\n"
    printf "Please install make first:\n"
    case $OS in
        linux)
            printf "  Ubuntu/Debian: sudo apt-get install build-essential\n"
            printf "  Fedora: sudo dnf groupinstall 'Development Tools'\n"
            printf "  Arch: sudo pacman -S make\n"
            ;;
        macos)
            printf "  macOS: xcode-select --install\n"
            ;;
        *)
            printf "  Please install build tools using your package manager\n"
            ;;
    esac
    exit 1
fi

printf "${GREEN}✓ Prerequisites check passed${NC}\n"
printf "\n"

# Create install directory
printf "${BLUE}→ Creating installation directory...${NC}\n"
mkdir -p "${INSTALL_DIR}"

# Clone or update repository
if [ -d "${REPO_DIR}" ]; then
    printf "${YELLOW}→ Repository already exists, updating...${NC}\n"
    cd "${REPO_DIR}"
    git fetch origin
    git reset --hard origin/main
else
    printf "${BLUE}→ Cloning ucli repository...${NC}\n"
    git clone "${REPO_URL}" "${REPO_DIR}"
    cd "${REPO_DIR}"
fi

printf "${GREEN}✓ Repository ready${NC}\n"
printf "\n"

# Run installation
printf "${BLUE}→ Installing ucli tool manager...${NC}\n"
make install

printf "\n"
printf "${GREEN}╔════════════════════════════════════════╗${NC}\n"
printf "${GREEN}║    ✓ UCLI Tools Installation Complete! ║${NC}\n"
printf "${GREEN}╚════════════════════════════════════════╝${NC}\n"
printf "\n"
printf "Run: ${ORANGE}ucli --version${NC} to verify installation\n"
printf "Get started: ${ORANGE}ucli help${NC}\n"
printf "\n"
printf "Next steps:\n"
printf "  1. Login to organization: ${ORANGE}ucli login${NC}\n"
printf "  2. Install tools: ${ORANGE}ucli build gits mdtexpdf${NC}\n"
printf "  3. Explore docs: ${ORANGE}https://docs.ucli.tools${NC}\n"
printf "\n"
printf "Documentation: ${BLUE}https://docs.ucli.tools${NC}\n"
printf "Registry: ${BLUE}https://registry.ucli.tools${NC}\n"
printf "\n"
