# Quick Download - Oricol Ticket Flow Auto Installer

## 🚀 One-Line Installation

Choose the command for your operating system:

### Windows (PowerShell)
```powershell
irm https://raw.githubusercontent.com/craigfelt/oricol-ticket-flow-c5475242/main/install.ps1 | iex
```

Or download and run separately:
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/craigfelt/oricol-ticket-flow-c5475242/main/install.ps1" -OutFile "install.ps1"
.\install.ps1
```

### macOS / Linux
```bash
curl -fsSL https://raw.githubusercontent.com/craigfelt/oricol-ticket-flow-c5475242/main/install.sh | bash
```

Or download and run separately:
```bash
curl -O https://raw.githubusercontent.com/craigfelt/oricol-ticket-flow-c5475242/main/install.sh
chmod +x install.sh
./install.sh
```

### Windows (Command Prompt / Batch)
Download the batch file:
```
https://raw.githubusercontent.com/craigfelt/oricol-ticket-flow-c5475242/main/install.bat
```
Then double-click `install.bat` to run.

## 📥 Direct Download Links

| Platform | Script | Download Link |
|----------|--------|---------------|
| Windows | PowerShell | [install.ps1](https://raw.githubusercontent.com/craigfelt/oricol-ticket-flow-c5475242/main/install.ps1) |
| Windows | Batch | [install.bat](https://raw.githubusercontent.com/craigfelt/oricol-ticket-flow-c5475242/main/install.bat) |
| macOS/Linux | Bash | [install.sh](https://raw.githubusercontent.com/craigfelt/oricol-ticket-flow-c5475242/main/install.sh) |

## ✅ What Gets Installed

After running the installer:
- Repository cloned to `lpc/` folder in current directory
- All npm dependencies installed
- `.env` file created from template
- Ready for configuration and first run

## 📋 Prerequisites

Make sure you have installed:
- ✅ Git
- ✅ Node.js (v18+)
- ✅ npm (comes with Node.js)

The installer will check for these and provide download links if missing.

## 🔧 After Installation

1. **Configure environment:**
   ```bash
   cd lpc
   # Edit .env with your Supabase credentials
   ```

2. **Run migrations:**
   ```bash
   npm run migrate
   ```

3. **Start the app:**
   ```bash
   npm run dev
   ```

4. **Open browser:**
   ```
   http://localhost:8080
   ```

## 📚 Documentation

For detailed information, see:
- [INSTALLER_README.md](./INSTALLER_README.md) - Full installer documentation
- [README.md](./README.md) - Main project documentation
- [QUICKSTART_GITHUB_SUPABASE.md](./QUICKSTART_GITHUB_SUPABASE.md) - Setup guide

## ⚠️ Security Note

**One-line installers**: The `curl | bash` and `irm | iex` commands download and execute scripts directly. This is convenient but only use these commands from trusted sources. If you prefer, download the script first, review it, then run it manually.

---

**Questions?** See [INSTALLER_README.md](./INSTALLER_README.md) for troubleshooting.
