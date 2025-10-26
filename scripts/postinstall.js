#!/usr/bin/env node

console.log(`
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃  Smart Find                        ┃
┃  Installation Complete!            ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

The 'smart-find' command is now available globally.

IMPORTANT: To intercept the 'find' command system-wide:

  1. Run the following command:
     $ smart-find-setup

  2. Reload your shell:
     $ exec zsh
     (or: exec bash)

  3. Verify installation:
     $ which find
     Should show: ~/.local/bin/find

CONFIGURATION:

  • View ignored directories:    smart-find --config
  • Add custom ignore:            smart-find --add-ignore <dir>
  • Remove custom ignore:         smart-find --remove-ignore <dir>

UNINSTALL:

  To remove smart-find interception:
  $ find --uninstall
  (This only removes the interception, npm package remains)

  To completely remove:
  $ npm uninstall -g @light-merlin-dark/smart-find

For more info: https://github.com/light-merlin-dark/smart-find

`);
