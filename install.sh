#!/bin/bash
# Oricol Ticket Flow - Unix/Linux/macOS Installer
# This script clones the GitHub repository and sets up the application

set -e  # Exit on error

# Configuration
GITHUB_REPO="https://github.com/craigfelt/oricol-ticket-flow-c5475242.git"
INSTALL_DIR="lpc"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Output functions
info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Display banner
echo -e "${CYAN}"
cat << "EOF"
╔══════════════════════════════════════════════════════════╗
║                                                          ║
║        Oricol Ticket Flow - Auto Installer              ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

info "Starting installation process..."
echo

# Check if Git is installed
info "Checking for Git..."
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version)
    success "Git is installed: $GIT_VERSION"
else
    error "Git is not installed!"
    echo
    echo "Please install Git:"
    echo "  Ubuntu/Debian: sudo apt-get install git"
    echo "  CentOS/RHEL:   sudo yum install git"
    echo "  macOS:         brew install git"
    echo
    echo "After installation, restart this script."
    exit 1
fi
echo

# Check if Node.js is installed
info "Checking for Node.js..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    success "Node.js is installed: $NODE_VERSION"
else
    error "Node.js is not installed!"
    echo
    echo "Please install Node.js from: https://nodejs.org/"
    echo "Or use a version manager like nvm: https://github.com/nvm-sh/nvm"
    echo
    echo "After installation, restart this script."
    exit 1
fi
echo

# Check if npm is installed
info "Checking for npm..."
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    success "npm is installed: v$NPM_VERSION"
else
    error "npm is not installed!"
    echo
    echo "npm should come with Node.js. Please reinstall Node.js."
    exit 1
fi
echo

# Get current directory
CURRENT_DIR=$(pwd)
info "Installation directory: $CURRENT_DIR/$INSTALL_DIR"
echo

# Check if installation directory already exists
if [ -d "$INSTALL_DIR" ]; then
    warning "Directory '$INSTALL_DIR' already exists!"
    read -p "Do you want to remove it and reinstall? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        info "Removing existing directory..."
        rm -rf "$INSTALL_DIR"
        success "Existing directory removed"
        echo
    else
        info "Installation cancelled by user"
        exit 0
    fi
fi

# Clone the repository
info "Cloning repository from GitHub..."
if git clone "$GITHUB_REPO" "$INSTALL_DIR"; then
    success "Repository cloned successfully"
    echo
else
    error "Failed to clone repository!"
    exit 1
fi

# Change to installation directory
cd "$INSTALL_DIR"

# Install dependencies
info "Installing npm dependencies..."
info "This may take a few minutes..."
if npm install; then
    success "Dependencies installed successfully"
    echo
else
    error "Failed to install dependencies!"
    cd "$CURRENT_DIR"
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    info "Creating .env file from template..."
    if [ -f ".env.example" ]; then
        cp ".env.example" ".env"
        success ".env file created"
        warning "IMPORTANT: Edit the .env file with your Supabase credentials!"
        echo
    else
        warning ".env.example not found. You'll need to create .env manually."
        echo
    fi
fi

# Return to original directory
cd "$CURRENT_DIR"

# Display completion message
echo
echo -e "${GREEN}"
cat << "EOF"
╔══════════════════════════════════════════════════════════╗
║                                                          ║
║        Installation Complete!                            ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo
success "Oricol Ticket Flow has been installed to: $CURRENT_DIR/$INSTALL_DIR"
echo
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Edit the .env file with your Supabase credentials:"
echo "     cd $INSTALL_DIR"
echo "     nano .env  # or use your preferred editor"
echo
echo "  2. Run database migrations:"
echo "     cd $INSTALL_DIR"
echo "     npm run migrate"
echo
echo "  3. Start the development server:"
echo "     npm run dev"
echo
echo "  4. Open your browser to: http://localhost:8080"
echo
echo "For more information, see README.md in the $INSTALL_DIR directory"
echo
