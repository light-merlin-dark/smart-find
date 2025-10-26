.PHONY: help check-auth version patch minor major push release

help:
	@echo "Smart Find - Release Commands"
	@echo ""
	@echo "NPM Registry:"
	@echo "  make check-auth - Check npm authentication status"
	@echo ""
	@echo "Version Management:"
	@echo "  make version    - Show current version"
	@echo "  make patch      - Bump patch version (1.0.0 -> 1.0.1)"
	@echo "  make minor      - Bump minor version (1.0.0 -> 1.1.0)"
	@echo "  make major      - Bump major version (1.0.0 -> 2.0.0)"
	@echo ""
	@echo "Release Management:"
	@echo "  make push       - Version bump and push to GitHub"
	@echo "  make release    - Full release: push + publish to npm"

check-auth:
	@echo "🔐 Checking npm authentication..."
	@if npm whoami --registry https://registry.npmjs.org/ > /dev/null 2>&1; then \
		echo "✅ Authenticated as: $$(npm whoami --registry https://registry.npmjs.org/)"; \
	else \
		echo "❌ Not authenticated. Run: npm login"; \
		exit 1; \
	fi

version:
	@node -p "require('./package.json').version"

patch:
	@npm version patch
	@echo "Version bumped to $$(make version)"

minor:
	@npm version minor
	@echo "Version bumped to $$(make version)"

major:
	@npm version major
	@echo "Version bumped to $$(make version)"

push:
	@echo "🚀 Preparing release..."
	@echo "📝 Committing and pushing to GitHub..."
	@git push
	@git push --tags
	@echo "✅ Changes pushed to GitHub!"

release: check-auth push
	@echo ""
	@echo "📦 Publishing to npm..."
	@npm publish --access public 2>/dev/null || \
		(echo "❌ Publish failed. Retrying with verbose output..." && npm publish --access public)
	@echo "✅ Published to npm!"
	@echo ""
	@echo "⏳ Waiting 10 seconds for npm registry propagation..."
	@sleep 10
	@echo ""
	@echo "✅ Release complete!"
	@echo "   Version: $$(make version)"
	@echo "   Package: @light-merlin-dark/smart-find"
