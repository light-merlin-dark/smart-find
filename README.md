# Smart Find

Intelligent `find` command wrapper that automatically excludes noise directories like `node_modules`, `.git`, `dist`, etc.

## Problem

The standard `find` command wastes time searching massive directories that you almost never want to search:
- `node_modules` (can contain 100k+ files)
- `.git`, `dist`, `build`, `.next`, `.cache`, etc.

This affects:
- Manual terminal commands
- AI assistant tools (Claude Code, etc.)
- Scripts and automation

## Solution

A smart wrapper that intercepts `find` commands and automatically excludes noise directories, while being intelligent enough to include them when explicitly requested.

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

### Excluded Directories
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

## Installation

```bash
make install
```

This will:
1. Copy `bin/find` to `~/.local/bin/find`
2. Add `~/.local/bin` to your PATH in `~/.zshrc` and `~/.bashrc`
3. Create a backup at `~/.local/bin/find.backup` if one already exists

## Testing Before Install

```bash
make test
```

Runs comprehensive tests without modifying your system.

## Uninstall

```bash
make uninstall
```

Restores the original `find` behavior by removing `~/.local/bin/find`.

## Verification

After installation:
```bash
which find  # Should show: /Users/merlin/.local/bin/find
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

Simply delete the wrapper:
```bash
rm ~/.local/bin/find
# Original find at /usr/bin/find takes over immediately
```

Or use:
```bash
make uninstall
```

## Platform Support

- macOS (BSD find) ✓
- Linux (GNU find) ✓

## License

MIT

## Author

Built to solve the eternal frustration of `find` drowning in node_modules.
