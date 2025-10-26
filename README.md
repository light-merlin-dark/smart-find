# Smart Find

Intelligent `find` wrapper that auto-excludes noise directories
CLI tool • User configuration • AI-optimized

## Why?

The standard `find` command wastes time searching massive directories you almost never want:
- `node_modules` (can contain 100k+ files)
- `.git`, `dist`, `build`, `.next`, `.cache`, etc.

**Impact:**
- Manual terminal commands slow down
- AI assistant tools waste time (Claude Code, etc.)
- Scripts search through irrelevant files
- Results buried in noise

## Solution

Smart wrapper that intercepts `find` commands and auto-excludes noise directories, while being intelligent enough to include them when explicitly requested.

**Key features:**
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

1. Script is placed at `~/.local/bin/find`
2. `~/.local/bin` is added to the beginning of your PATH
3. When you type `find`, the shell finds our script first
4. Script checks if you're explicitly searching excluded directories
5. If yes, uses `/usr/bin/find` (original)
6. If no, applies exclusion filters automatically

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

## Platform Support

- macOS (BSD find) ✓
- Linux (GNU find) ✓

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Contributing

Contributions welcome! Please feel free to submit a Pull Request.

## Author

Built to solve the eternal frustration of `find` drowning in node_modules.
