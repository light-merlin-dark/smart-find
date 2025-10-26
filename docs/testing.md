# Testing Smart Find

## Test Results Summary

All tests passed successfully on macOS (Darwin 25.0.0).

### Test 1: Normal Search Excludes node_modules
```bash
find . -name "*.js"
```
✅ Result: Found only project files, excluded node_modules

### Test 2: Explicit Search Includes node_modules (Intelligent!)
```bash
find ./node_modules -name "*.js"
```
✅ Result: Found files in node_modules (user explicitly requested it)

### Test 3: --raw Bypass Works
```bash
find . --raw -name "*.js"
```
✅ Result: Found all files including node_modules

### Test 4: SMART_FIND=0 Bypass Works
```bash
SMART_FIND=0 find . -name "*.js"
```
✅ Result: Found all files including node_modules

### Test 5: Works for All Find Operations
```bash
find .              # No pattern
find . -type f      # Find files
find . -type d      # Find directories
find . -mtime -1    # By modification time
find . -size +1M    # By size
```
✅ Result: All operations exclude node_modules by default

## Performance Comparison

Tested in a real repository with node_modules:

**Smart Find:**
- Time: 0.122s
- Output: Clean, project files first
- Result: Immediate useful information

**Raw Find:**
- Time: 0.018s
- Output: 99% node_modules noise
- Result: Must scroll through thousands of irrelevant files

**Verdict:** Smart find is slower but output quality makes it worth it. You see your actual files instead of node_modules garbage.

## Running Tests

### Quick Test
```bash
make test
```

### Manual Testing
```bash
# Create test directory
cd /tmp
mkdir -p test-smart-find/node_modules/package
echo "test" > test-smart-find/app.js
echo "test" > test-smart-find/node_modules/package/index.js
cd test-smart-find

# Test exclusion
find . -name "*.js"  # Should only show ./app.js

# Test intelligent inclusion
find ./node_modules -name "*.js"  # Should show ./node_modules/package/index.js

# Test bypass
find . --raw -name "*.js"  # Should show both files
```

## Test Environment
- Platform: macOS (Darwin 25.0.0)
- Shell: zsh
- Find: BSD find (macOS default)
