#!/usr/bin/env bash
# Smart Find setup script
# Installs smart-find as the system find command

INSTALL_DIR="$HOME/.local/bin"
SCRIPT_NAME="find"
BACKUP_SUFFIX=".backup"
SHELL_RC_ZSH="$HOME/.zshrc"
SHELL_PROFILE_ZSH="$HOME/.zprofile"
SHELL_RC_BASH="$HOME/.bashrc"
SHELL_PROFILE="$HOME/.profile"

echo "Smart Find - Installing..."
echo ""

# Create install directory
mkdir -p "$INSTALL_DIR"

# Backup existing find if it exists and is not already our script
if [[ -f "$INSTALL_DIR/$SCRIPT_NAME" ]] && [[ ! -f "$INSTALL_DIR/$SCRIPT_NAME$BACKUP_SUFFIX" ]]; then
  # Check if it's already smart-find
  if ! grep -q "Smart find wrapper" "$INSTALL_DIR/$SCRIPT_NAME" 2>/dev/null; then
    echo "Backing up existing find to $INSTALL_DIR/$SCRIPT_NAME$BACKUP_SUFFIX"
    cp "$INSTALL_DIR/$SCRIPT_NAME" "$INSTALL_DIR/$SCRIPT_NAME$BACKUP_SUFFIX"
  fi
fi

# Find the smart-find script location (where npm installed it)
SMART_FIND_PATH=$(which smart-find 2>/dev/null)

if [[ -z "$SMART_FIND_PATH" ]]; then
  echo "❌ Error: smart-find command not found"
  echo "   Please install via: npm install -g @light-merlin-dark/smart-find"
  exit 1
fi

# Resolve symlink(s) to an absolute path (portable for relative symlinks)
resolve_path() {
  local target="$1"

  while [[ -L "$target" ]]; do
    local link
    link=$(readlink "$target")
    if [[ "$link" == /* ]]; then
      target="$link"
    else
      target="$(cd "$(dirname "$target")" && pwd -P)/$link"
    fi
  done

  echo "$(cd "$(dirname "$target")" && pwd -P)/$(basename "$target")"
}

SMART_FIND_PATH="$(resolve_path "$SMART_FIND_PATH")"

if [[ ! -f "$SMART_FIND_PATH" ]]; then
  echo "❌ Error: resolved smart-find path does not exist:"
  echo "   $SMART_FIND_PATH"
  exit 1
fi

# Copy smart-find to find
cp "$SMART_FIND_PATH" "$INSTALL_DIR/$SCRIPT_NAME"
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

echo "✅ Smart find installed to $INSTALL_DIR/$SCRIPT_NAME"

# Ensure ~/.local/bin is prepended in shell startup files so interception works
# in interactive and non-interactive shells.
ensure_prepend_local_bin() {
  local rc_file="$1"
  local desired='export PATH="$HOME/.local/bin:$PATH"'
  local label="$2"

  [[ -f "$rc_file" ]] || return 0

  if grep -Eq '^export PATH=.*\.local/bin' "$rc_file" 2>/dev/null; then
    awk '!/^export PATH=.*\.local\/bin/' "$rc_file" > "$rc_file.tmp" && mv "$rc_file.tmp" "$rc_file"
    printf '\n%s\n' "$desired" >> "$rc_file"
    echo "✅ Updated PATH precedence in $label"
  else
    printf '\n%s\n' "$desired" >> "$rc_file"
    echo "✅ Added ~/.local/bin to PATH in $label"
  fi
}

ensure_prepend_local_bin "$SHELL_RC_ZSH" "$SHELL_RC_ZSH"
ensure_prepend_local_bin "$SHELL_PROFILE_ZSH" "$SHELL_PROFILE_ZSH"
ensure_prepend_local_bin "$SHELL_RC_BASH" "$SHELL_RC_BASH"
ensure_prepend_local_bin "$SHELL_PROFILE" "$SHELL_PROFILE"

echo ""
echo "Installation complete! Reload your shell:"
echo "  exec zsh"
echo "  (or: exec bash)"
echo ""
echo "Verify installation:"
echo "  which find  # Should show $INSTALL_DIR/$SCRIPT_NAME"
echo ""
echo "Configure ignored directories:"
echo "  find --config"
echo "  find --add-ignore <directory>"
