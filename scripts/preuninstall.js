#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const os = require('os');

console.log('\nSmart Find - Cleanup...\n');

const homeDir = os.homedir();
const installDir = path.join(homeDir, '.local', 'bin');
const findScript = path.join(installDir, 'find');
const backupScript = path.join(installDir, 'find.backup');

// Remove the find wrapper
if (fs.existsSync(findScript)) {
  // Check if it's our script
  const content = fs.readFileSync(findScript, 'utf8');
  if (content.includes('Smart find wrapper')) {
    fs.unlinkSync(findScript);
    console.log(`✅ Removed ${findScript}`);

    // Restore backup if it exists
    if (fs.existsSync(backupScript)) {
      fs.renameSync(backupScript, findScript);
      console.log(`✅ Restored backup to ${findScript}`);
    }
  }
}

console.log(`
✅ Smart Find cleanup complete!

Note: PATH modifications in ~/.zshrc and ~/.bashrc remain.
      (They're harmless but you can remove them manually if desired)

`);
