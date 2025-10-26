.PHONY: help install uninstall test clean

INSTALL_DIR := $(HOME)/.local/bin
SCRIPT_NAME := find
BACKUP_SUFFIX := .backup
SHELL_RC_ZSH := $(HOME)/.zshrc
SHELL_RC_BASH := $(HOME)/.bashrc

help:
	@echo "Smart Find - Intelligent find wrapper"
	@echo ""
	@echo "Available targets:"
	@echo "  make install    - Install smart find to ~/.local/bin/find"
	@echo "  make uninstall  - Remove smart find and restore original"
	@echo "  make test       - Run tests without installing"
	@echo "  make clean      - Remove test artifacts"
	@echo ""
	@echo "After install, reload your shell:"
	@echo "  exec zsh"

install:
	@echo "Installing smart find..."
	@mkdir -p $(INSTALL_DIR)
	@if [ -f $(INSTALL_DIR)/$(SCRIPT_NAME) ] && [ ! -f $(INSTALL_DIR)/$(SCRIPT_NAME)$(BACKUP_SUFFIX) ]; then \
		echo "Backing up existing find to $(INSTALL_DIR)/$(SCRIPT_NAME)$(BACKUP_SUFFIX)"; \
		cp $(INSTALL_DIR)/$(SCRIPT_NAME) $(INSTALL_DIR)/$(SCRIPT_NAME)$(BACKUP_SUFFIX); \
	fi
	@cp bin/$(SCRIPT_NAME) $(INSTALL_DIR)/$(SCRIPT_NAME)
	@chmod +x $(INSTALL_DIR)/$(SCRIPT_NAME)
	@echo "Smart find installed to $(INSTALL_DIR)/$(SCRIPT_NAME)"
	@if ! grep -q '\.local/bin' $(SHELL_RC_ZSH) 2>/dev/null; then \
		echo 'export PATH="$$HOME/.local/bin:$$PATH"' >> $(SHELL_RC_ZSH); \
		echo "Added ~/.local/bin to PATH in $(SHELL_RC_ZSH)"; \
	else \
		echo "PATH already configured in $(SHELL_RC_ZSH)"; \
	fi
	@if [ -f $(SHELL_RC_BASH) ]; then \
		if ! grep -q '\.local/bin' $(SHELL_RC_BASH) 2>/dev/null; then \
			echo 'export PATH="$$HOME/.local/bin:$$PATH"' >> $(SHELL_RC_BASH); \
			echo "Added ~/.local/bin to PATH in $(SHELL_RC_BASH)"; \
		else \
			echo "PATH already configured in $(SHELL_RC_BASH)"; \
		fi \
	fi
	@echo ""
	@echo "Installation complete! Reload your shell:"
	@echo "  exec zsh"
	@echo ""
	@echo "Verify installation:"
	@echo "  which find  # Should show $(INSTALL_DIR)/$(SCRIPT_NAME)"

uninstall:
	@echo "Uninstalling smart find..."
	@if [ -f $(INSTALL_DIR)/$(SCRIPT_NAME) ]; then \
		rm $(INSTALL_DIR)/$(SCRIPT_NAME); \
		echo "Removed $(INSTALL_DIR)/$(SCRIPT_NAME)"; \
	else \
		echo "Smart find not found at $(INSTALL_DIR)/$(SCRIPT_NAME)"; \
	fi
	@if [ -f $(INSTALL_DIR)/$(SCRIPT_NAME)$(BACKUP_SUFFIX) ]; then \
		mv $(INSTALL_DIR)/$(SCRIPT_NAME)$(BACKUP_SUFFIX) $(INSTALL_DIR)/$(SCRIPT_NAME); \
		echo "Restored backup to $(INSTALL_DIR)/$(SCRIPT_NAME)"; \
	fi
	@echo ""
	@echo "Uninstall complete. Original find restored."
	@echo "Note: PATH modifications in ~/.zshrc and ~/.bashrc remain."
	@echo "      (They're harmless but you can remove them manually if desired)"

test:
	@echo "Running smart find tests..."
	@mkdir -p /tmp/smart-find-test/node_modules/test-package
	@echo "test" > /tmp/smart-find-test/test.js
	@echo "test" > /tmp/smart-find-test/node_modules/test-package/index.js
	@echo ""
	@echo "Test 1: Normal search excludes node_modules"
	@cd /tmp/smart-find-test && $(PWD)/bin/$(SCRIPT_NAME) . -name "*.js" | grep -q "test.js" && echo "✅ PASS" || echo "❌ FAIL"
	@cd /tmp/smart-find-test && $(PWD)/bin/$(SCRIPT_NAME) . -name "*.js" | grep -q "node_modules.*index.js" && echo "❌ FAIL: Found node_modules" || echo "✅ PASS: node_modules excluded"
	@echo ""
	@echo "Test 2: Explicit node_modules search includes it"
	@cd /tmp/smart-find-test && $(PWD)/bin/$(SCRIPT_NAME) ./node_modules -name "*.js" | grep -q "index.js" && echo "✅ PASS" || echo "❌ FAIL"
	@echo ""
	@echo "Test 3: --raw bypass includes node_modules"
	@cd /tmp/smart-find-test && $(PWD)/bin/$(SCRIPT_NAME) . --raw -name "*.js" | grep -q "node_modules.*index.js" && echo "✅ PASS" || echo "❌ FAIL"
	@echo ""
	@echo "Test 4: SMART_FIND=0 bypass includes node_modules"
	@cd /tmp/smart-find-test && SMART_FIND=0 $(PWD)/bin/$(SCRIPT_NAME) . -name "*.js" | grep -q "node_modules.*index.js" && echo "✅ PASS" || echo "❌ FAIL"
	@echo ""
	@echo "All tests complete!"

clean:
	@rm -rf /tmp/smart-find-test
	@echo "Test artifacts cleaned"
