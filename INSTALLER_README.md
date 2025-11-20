# Auto Installer for Oricol Ticket Flow

This directory contains automated installer scripts that clone the GitHub repository and set up the Oricol Ticket Flow application in a local `lpc` folder.

## 📦 What It Does

The auto installer:
- ✅ Checks for required dependencies (Git, Node.js, npm)
- ✅ Clones the GitHub repository to a local `lpc` folder
- ✅ Installs all npm dependencies automatically
- ✅ Creates a `.env` file from the template
- ✅ Provides clear next steps for completing the setup

## 🚀 Quick Start

### Windows Users

**Option 1: PowerShell (Recommended)**
1. Download `install.ps1`
2. Right-click the file and select "Run with PowerShell"
   - Or open PowerShell in the directory and run: `.\install.ps1`

**Option 2: Batch File**
1. Download `install.bat`
2. Double-click the file to run it
   - Or open Command Prompt in the directory and run: `install.bat`

### macOS / Linux Users

1. Download `install.sh`
2. Open Terminal in the download directory
3. Make the script executable (if needed):
   ```bash
   chmod +x install.sh
   ```
4. Run the installer:
   ```bash
   ./install.sh
   ```

## 📥 Downloading the Installers

You can download the installer scripts directly from GitHub:

### Direct Download Links

**Windows PowerShell:**
```
https://raw.githubusercontent.com/craigfelt/oricol-ticket-flow-c5475242/main/install.ps1
```

**Windows Batch:**
```
https://raw.githubusercontent.com/craigfelt/oricol-ticket-flow-c5475242/main/install.bat
```

**macOS/Linux:**
```
https://raw.githubusercontent.com/craigfelt/oricol-ticket-flow-c5475242/main/install.sh
```

### Using curl or wget

**macOS/Linux:**
```bash
# Download using curl
curl -O https://raw.githubusercontent.com/craigfelt/oricol-ticket-flow-c5475242/main/install.sh

# Or using wget
wget https://raw.githubusercontent.com/craigfelt/oricol-ticket-flow-c5475242/main/install.sh

# Make executable and run
chmod +x install.sh
./install.sh
```

**Windows (PowerShell):**
```powershell
# Download using PowerShell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/craigfelt/oricol-ticket-flow-c5475242/main/install.ps1" -OutFile "install.ps1"

# Run the installer
.\install.ps1
```

## 📋 Prerequisites

Before running the installer, make sure you have:

### Required
- **Git** - Version control system
  - Windows: [Download Git](https://git-scm.com/download/win)
  - macOS: `brew install git` or [Download](https://git-scm.com/download/mac)
  - Linux: `sudo apt-get install git` or `sudo yum install git`

- **Node.js** (v18 or higher) - JavaScript runtime
  - [Download Node.js](https://nodejs.org/)
  - Includes npm (Node Package Manager)

### Optional
- **Supabase Account** - For cloud database (free tier available)
  - [Create account at supabase.com](https://supabase.com)

## 🔧 What Happens During Installation

1. **Dependency Check**
   - Verifies Git is installed
   - Verifies Node.js is installed
   - Verifies npm is installed

2. **Directory Setup**
   - Creates `lpc` folder in current directory
   - Checks if folder exists and prompts for overwrite

3. **Repository Clone**
   - Clones the GitHub repository into `lpc` folder
   - Downloads all project files

4. **Dependency Installation**
   - Runs `npm install`
   - Installs all required packages
   - May take 2-5 minutes

5. **Configuration Setup**
   - Creates `.env` file from `.env.example`
   - Reminds you to add Supabase credentials

## 📝 After Installation

After the installer completes, follow these steps:

### 1. Configure Environment Variables

Edit the `.env` file in the `lpc` directory:

```bash
cd lpc
# Windows
notepad .env

# macOS/Linux
nano .env
```

Add your Supabase credentials:
```env
VITE_SUPABASE_URL=your-project-url
VITE_SUPABASE_PUBLISHABLE_KEY=your-anon-key
VITE_SUPABASE_PROJECT_ID=your-project-id
```

Get these from your [Supabase Project Settings](https://app.supabase.com).

### 2. Run Database Migrations

```bash
cd lpc
npm run migrate
```

This sets up all required database tables.

### 3. Start the Development Server

```bash
npm run dev
```

The application will be available at `http://localhost:8080`

### 4. Create Admin Account

See `ADMIN_ACCOUNT_SETUP.md` in the `lpc` directory for instructions.

## 🔍 Installation Directory Structure

After installation, you'll have:

```
your-current-directory/
└── lpc/
    ├── src/                  # Source code
    ├── public/               # Static files
    ├── supabase/            # Database migrations
    ├── scripts/             # Helper scripts
    ├── .env                 # Configuration (you need to edit this)
    ├── package.json         # Dependencies
    ├── README.md            # Main documentation
    └── ...                  # Other project files
```

## ❓ Troubleshooting

### "Git is not installed"
- Install Git from the links above
- Restart your terminal/command prompt
- Run the installer again

### "Node.js is not installed"
- Install Node.js from https://nodejs.org/
- Choose the LTS (Long Term Support) version
- Restart your terminal/command prompt
- Run the installer again

### "Permission denied" (Linux/macOS)
- Make the script executable: `chmod +x install.sh`
- Or run with bash: `bash install.sh`

### "Execution of scripts is disabled" (Windows PowerShell)
Run PowerShell as Administrator and execute:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```
Then run the installer again.

### "Directory already exists"
The installer will ask if you want to overwrite.
- Choose `y` to remove and reinstall
- Choose `n` to cancel installation

### Installation fails during `npm install`
- Check your internet connection
- Try running manually:
  ```bash
  cd lpc
  npm install
  ```
- Clear npm cache if needed:
  ```bash
  npm cache clean --force
  npm install
  ```

## 🆘 Support

For more help:
- See `README.md` in the `lpc` folder after installation
- Check `QUICKSTART.md` for setup guides
- Review `TROUBLESHOOTING.md` for common issues
- Open an issue on GitHub

## 📚 Additional Documentation

After installation, check these files in the `lpc` directory:
- `README.md` - Main project documentation
- `QUICKSTART_GITHUB_SUPABASE.md` - 5-minute setup guide
- `LOCAL_SETUP.md` - Local development guide
- `ADMIN_ACCOUNT_SETUP.md` - Admin account creation
- `SUPABASE_MIGRATIONS.md` - Database migration guide

## 🔒 Security Notes

- Never commit your `.env` file to Git
- Keep your Supabase keys secure
- Use environment-specific configurations
- Follow security best practices in the documentation

## 📄 License

This installer is part of the Oricol Ticket Flow project.

---

**Last Updated**: November 2025
