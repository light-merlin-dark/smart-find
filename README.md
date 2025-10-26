```
 (smart)
 ███████╗██╗███╗   ██╗██████╗
 ██╔════╝██║████╗  ██║██╔══██╗
 █████╗  ██║██╔██╗ ██║██║  ██║
 ██╔══╝  ██║██║╚██╗██║██║  ██║
 ██║     ██║██║ ╚████║██████╔╝
 ╚═╝     ╚═╝╚═╝  ╚═══╝╚═════╝
```

**Intelligent wrapper for the native `find` command**

Drop-in replacement • Auto-excludes build artifacts • Works with BSD & GNU find

## What It Replaces

The native `find` command that ships with your OS:
- **macOS**: BSD find (`/usr/bin/find`)
- **Linux**: GNU findutils find (`/usr/bin/find`)

This wrapper intercepts `find` calls and intelligently filters out build artifacts and dependency directories that waste time and pollute results.

## Why?

The standard `find` command wastes time searching massive directories you almost never want:
- `node_modules` (can contain 100k+ files)
- `.git`, `dist`, `build`, `.next`, `.cache`, etc.

**Impact:**
- Manual terminal commands slow down
- AI assistant tools waste time (Claude Code, etc.)
- Scripts search through irrelevant files
- Results buried in noise

**Solution:**
Auto-excludes noise directories while being intelligent enough to include them when explicitly requested.

**Key features:**
- Drop-in replacement (no syntax changes)
- User-configurable ignore list
- Intelligent detection (explicit paths bypass filters)
- Multiple bypass options
- Zero configuration required

## Features

### Automatic Exclusion
```bash
find . -name "*.ts"          # Excludes node_modules automatically
find . -type f               # Excludes node_modules automatically
find .                       # Excludes node_modules automatically
```

### Intelligent Detection
```bash
find ./node_modules -name "*.js"  # INCLUDES node_modules (you asked for it!)
find ./dist -type f              # INCLUDES dist (explicit path)
```

### Multiple Bypass Options
```bash
find . --raw -name "*.ts"        # Include everything
SMART_FIND=0 find . -name "*.ts" # Include everything
/usr/bin/find . -name "*.ts"     # Use original find directly
```

### Default Excluded Directories
- `node_modules`
- `.git`
- `dist`
- `build`
- `out`
- `.next`
- `.nuxt`
- `target` (Rust/Java)
- `vendor` (Go/PHP)
- `.turbo`
- `.cache`
- `coverage`
- `__pycache__` (Python)

### Configuration Management

Customize your ignore list with simple commands:

```bash
# View current configuration
find --config          # or --list-ignored

# Add custom directories to ignore
find --add-ignore tmp
find --add-ignore .venv

# Remove custom ignores
find --remove-ignore tmp
```

**Configuration stored at:** `~/.config/smart-find/config`

**How it works:**
- Built-in directories are always excluded (cannot be removed)
- User additions are persistent across sessions
- Config file is simple text (one directory per line)
- Comments supported (lines starting with #)

**Example config file:**
```
# User-defined ignored directories
tmp
.venv
.pytest_cache
```

## Installation

```bash
# Install globally
npm install -g @light-merlin-dark/smart-find

# Run setup to intercept find command
smart-find-setup

# Reload your shell
exec zsh  # or: exec bash
```

This will:
1. Copy `smart-find` to `~/.local/bin/find`
2. Add `~/.local/bin` to your PATH in `~/.zshrc` and `~/.bashrc`
3. Create a backup at `~/.local/bin/find.backup` if one already exists

## Uninstall

```bash
# Remove find interception
find --uninstall

# Remove npm package (optional)
npm uninstall -g @light-merlin-dark/smart-find
```

## Verification

After installation:
```bash
which find  # Should show: ~/.local/bin/find
find . -name "*.ts" | grep -c node_modules  # Should be 0
find ./node_modules -type f | head -5       # Should show results
```

## How It Works

This is a **drop-in replacement** that intercepts `find` commands:

1. Wrapper script installed at `~/.local/bin/find`
2. `~/.local/bin` prepended to your PATH (higher priority than `/usr/bin`)
3. When you type `find`, the shell finds our wrapper first
4. Wrapper analyzes your command:
   - **Explicit paths** to excluded dirs → pass through to native find
   - **General searches** → add exclusion filters automatically
5. Native `find` at `/usr/bin/find` does the actual work
6. You get faster, cleaner results with zero syntax changes

## Rollback

Use the built-in uninstall command:
```bash
find --uninstall
```

Or manually delete the wrapper:
```bash
rm ~/.local/bin/find
# Original find at /usr/bin/find takes over immediately
```

## OS Compatibility

**Works anywhere the native `find` command exists:**

| OS | Find Version | Status |
|---|---|---|
| macOS | BSD find | ✓ Tested |
| Linux (Debian/Ubuntu) | GNU findutils | ✓ Tested |
| Linux (RHEL/Fedora/Arch) | GNU findutils | ✓ Compatible |
| Unix-like systems | BSD/GNU find | ✓ Should work |

**Requirements:**
- Bash shell
- Native `find` command at `/usr/bin/find`
- `~/.local/bin` in your PATH (setup script handles this)

## License

MIT License - see [LICENSE](LICENSE) file for details.

---

Built by [@EnchantedRobot](https://twitter.com/EnchantedRobot)
