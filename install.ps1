# Oricol Ticket Flow - Windows Installer (PowerShell)
# This script clones the GitHub repository and sets up the application

$ErrorActionPreference = "Stop"

# Configuration
$GITHUB_REPO = "https://github.com/craigfelt/oricol-ticket-flow-c5475242.git"
$INSTALL_DIR = "lpc"

# Color output functions
function Write-Info {
    param($Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param($Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Error-Message {
    param($Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-Warning {
    param($Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

# Display banner
Write-Host @"
╔══════════════════════════════════════════════════════════╗
║                                                          ║
║        Oricol Ticket Flow - Auto Installer              ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

Write-Info "Starting installation process..."

# Check if Git is installed
Write-Info "Checking for Git..."
try {
    $gitVersion = git --version
    Write-Success "Git is installed: $gitVersion"
} catch {
    Write-Error-Message "Git is not installed!"
    Write-Host ""
    Write-Host "Please install Git from: https://git-scm.com/download/win"
    Write-Host "After installation, restart this script."
    exit 1
}

# Check if Node.js is installed
Write-Info "Checking for Node.js..."
try {
    $nodeVersion = node --version
    Write-Success "Node.js is installed: $nodeVersion"
} catch {
    Write-Error-Message "Node.js is not installed!"
    Write-Host ""
    Write-Host "Please install Node.js from: https://nodejs.org/"
    Write-Host "After installation, restart this script."
    exit 1
}

# Check if npm is installed
Write-Info "Checking for npm..."
try {
    $npmVersion = npm --version
    Write-Success "npm is installed: v$npmVersion"
} catch {
    Write-Error-Message "npm is not installed!"
    Write-Host ""
    Write-Host "npm should come with Node.js. Please reinstall Node.js."
    exit 1
}

# Get current directory
$CURRENT_DIR = Get-Location
Write-Info "Installation directory: $CURRENT_DIR\$INSTALL_DIR"

# Check if installation directory already exists
if (Test-Path $INSTALL_DIR) {
    Write-Warning "Directory '$INSTALL_DIR' already exists!"
    $response = Read-Host "Do you want to remove it and reinstall? (y/N)"
    if ($response -eq "y" -or $response -eq "Y") {
        Write-Info "Removing existing directory..."
        Remove-Item -Recurse -Force $INSTALL_DIR
        Write-Success "Existing directory removed"
    } else {
        Write-Info "Installation cancelled by user"
        exit 0
    }
}

# Clone the repository
Write-Info "Cloning repository from GitHub..."
try {
    git clone $GITHUB_REPO $INSTALL_DIR
    Write-Success "Repository cloned successfully"
} catch {
    Write-Error-Message "Failed to clone repository!"
    Write-Host "Error: $_"
    exit 1
}

# Change to installation directory
Set-Location $INSTALL_DIR

# Install dependencies
Write-Info "Installing npm dependencies..."
Write-Info "This may take a few minutes..."
try {
    npm install
    Write-Success "Dependencies installed successfully"
} catch {
    Write-Error-Message "Failed to install dependencies!"
    Write-Host "Error: $_"
    Set-Location $CURRENT_DIR
    exit 1
}

# Create .env file if it doesn't exist
if (-not (Test-Path ".env")) {
    Write-Info "Creating .env file from template..."
    if (Test-Path ".env.example") {
        Copy-Item ".env.example" ".env"
        Write-Success ".env file created"
        Write-Warning "IMPORTANT: Edit the .env file with your Supabase credentials!"
    } else {
        Write-Warning ".env.example not found. You'll need to create .env manually."
    }
}

# Return to original directory
Set-Location $CURRENT_DIR

# Display completion message
Write-Host ""
Write-Host @"
╔══════════════════════════════════════════════════════════╗
║                                                          ║
║        Installation Complete!                            ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
"@ -ForegroundColor Green

Write-Host ""
Write-Success "Oricol Ticket Flow has been installed to: $CURRENT_DIR\$INSTALL_DIR"
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Edit the .env file with your Supabase credentials:"
Write-Host "     cd $INSTALL_DIR"
Write-Host "     notepad .env"
Write-Host ""
Write-Host "  2. Run database migrations:"
Write-Host "     cd $INSTALL_DIR"
Write-Host "     npm run migrate"
Write-Host ""
Write-Host "  3. Start the development server:"
Write-Host "     npm run dev"
Write-Host ""
Write-Host "  4. Open your browser to: http://localhost:8080"
Write-Host ""
Write-Host "For more information, see README.md in the $INSTALL_DIR directory"
Write-Host ""
