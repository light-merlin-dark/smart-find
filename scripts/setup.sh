#!/usr/bin/env bash
# Smart Find setup script
# Installs smart-find as the system find command

INSTALL_DIR="$HOME/.local/bin"
SCRIPT_NAME="find"
BACKUP_SUFFIX=".backup"
SHELL_RC_ZSH="$HOME/.zshrc"
SHELL_RC_BASH="$HOME/.bashrc"

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

# Resolve symlink to get actual script location
if [[ -L "$SMART_FIND_PATH" ]]; then
  SMART_FIND_PATH=$(readlink "$SMART_FIND_PATH")
fi

# Copy smart-find to find
cp "$SMART_FIND_PATH" "$INSTALL_DIR/$SCRIPT_NAME"
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

echo "✅ Smart find installed to $INSTALL_DIR/$SCRIPT_NAME"

# Add to PATH if not already there
if [[ -f "$SHELL_RC_ZSH" ]]; then
  if ! grep -q '.local/bin' "$SHELL_RC_ZSH" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC_ZSH"
    echo "✅ Added ~/.local/bin to PATH in $SHELL_RC_ZSH"
  else
    echo "✅ PATH already configured in $SHELL_RC_ZSH"
  fi
fi

if [[ -f "$SHELL_RC_BASH" ]]; then
  if ! grep -q '.local/bin' "$SHELL_RC_BASH" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC_BASH"
    echo "✅ Added ~/.local/bin to PATH in $SHELL_RC_BASH"
  else
    echo "✅ PATH already configured in $SHELL_RC_BASH"
  fi
fi

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
