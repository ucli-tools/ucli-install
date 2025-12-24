#!/bin/sh
# UCLI Tools Installer
# Usage: curl -sSL install.ucli.tools/install.sh | sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Repository details
REPO_URL="https://github.com/ucli-tools/ucli"
INSTALL_DIR="${HOME}/.ucli"
REPO_DIR="${INSTALL_DIR}/ucli"

printf "${BLUE}╔════════════════════════════════════════╗${NC}\n"
printf "${BLUE}║      UCLI Tools Installer v1.0.0       ║${NC}\n"
printf "${BLUE}╔════════════════════════════════════════╗${NC}\n"
printf "\n"

# Check if git is installed
if ! command -v git > /dev/null 2>&1; then
    printf "${RED}✗ Error: git is not installed${NC}\n"
    printf "Please install git first:\n"
    printf "  Ubuntu/Debian: sudo apt-get install git\n"
    printf "  macOS: brew install git\n"
    printf "  Fedora: sudo dnf install git\n"
    exit 1
fi

# Check if make is installed
if ! command -v make > /dev/null 2>&1; then
    printf "${RED}✗ Error: make is not installed${NC}\n"
    printf "Please install make first:\n"
    printf "  Ubuntu/Debian: sudo apt-get install build-essential\n"
    printf "  macOS: xcode-select --install\n"
    printf "  Fedora: sudo dnf groupinstall 'Development Tools'\n"
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
printf "${BLUE}→ Installing ucli CLI...${NC}\n"
make

printf "\n"
printf "${GREEN}╔════════════════════════════════════════╗${NC}\n"
printf "${GREEN}║      ✓ Installation Complete!          ║${NC}\n"
printf "${GREEN}╔════════════════════════════════════════╗${NC}\n"
printf "\n"
printf "Run: ${BLUE}ucli --version${NC} to verify installation\n"
printf "Get started: ${BLUE}ucli --help${NC}\n"
printf "\n"
printf "Documentation: ${BLUE}https://docs.ucli.tools${NC}\n"
printf "Registry: ${BLUE}https://registry.ucli.tools${NC}\n"
printf "\n"
