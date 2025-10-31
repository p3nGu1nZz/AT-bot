# 📊 atproto Development Workflow & Decision Tree

**Purpose**: Quick visual guide for "what should I work on next?"  
**Date**: October 28, 2025

---

## 🎯 DECISION TREE: What Should I Work On?

```
                    START HERE
                        ↓
                ┌───────────────┐
                │ Have you read │
                │  PROJECT_    │
                │ REVIEW &     │
                │ PHASE2_     │
                │ ACTIONS?     │
                └───┬───────┬──┘
                   NO      YES
                    ↓       ↓
                  [READ]   ↓
                           ┌─────────────────────────┐
                           │ Pick a focus area:      │
                           ├─────────────────────────┤
                           │ A) MCP Server           │
                           │ B) JSON Output Format   │
                           │ C) Linux Packaging      │
                           │ D) macOS Packaging      │
                           │ E) Documentation Build  │
                           └────────┬────┬────┬─────┘
                                   │    │    │
              ┌────────────────────┘    │    └─────────────┐
              │                        │                  │
         ┌────▼─────┐            ┌────▼────┐        ┌────▼─────┐
         │  EASIEST │            │ MEDIUM  │        │ HARDEST  │
         └────┬─────┘            └────┬────┘        └────┬─────┘
              │                       │                  │
         A) npm install          B) --format json   C,D) debian/
         npm build               Add to all cmds        Homebrew
         npm start               Test + docs            pkg config
         (1-2h)                  (6-8h)                 (4-6h each)
              │                       │                  │
              └───────────┬───────────┴──────────┬───────┘
                          │
                    ┌─────▼──────┐
                    │ Commit to  │
                    │   GitHub   │
                    └────────────┘
```

---

## 🚦 PRIORITY MATRIX

```
IMPACT
  ↑
  │ HIGH
  │        ┌─────────────┬──────────────┐
  │        │ MCP Build   │ JSON Output  │  ← DO THESE FIRST
  │        │ (Quick win) │ (Big impact) │
  │        ├─────────────┼──────────────┤
  │        │ Packaging   │ Publishing   │
  │        │ (Important) │ (Docs)       │  ← DO THESE SECOND
  │        └─────────────┴──────────────┘
  │  LOW
  │
  └──────────────────────────────────────→ EFFORT
              EASY                HARD
```

---

## 📋 QUICK START CHECKLIST

Choose ONE item, do it completely, then move to next.

### ✅ ITEM 1: MCP SERVER COMPILATION (Easiest)
**Time**: 1-2 hours | **Difficulty**: ⭐ | **Impact**: 🔥🔥🔥

```bash
# Step 1: Navigate
cd /mnt/c/Users/3nigma/source/repos/atproto/mcp-server

# Step 2: Install
npm install

# Step 3: Build
npm run build

# Step 4: Test
npm start
# Should see: "atproto MCP Server started successfully"
# Should see: "Registered 27 tools"

# Step 5: Verify
ls -la dist/
# Should see dist/index.js and other compiled files

# Step 6: Stop server
# Press Ctrl+C

# Step 7: Commit
cd ..
git add mcp-server/dist/  # or update .gitignore if excluding
git commit -m "build: compile MCP server TypeScript"
git push origin main
```

**Success Criteria**:
- ✅ npm install completes without errors
- ✅ npm run build creates dist/ directory
- ✅ npm start runs without crashing
- ✅ Sees "27 tools" message
- ✅ Changes committed to git

**Next**: Move to Item 2

---

### ✅ ITEM 2: JSON OUTPUT FORMAT (Most Valuable)
**Time**: 6-8 hours | **Difficulty**: ⭐⭐ | **Impact**: 🔥🔥

```bash
# Step 1: Understand the goal
# Add --format json to ALL commands
# atproto whoami --format json
# atproto feed --format json

# Step 2: Plan the implementation
# Edit lib/atproto.sh:
#   - Add function output_json() 
#   - Modify all functions to return structured data
#
# Edit bin/atproto:
#   - Parse --format flag
#   - Route output through formatter
#   - Maintain backward compatibility

# Step 3: Implement core functions
# Priority order:
#   1. whoami, post, feed (most used)
#   2. follow, profile, search (common)
#   3. All others

# Step 4: Test each command
atproto whoami --format json | jq .           # Test parsing
atproto post "hello" --format json | jq .     # Test parsing
atproto feed --format json | jq '.' | head    # Test parsing

# Step 5: Write tests
# Create tests/test_json_output.sh
# Test all commands with JSON flag

# Step 6: Update documentation
# Add examples to README
# Document JSON schemas

# Step 7: Commit
git add lib/ bin/ tests/
git commit -m "feat: add JSON output format (--format json)"
git push origin main
```

**Success Criteria**:
- ✅ `--format json` flag recognized
- ✅ Output is valid JSON (can parse with jq)
- ✅ All fields documented
- ✅ Tests passing
- ✅ Backward compatible (default output unchanged)

**Next**: Move to Item 3

---

### ✅ ITEM 3: DEBIAN PACKAGING (Linux)
**Time**: 4-6 hours | **Difficulty**: ⭐⭐⭐ | **Impact**: 🔥

```bash
# Step 1: Create debian directory structure
mkdir -p debian
cd debian

# Step 2: Create files
cat > control << 'EOF'
Package: atproto
Version: 0.4.0
Architecture: all
Depends: bash, curl, jq
Maintainer: atproto Contributors <mail@example.com>
Description: Bluesky/AT Protocol CLI tool
 atproto provides a simple command-line interface for
 interacting with Bluesky and the AT Protocol.
EOF

cat > rules << 'EOF'
#!/usr/bin/make -f
%:
	dh $@
override_dh_auto_build:
	true
EOF
chmod 755 rules

cat > postinst << 'EOF'
#!/bin/bash
# Make sure atproto is executable
chmod 755 /usr/local/bin/atproto
EOF
chmod 755 postinst

# Step 3: Build package
cd ..
dpkg-buildpackage

# Step 4: Test installation
sudo dpkg -i ../atproto_0.4.0_all.deb

# Step 5: Verify
atproto help

# Step 6: Test uninstallation
sudo dpkg -r atproto

# Step 7: Commit
git add debian/
git commit -m "build: add Debian packaging (deb)"
git push origin main
```

**Success Criteria**:
- ✅ debian/ directory created with config
- ✅ .deb package builds without errors
- ✅ Package installs cleanly
- ✅ atproto command works after install
- ✅ Uninstalls cleanly

**Next**: Move to Item 4

---

### ✅ ITEM 4: HOMEBREW FORMULA (macOS)
**Time**: 3-4 hours | **Difficulty**: ⭐⭐ | **Impact**: 🔥

```bash
# Step 1: Create tap repository (one-time)
# Go to GitHub, create repo: homebrew-atproto
git clone https://github.com/<YOU>/homebrew-atproto
cd homebrew-atproto

# Step 2: Create formula
mkdir -p Formula
cat > Formula/atproto.rb << 'EOF'
class AtBot < Formula
  desc "Bluesky/AT Protocol CLI tool"
  homepage "https://github.com/p3nGu1nZz/atproto"
  url "https://github.com/p3nGu1nZz/atproto/releases/download/v0.4.0/atproto-0.4.0.tar.gz"
  sha256 "abc123..."  # Get real sha256: shasum -a 256 file.tar.gz
  
  def install
    bin.install "atproto"
    man1.install "atproto.1" if File.exist?("atproto.1")
  end
  
  test do
    system "#{bin}/atproto", "help"
  end
end
EOF

# Step 3: Test formula
cd ..
brew install --build-from-source ./homebrew-atproto/Formula/atproto.rb

# Step 4: Verify
atproto help

# Step 5: Commit to tap repo
cd homebrew-atproto
git add Formula/
git commit -m "add: atproto formula"
git push origin main

# Step 6: Make tap discoverable
# GitHub Actions or manual setup for tap

# Step 7: Document in main atproto repo
# Add to README: brew tap p3nGu1nZz/atproto && brew install atproto
git commit -m "docs: add Homebrew installation instructions"
git push origin main
```

**Success Criteria**:
- ✅ homebrew-atproto tap created
- ✅ Formula installs cleanly
- ✅ atproto command works after install
- ✅ Formula can be found via GitHub
- ✅ Installation instructions in README

**Next**: Move to Item 5

---

### ✅ ITEM 5: PUBLISH DOCUMENTATION (Visibility)
**Time**: 2-3 hours | **Difficulty**: ⭐ | **Impact**: 🔥

```bash
# Step 1: Test build system
cd /mnt/c/Users/3nigma/source/repos/atproto
scripts/build-docs.sh

# Step 2: Verify output
ls -la docs/
# Should see HTML files, index.html, etc.

# Step 3: Open in browser
open docs/index.html

# Step 4: Check quality
# - Navigation working?
# - All pages linked?
# - Styling acceptable?
# - Search working?

# Step 5: Set up GitHub Pages
# GitHub repo settings → Pages → Source: docs/
# Wait 5 minutes for deploy

# Step 6: Verify online
# Visit: https://p3nGu1nZz.github.io/atproto/

# Step 7: Update README
# Add link to documentation site
git add docs/
git commit -m "docs: generate and publish documentation"
git push origin main
```

**Success Criteria**:
- ✅ docs/ directory populated with HTML
- ✅ Index page readable
- ✅ Links working
- ✅ GitHub Pages configured
- ✅ Site accessible online

---

## 📊 PROGRESS TRACKING

### Copy This Template
```
SESSION START: _______________________
FOCUS ITEM: (A) MCP Build / (B) JSON / (C) Debian / (D) Homebrew / (E) Docs

WORK LOG:
[ ] Task 1: _______________________________
[ ] Task 2: _______________________________
[ ] Task 3: _______________________________

BLOCKERS: None / (describe if any)

GIT COMMITS: (paste commit hashes)
___________________________________________

TESTING: ✅ All tests pass / ⚠️ (describe issues)

NEXT STEPS:
- ________________________
- ________________________

SESSION END: _______________________
TIME SPENT: _______________________
```

---

## 🎨 VISUAL PROGRESS

### Current Status
```
MCP Server       ████░░░░░░ 40% (code complete, not built)
JSON Output      ░░░░░░░░░░  0% (planned)
Debian Package   ░░░░░░░░░░  0% (planned)
Homebrew         ░░░░░░░░░░  0% (planned)
Documentation    ████░░░░░░ 40% (build system exists)
────────────────────────────────────────
v0.4.0 READY:    ████░░░░░░ 40% (target: 100%)
```

### After Your Work
```
MCP Server       ██████████100% ✅ DONE
JSON Output      ██████████100% ✅ DONE
Debian Package   ██████████100% ✅ DONE
Homebrew         ██████████100% ✅ DONE
Documentation    ██████████100% ✅ DONE
────────────────────────────────────────
v0.4.0 READY:    ██████████100% 🎉 RELEASE
```

---

## 🏁 WHEN ALL DONE

```bash
# Tag release
git tag -a v0.4.0 -m "Release: MCP deployment, JSON output, packaging"

# Push everything
git push origin main --tags

# Create GitHub release
# - Copy release notes from CHANGELOG
# - Attach .deb file
# - Mention npm package
# - Link to documentation

# Publish to npm
cd mcp-server
npm publish

# Announce
# - Twitter/Bluesky (via atproto!)
# - GitHub discussions
# - Community channels

# Celebrate! 🎉
atproto post "🎉 atproto v0.4.0 released! MCP server, JSON output, and packages! https://github.com/p3nGu1nZz/atproto"
```

---

## ⏰ TIME ESTIMATE CHART

```
Task              | Hours | When    | Priority
─────────────────────────────────────────────
MCP Build         |  1-2  | Today   | 🔥🔥🔥
JSON Output       |  6-8  | Week 2  | 🔥🔥🔥
Debian Package    |  4-6  | Week 3  | 🔥🔥
Homebrew Formula  |  3-4  | Week 3  | 🔥🔥
Documentation     |  2-3  | Week 4  | 🔥
─────────────────────────────────────────────
TOTAL TO v0.4.0   | 16-23 | 3-4wks  | CRITICAL
```

---

## 💡 PRO TIPS

1. **Do MCP first** - It's quick and enables everything else
2. **Test JSON output on real commands** - Use jq to validate
3. **Use automation for packages** - Script the build process
4. **Document as you go** - Makes releases easier
5. **Commit frequently** - One feature per commit
6. **Push to GitHub after each task** - Don't lose work

---

## 🆘 IF YOU GET STUCK

### MCP Server won't compile?
```bash
# Check Node.js version
node --version  # Should be 18+

# Try clean install
cd mcp-server
rm -rf node_modules package-lock.json
npm install
npm run build
```

### JSON output not parsing?
```bash
# Verify it's valid JSON
atproto whoami --format json | jq '.' 

# If fails, check for console.error() statements
# stdout must contain only valid JSON
```

### Package build fails?
```bash
# Check dpkg tools installed
dpkg-buildpackage --version

# Try minimal build
cd debian && cat control  # Verify format

# Check dependencies available
apt-cache search curl jq  # Verify listed deps exist
```

---

**Need more help?**
- See: PROJECT_REVIEW_2025-10-28.md (detailed analysis)
- See: PHASE2_ACTION_ITEMS.md (full checklist)
- See: WHATS_NEXT_SUMMARY.md (one-page overview)
- See: STYLE.md (code standards)

**Ready to start?** Pick Item 1 and go! 🚀

