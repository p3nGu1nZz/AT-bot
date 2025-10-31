# Project Rebranding: AT-bot → atproto

## Rationale

**Old Name**: AT-bot  
**New Name**: atproto

### Why Rebrand?
- ✅ More professional and concise
- ✅ Aligns with AT Protocol branding convention
- ✅ Easier to type and remember (no hyphen, no caps)
- ✅ Better marketplace searchability and SEO
- ✅ Follows naming pattern of successful protocol tools (docker, kubectl, etc.)
- ✅ Single word is more memorable and brandable
- ✅ "atproto" clearly indicates AT Protocol without redundant "bot" suffix

## GitHub Repository Changes

### Step 1: Rename Repository
- [ ] Navigate to GitHub repository settings
- [ ] Go to repository Settings → General → Repository name
- [ ] Change name from `AT-bot` to `atproto`
- [ ] GitHub will automatically set up redirect from old URL
- [ ] Update repository description to: "AT Protocol CLI and VS Code extension for Bluesky automation"
- [ ] Update repository topics: `at-protocol`, `bluesky`, `cli`, `mcp`, `vscode-extension`, `automation`

### Step 2: Update Repository Files
After renaming, GitHub provides these instructions:
```bash
# For existing local clones
git remote set-url origin git@github.com:p3nGu1nZz/atproto.git

# Or fresh checkout
git clone git@github.com:p3nGu1nZz/atproto.git
cd atproto
```

### Step 3: Archive Old References
- [ ] Add deprecation notice to old repo URL (if using redirect)
- [ ] Update any external links pointing to old repo name

## Code Changes Checklist

### Binary and Command Names
- [ ] Rename `bin/at-bot` → `bin/atproto`
- [ ] Rename `bin/at-bot-mcp-server` → `bin/atproto-mcp-server`
- [ ] Update shebang and comments in both files

### Configuration Paths
- [ ] Update config directory: `~/.config/at-bot` → `~/.config/atproto`
- [ ] Add migration logic to move old config to new location
- [ ] Update session file path in all references
- [ ] Update documentation with new paths

### Library Files
- [ ] Update `lib/atproto.sh`:
  - [ ] Change `CONFIG_DIR` path
  - [ ] Update all help text and messages
  - [ ] Update error messages
  - [ ] Change function documentation
- [ ] Update `lib/config.sh` with new paths
- [ ] Update `lib/doc.sh` references
- [ ] Update `lib/setup.sh` dependency checker

### Scripts
- [ ] Update `install.sh`:
  - [ ] Change installation messages
  - [ ] Update binary names
  - [ ] Update help text
- [ ] Update `uninstall.sh` with new paths
- [ ] Update `scripts/at-bot-completion.bash` → `scripts/atproto-completion.bash`
- [ ] Update `scripts/at-bot-completion.zsh` → `scripts/atproto-completion.zsh`
- [ ] Update completion script content with new command name

### Documentation Files (Root)
- [ ] `README.md`:
  - [ ] Update title: "atproto - AT Protocol CLI & VS Code Extension"
  - [ ] Change all command examples: `at-bot` → `atproto`
  - [ ] Update installation instructions
  - [ ] Update repository URLs
- [ ] `PLAN.md`:
  - [ ] Update project name throughout
  - [ ] Update vision and mission statements
  - [ ] Change all references to binary name
- [ ] `AGENTS.md`:
  - [ ] Update automation examples
  - [ ] Change command references
- [ ] `STYLE.md`:
  - [ ] Update example code with new names
  - [ ] Change file path references
- [ ] `TODO.md`:
  - [ ] Update all task descriptions
  - [ ] Change command references
- [ ] `CONTRIBUTING.md`:
  - [ ] Update repository URLs
  - [ ] Change example commands

### Documentation Files (doc/)
- [ ] `doc/QUICKSTART.md`
- [ ] `doc/CONFIGURATION.md`
- [ ] `doc/DEBUG_MODE.md`
- [ ] `doc/ENCRYPTION.md`
- [ ] `doc/TESTING.md`
- [ ] `doc/ARCHITECTURE.md`
- [ ] `doc/QUICKREF.md`
- [ ] `doc/EXAMPLES.md`
- [ ] `doc/FAQ.md`
- [ ] `doc/PACKAGING.md`

### Session Documentation (doc/sessions/)
- [ ] Update all session summaries with new name
- [ ] No need to change historical logs, just note the rename

### MCP Server
- [ ] `mcp-server/package.json`:
  - [ ] Change `name`: `"@p3ngu1nzz/atproto-mcp-server"`
  - [ ] Update `description`
  - [ ] Update repository URL
- [ ] `mcp-server/README.md`:
  - [ ] Update title and examples
  - [ ] Change binary references
- [ ] `mcp-server/docs/`:
  - [ ] Update all documentation with new names
  - [ ] Change example commands
- [ ] `mcp-server/src/index.ts`:
  - [ ] Update server name in registration
  - [ ] Change console log messages
- [ ] All tool files in `mcp-server/src/tools/`:
  - [ ] Update shell command calls: `at-bot` → `atproto`

### Test Files
- [ ] `tests/` - Update all test scripts:
  - [ ] Change command references
  - [ ] Update test descriptions
  - [ ] Fix any hardcoded paths

### Build System
- [ ] `Makefile`:
  - [ ] Update binary names
  - [ ] Change installation paths
  - [ ] Update help text
- [ ] `.vscode/settings.json`:
  - [ ] Update MCP server command path
  - [ ] Change configuration keys if needed

### Package Configuration
- [ ] `package.json` (root if exists)
- [ ] Update any npm scripts
- [ ] Change repository URLs

## Migration Support

### Backward Compatibility Script
Create a migration helper for existing users:

```bash
#!/bin/bash
# migrate-to-atproto.sh
# Helps users migrate from at-bot to atproto

OLD_CONFIG="$HOME/.config/at-bot"
NEW_CONFIG="$HOME/.config/atproto"

if [ -d "$OLD_CONFIG" ]; then
    echo "Found old at-bot configuration"
    echo "Migrating to atproto..."
    
    # Create new config directory
    mkdir -p "$NEW_CONFIG"
    
    # Copy session and config files
    if [ -f "$OLD_CONFIG/session.json" ]; then
        cp "$OLD_CONFIG/session.json" "$NEW_CONFIG/session.json"
        echo "✓ Migrated session"
    fi
    
    # Copy any other config files
    cp -r "$OLD_CONFIG"/* "$NEW_CONFIG/" 2>/dev/null
    
    echo ""
    echo "Migration complete!"
    echo "Old config preserved at: $OLD_CONFIG"
    echo "New config location: $NEW_CONFIG"
    echo ""
    echo "You can now use: atproto (instead of at-bot)"
fi
```

### Deprecation Notice
Add to old binary location (if keeping for transition):

```bash
#!/bin/bash
# Legacy at-bot wrapper (deprecated)

echo "⚠️  Warning: 'at-bot' has been renamed to 'atproto'" >&2
echo "   Please update your scripts and use 'atproto' instead" >&2
echo "" >&2

# Forward to new binary
exec atproto "$@"
```

## Communication Plan

### Announce Rebranding
- [ ] Create announcement post on Bluesky (using atproto! 🎉)
- [ ] Update GitHub repository description
- [ ] Add notice to README about rename
- [ ] Update any external documentation or blog posts
- [ ] Notify any existing users via GitHub discussion

### Transition Period (30 days)
- [ ] Keep redirect from old GitHub URL
- [ ] Maintain backward compatibility in CLI
- [ ] Document migration path clearly
- [ ] Provide migration script

### Post-Transition
- [ ] Remove backward compatibility shims
- [ ] Archive old references
- [ ] Focus on new branding

## VS Code Extension Branding

### Extension Package
- [ ] Extension ID: `p3ngu1nzz.atproto`
- [ ] Display Name: `atproto: AT Protocol & Bluesky`
- [ ] Description: "AT Protocol CLI and MCP server for Bluesky automation and AI agents"
- [ ] Publisher: `p3ngu1nzz`

### Extension Assets
- [ ] Create extension icon (128x128 PNG)
  - Use AT Protocol "at" symbol (ⓐ) or custom design
  - Purple/blue color scheme (matches Bluesky branding)
- [ ] Create marketplace banner
- [ ] Create promotional screenshots
- [ ] Create demo GIF/video

### Marketplace Keywords
- `atproto`
- `at-protocol`
- `bluesky`
- `mcp`
- `model-context-protocol`
- `copilot`
- `ai`
- `automation`
- `social-media`
- `cli`

## Verification Checklist

After completing the rebrand:

### Functionality Tests
- [ ] CLI commands work with new name
- [ ] Configuration files load from new location
- [ ] Session management works
- [ ] MCP server starts with new wrapper
- [ ] All tests pass: `make test`
- [ ] Installation works: `./install.sh`
- [ ] Completion scripts work with new name

### Documentation Tests
- [ ] All internal links work
- [ ] No broken references to old name
- [ ] Examples use correct command name
- [ ] Configuration paths are correct

### Repository Tests
- [ ] Old URL redirects to new repository
- [ ] GitHub Actions CI/CD still works
- [ ] Clone with new URL works
- [ ] Issues/PRs still accessible

## Timeline

### Immediate (Day 1)
1. Rename GitHub repository
2. Fresh checkout with new name
3. Update all binary and command names
4. Update configuration paths
5. Test basic functionality

### Short-term (Days 2-3)
1. Update all documentation
2. Update MCP server references
3. Create migration script
4. Test complete workflow

### Medium-term (Week 1)
1. Announce rebranding
2. Update external references
3. Begin VS Code extension development
4. Create new branding assets

### Long-term (Month 1+)
1. Phase out backward compatibility
2. Focus on new branding
3. Publish VS Code extension
4. Build community around new name

## Notes

- GitHub automatically creates redirects from old repository URL
- Existing git clones can update remote URL: `git remote set-url origin <new-url>`
- Consider keeping `at-bot` as an alias during transition period
- The MCP server name in VS Code can be "atproto" for consistency

---

*Document created: October 31, 2025*  
*Status: Planning Phase*
