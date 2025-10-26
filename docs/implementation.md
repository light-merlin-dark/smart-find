# Smart Find: Auto-Ignore node_modules

## Problem
`find` commands waste time searching massive directories like `node_modules`, `.git`, `dist`, etc. that we almost never want to search. This happens in:
- Manual terminal commands
- AI assistant Bash tool commands
- Scripts and automation

## Solution: Intelligent PATH Wrapper Script
Create `~/.local/bin/find` that intercepts all find commands system-wide.

**Why this approach?**
- Shell functions/aliases only work in interactive shells (won't help Claude Code)
- Need system-level interception for both interactive and non-interactive shells
- Original `/usr/bin/find` remains untouched and accessible

**Intelligence:**
- `find . -name "*.js"` → auto-excludes node_modules ✓
- `find ./node_modules -name "*.js"` → includes node_modules (you asked for it!) ✓
- `find . --raw` → includes everything (explicit bypass) ✓
- Script detects when you explicitly search excluded dirs and doesn't filter them

## Implementation

### The Script: `~/.local/bin/find`
```bash
#!/usr/bin/env bash
# Smart find wrapper - auto-excludes noise directories
# Bypass: --raw flag, SMART_FIND=0, or /usr/bin/find
# Intelligent: if user explicitly searches node_modules/, don't filter it

# Bypass via env var
[[ "$SMART_FIND" == "0" ]] && exec /usr/bin/find "$@"

# Check for --raw flag or explicit excluded directory search
RAW_MODE=false
ARGS=()
EXCLUDED_DIRS=(node_modules .git dist build .next .nuxt target vendor .turbo .cache coverage __pycache__)

for arg in "$@"; do
  if [[ "$arg" == "--raw" ]]; then
    RAW_MODE=true
  else
    # Check if user is explicitly searching an excluded directory
    for dir in "${EXCLUDED_DIRS[@]}"; do
      if [[ "$arg" == *"$dir"* ]] && [[ "$arg" == ./* || "$arg" == /* || "$arg" == */* ]]; then
        RAW_MODE=true
        break 2
      fi
    done
    ARGS+=("$arg")
  fi
done

# If user explicitly wants excluded dirs, use raw find
[[ "$RAW_MODE" == "true" ]] && exec /usr/bin/find "${ARGS[@]}"

# Apply smart exclusions
EXCLUDE=(
  -path '*/node_modules' -prune -o
  -path '*/.git' -prune -o
  -path '*/dist' -prune -o
  -path '*/build' -prune -o
  -path '*/out' -prune -o
  -path '*/.next' -prune -o
  -path '*/.nuxt' -prune -o
  -path '*/target' -prune -o
  -path '*/vendor' -prune -o
  -path '*/.turbo' -prune -o
  -path '*/.cache' -prune -o
  -path '*/coverage' -prune -o
  -path '*/__pycache__' -prune -o
)

exec /usr/bin/find "${EXCLUDE[@]}" "$@" -print
```

### Safe Testing (Before System-Wide Install)

```bash
# 1. Create test script with different name
mkdir -p ~/.local/bin
# (save script to ~/.local/bin/smart-find)
chmod +x ~/.local/bin/smart-find

# 2. Test without modifying PATH
alias sf='~/.local/bin/smart-find'

# 3. Run comprehensive tests
sf . -name "*.ts"                    # Should exclude node_modules
sf . -name "*.ts" | grep node_modules # Should be empty
sf ./node_modules -name "*.js"       # Should INCLUDE node_modules (intelligent!)
sf . --raw -name "*.ts" | grep node_modules # Should include node_modules
SMART_FIND=0 sf . -name "*.ts" | grep node_modules # Should include node_modules

# 4. Performance test
time sf . > /dev/null
time /usr/bin/find . > /dev/null     # Compare speeds

# 5. If all tests pass, proceed to installation
```

### Installation (After Testing)

```bash
# 1. Rename test script to find
mv ~/.local/bin/smart-find ~/.local/bin/find

# 2. Backup current PATH (optional safety)
echo "export PATH_BACKUP='$PATH'" >> ~/.zshrc.backup

# 3. Add to PATH (check if already exists first!)
grep -q '.local/bin' ~/.zshrc || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
grep -q '.local/bin' ~/.bashrc || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

# 4. Reload shell
exec zsh  # or: source ~/.zshrc

# 5. Verify
which find  # Should show: /Users/merlin/.local/bin/find
```

### Verification Tests
```bash
# Test 1: Normal search excludes node_modules
find . -name "*.js" | grep -c node_modules  # Should be 0

# Test 2: Explicit search includes node_modules
find ./node_modules -name "*.js" | head -5  # Should show results

# Test 3: Raw bypass works
find . --raw -name "*.js" | grep -c node_modules  # Should be > 0

# Test 4: Original find still accessible
/usr/bin/find . -name "*.js" | grep -c node_modules  # Should be > 0

# Test 5: Works in scripts
bash -c 'find . -name "*.ts"'  # Should exclude node_modules
```

## Rollback (If Needed)
```bash
# Quick rollback: just remove the script
rm ~/.local/bin/find
# That's it! Original find at /usr/bin/find takes over immediately

# Optional: restore PATH backup
# source ~/.zshrc.backup

# Optional: clean up PATH modifications
# Edit ~/.zshrc and ~/.bashrc to remove: export PATH="$HOME/.local/bin:$PATH"
```

## Why Not Other Approaches?
- **Shell functions**: Only work in interactive shells (fail for Claude Code)
- **Aliases**: Same limitation as functions
- **fd alternative**: Different syntax, AI won't use it
- All we need is a simple PATH wrapper that works everywhere
