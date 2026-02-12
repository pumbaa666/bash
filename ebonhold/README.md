# Ebonhold Launcher

A launcher and updater for **[WoW Ebonhold](https://project-ebonhold.com/)**. This tool automatically downloads the latest game files from the Ebonhold servers and launches the game.

## Quick Start

### Windows

1. **First-time setup** - Run `install-python.bat` to set up Python and dependencies
2. **Configure credentials** - Create a `.env` file (see Configuration section)
3. **Launch the game** - Run `ebonhold-launcher.bat` to update and start Ebonhold

## Requirements

- **Python 3.8+** (Python 3.8.10 recommended for Windows 7 compatibility)
- **Dependencies**: `requests` library
- **Ebonhold account** with valid credentials

## Installation

### Windows Setup

#### Option 1: Automatic Installation (Recommended)
Run `install-python.bat` which will:
- Check if Python is installed
- Install Python 3.8.10 automatically if the installer is found in the current directory
- Create a virtual environment (`venv/`)
- Install the `requests` package

#### Option 2: Manual Installation
1. Download and install [Python 3.8.10](https://www.python.org/downloads/release/python-3810/) ([32 bits](https://www.python.org/ftp/python/3.8.10/python-3.8.10.exe), [64 bits](https://www.python.org/ftp/python/3.8.10/python-3.8.10-amd64.exe))
2. During installation, **check "Add Python to PATH"**
3. Run `install-python.bat` to set up the virtual environment and dependencies or manually create a virtual environment and install `requests`:
   ```bash
   python -m venv venv
   venv\Scripts\activate
   pip install requests
   ```

## Configuration

### Credentials

You can provide your Ebonhold account credentials in three ways (listed by priority):

1. **Command-line arguments**:
   ```bash
   ./update-ebonhold.sh --username=your@email.com --password=yourpassword
   ```

2. **Environment variables**:
   ```bash
   export ACCOUNT_EMAIL="your@email.com"
   export ACCOUNT_PASSWORD="yourpassword"
   ```

3. **.env file** (recommended):
   Create a `.env` file in the project directory:
   ```
   ACCOUNT_EMAIL=your@email.com
   ACCOUNT_PASSWORD=yourpassword
   ```

If credentials are not provided, the script will prompt for them interactively.

## Usage

### Windows

Simply run:
```batch
ebonhold-launcher.bat
```

This will:
1. Check for Python installation
2. Run the update script to download the latest game files
3. Launch `WoW.exe` automatically

### Linux/macOS

Not supported for now, that's why there is no `ebonhold-launcher.sh` script. You can still use the `update-ebonhold.py` or `update-ebonhold.sh` scripts to download the latest files, but you will need to launch the game manually.

Run the update script with the game location.
If the launcher is located in the same directory as the game files (as it should), --game-location is `.`:
```bash
./update-ebonhold.sh --game-location=.
```

### Update Script Options

The `update-ebonhold.py` and `update-ebonhold.sh` scripts support the following options:

| Option | Description |
|--------|-------------|
| `--username=EMAIL` | Your Ebonhold account email |
| `--password=PASS` | Your Ebonhold account password |
| `--game-location=PATH` | Path where game files should be copied (default: current directory) |
| `-l, --login` | Force re-login and refresh authentication token |
| `-f, --force` | Force download all files, even if up-to-date |
| `-c, --clear` | Clear downloads folder after copying files to game directory |
| `-dr, --dry-run` | Show what would be downloaded without actually downloading |
| `-d, --debug` | Enable debug logging for troubleshooting |
| `-h, --help` | Display help message |

### Examples

**Update and copy files to a specific location:**
```bash
./update-ebonhold.sh --game-location=/path/to/game
```

**Force download all files:**
```bash
./update-ebonhold.sh --force --game-location=.
```

**Dry run to see what would be updated:**
```bash
./update-ebonhold.sh --dry-run
```

**Force re-login with new credentials:**
```bash
./update-ebonhold.sh --login --username=new@email.com --password=newpass
```

## How It Works

1. **Authentication**: Logs in to the Ebonhold API and caches the authentication token
2. **File Check**: Fetches the list of required files from the server
3. **Update Detection**: Compares server file timestamps with local cache to detect outdated files
4. **Download**: Downloads only files that are new or have been updated
5. **Installation**: Copies downloaded files to the game directory
6. **Launch**: (Windows only) Starts the game executable

### Caching

- **Token cache**: `cache/token.json` - Stores authentication token (auto-refreshed when expired)
- **Patch cache**: `cache/last-patch-date.json` - Tracks file update timestamps to avoid redundant downloads
- **Downloads**: `downloads/` - Temporary storage for downloaded files

## Troubleshooting

### Python not found (Windows)
- Run `install-python.bat` to install Python automatically
- Or manually install Python 3.8.10 and ensure "Add to PATH" is checked

### Login failed
- Verify your credentials in `.env` file
- Use `--login` flag to force re-authentication
- Check your internet connection

### Files not updating
- Use `--force` flag to force re-download all files
- Delete `cache/last-patch-date.json` to reset update tracking
- Check debug output with `--debug` flag

### Game won't launch
- Verify `WoW.exe` exists in the game directory
- Ensure all files were downloaded successfully
- Check file permissions

## Project Structure

```
ebonhold/
├── install-python.bat        # Windows Python installer and setup
├── ebonhold-launcher.bat     # Windows launcher (updates + launches game)
├── update-ebonhold.py        # Python update script (cross-platform)
├── update-ebonhold.sh        # Bash update script (Linux/macOS)
├── .env                      # User credentials (not tracked in git)
├── .env.sample               # Template for .env file
├── cache/                    # Token and update tracking
│   ├── token.json
│   └── last-patch-date.json
└── downloads/                # Downloaded game files (temporary)
```

## API Endpoints

The updater connects to the Ebonhold API:
- **Base URL**: `https://api.project-ebonhold.com/api`
- **Login**: `/auth/login`
- **File List**: `/launcher/public-files?type=required`
- **Download**: `/launcher/download?file_ids=<id>`

## License

MIT License

## Author

**Pumbaa**
- GitHub: [github.com/pumbaa666](https://github.com/pumbaa666/)
- Website: [pumbaa.ch](https://pumbaa.ch)

## Security Note

**Never commit your `.env` file or credentials to version control.** The `.env.sample` file is provided as a template.
