# Installer Files Manifest

This document lists all files related to the auto-installer feature.

## Core Installer Scripts

| File | Platform | Description | Size |
|------|----------|-------------|------|
| `install.sh` | macOS/Linux/Unix | Bash installer script with colored output | ~5KB |
| `install.ps1` | Windows | PowerShell installer script with colored output | ~5KB |
| `install.bat` | Windows | Batch file installer (alternative) | ~4KB |

## Documentation Files

| File | Description |
|------|-------------|
| `INSTALLER_README.md` | Comprehensive installer documentation |
| `QUICK_INSTALL.md` | Quick reference with one-line install commands |
| `INSTALLER_MANIFEST.md` | This file - lists all installer-related files |

## Updated Files

| File | Changes |
|------|---------|
| `README.md` | Added auto-installer section in Quick Start |

## Installation Directory

All installers clone the repository to: **`lpc/`** (Local Project Copy)

This directory is created in the same location where the installer script is executed.

## Features Implemented

### All Installers Include:
- ✅ Prerequisites checking (Git, Node.js, npm)
- ✅ Repository cloning to `lpc` folder
- ✅ Automatic dependency installation (`npm install`)
- ✅ `.env` file creation from `.env.example`
- ✅ Colored/formatted output for better UX
- ✅ Error handling with helpful messages
- ✅ Overwrite protection with confirmation prompt
- ✅ Clear next steps displayed after installation

### Platform-Specific Features:

**install.sh (Bash)**
- ANSI color codes for terminal output
- Cross-platform compatibility (macOS/Linux/WSL)
- Executable bit set automatically

**install.ps1 (PowerShell)**
- PowerShell color formatting
- Error action preference set to "Stop"
- Native Windows PowerShell functions

**install.bat (Batch)**
- Windows Command Prompt compatible
- No special permissions required
- Simple double-click execution

## Download Methods

### Direct Download from GitHub
Users can download files directly from the repository using the GitHub web interface.

### Raw File URLs
```
install.sh:   https://raw.githubusercontent.com/craigfelt/oricol-ticket-flow-c5475242/main/install.sh
install.ps1:  https://raw.githubusercontent.com/craigfelt/oricol-ticket-flow-c5475242/main/install.ps1
install.bat:  https://raw.githubusercontent.com/craigfelt/oricol-ticket-flow-c5475242/main/install.bat
```

### One-Line Install Commands

**macOS/Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/craigfelt/oricol-ticket-flow-c5475242/main/install.sh | bash
```

**Windows PowerShell:**
```powershell
irm https://raw.githubusercontent.com/craigfelt/oricol-ticket-flow-c5475242/main/install.ps1 | iex
```

## Testing

### Syntax Validation
- ✅ Bash script: Validated with `bash -n install.sh`
- ✅ PowerShell script: Syntax follows PowerShell best practices
- ✅ Batch script: Syntax follows Windows batch conventions

### Manual Testing Required
Users should test the installers on:
- [ ] Windows 10/11 with PowerShell
- [ ] Windows 10/11 with Command Prompt
- [ ] macOS (latest)
- [ ] Ubuntu/Debian Linux
- [ ] CentOS/RHEL Linux

## Security Considerations

1. **Source Verification**: Users should only run installers from trusted sources
2. **Script Review**: Users can review scripts before execution
3. **HTTPS URLs**: All download links use HTTPS
4. **No Credential Storage**: Installers never store or transmit credentials
5. **Local Installation**: All operations performed locally

## Troubleshooting

Common issues and solutions are documented in:
- `INSTALLER_README.md` - Comprehensive troubleshooting section
- `QUICK_INSTALL.md` - Quick reference for common issues

## Maintenance

### Updating the Repository URL
If the repository is moved or renamed, update the `GITHUB_REPO` variable in:
- `install.sh` (line 8)
- `install.ps1` (line 7)
- `install.bat` (line 8)

### Updating the Installation Directory
To change the default `lpc` folder name, update the `INSTALL_DIR` variable in:
- `install.sh` (line 9)
- `install.ps1` (line 8)
- `install.bat` (line 9)

## Version History

- **v1.0** (2025-11-20): Initial release
  - Windows PowerShell installer
  - Windows Batch installer
  - macOS/Linux Bash installer
  - Comprehensive documentation

---

**Last Updated**: November 20, 2025
