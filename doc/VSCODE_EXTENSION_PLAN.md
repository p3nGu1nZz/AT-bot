# atproto VS Code Extension Plan

## Project Rebranding

**Old Name**: AT-bot  
**New Name**: atproto

### Rationale
- More professional and concise
- Aligns with AT Protocol branding
- Easier to type and remember
- Better marketplace searchability
- Follows naming convention of protocol tools (e.g., "docker", "kubernetes")

### Rebranding Checklist
- [ ] Rename GitHub repository: `AT-bot` → `atproto`
- [ ] Update repository description and topics
- [ ] Fresh checkout after rename
- [ ] Update all documentation references
- [ ] Update package names and identifiers
- [ ] Update CLI binary name: `at-bot` → `atproto`
- [ ] Update MCP server wrapper: `at-bot-mcp-server` → `atproto-mcp-server`
- [ ] Update configuration paths: `~/.config/at-bot` → `~/.config/atproto`
- [ ] Update all command names: `at-bot` → `atproto`
- [ ] Update extension name and marketplace listing
- [ ] Create redirect/deprecation notice for old name

## Overview

Create a VS Code extension that provides seamless AT Protocol/Bluesky integration through:
1. **Native MCP Server** - Built-in MCP server using VS Code's `McpServerDefinitionProvider` API
2. **Optional CLI** - Install the `atproto` CLI tool for terminal usage
3. **Automatic Bootstrap** - No manual configuration or dependency installation required

This approach follows the pattern of successful extensions like markitdown and Azure MCP Server.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│            atproto VS Code Extension                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Extension Host (TypeScript)                             │
│     ├── McpServerDefinitionProvider (VS Code API)          │
│     ├── Server Lifecycle Manager                           │
│     ├── Configuration UI                                    │
│     └── CLI Installation Manager (Optional)                │
│                                                             │
│  2. Bundled MCP Server (dist/)                             │
│     ├── AT Protocol Tools (31 tools)                       │
│     ├── Shell Executor (for atproto CLI bridge)           │
│     └── Session Manager                                     │
│                                                             │
│  3. Optional: CLI Tools                                     │
│     └── Install script for atproto command                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Benefits Over Manual Installation

### Current Manual Approach (Complex)
```bash
# Clone repo
git clone https://github.com/p3nGu1nZz/atproto.git
cd atproto

# Install CLI
sudo ./install.sh

# Install MCP server
cd mcp-server
npm install
npm run build

# Configure VS Code
# Edit .vscode/settings.json manually
# Add mcpServers configuration
# Reload VS Code
```

### VS Code Extension Approach (Simple)
```bash
# From VS Code
1. Install extension from marketplace
2. Extension auto-configures itself
3. Start using @atproto in Copilot chat
```

## Extension Structure

```
vscode-extension/
├── package.json                 # Extension manifest
├── tsconfig.json               # TypeScript config
├── .vscodeignore              # Files to exclude from package
├── src/
│   ├── extension.ts           # Extension entry point
│   ├── mcp-provider.ts        # McpServerDefinitionProvider implementation
│   ├── server-manager.ts      # MCP server lifecycle
│   ├── cli-installer.ts       # Optional CLI installation
│   └── config-manager.ts      # Configuration handling
├── mcp-server/                # Bundled MCP server (from existing code)
│   ├── dist/                  # Pre-compiled MCP server
│   └── package.json
└── README.md
```

## Implementation Steps

### Phase 1: Basic Extension (1-2 days)
- [ ] Create extension scaffolding with `yo code`
- [ ] Bundle existing MCP server into extension
- [ ] Implement `McpServerDefinitionProvider`
- [ ] Register with `lm.registerMcpServerDefinitionProvider`
- [ ] Test basic tool discovery in Copilot

### Phase 2: Authentication & Configuration (1 day)
- [ ] Add authentication flow (Bluesky login)
- [ ] Store credentials securely using VS Code SecretStorage API
- [ ] Create configuration UI for PDS endpoint
- [ ] Add status bar item showing auth status

### Phase 3: Enhanced Features (1-2 days)
- [ ] Add command palette commands (`AT-bot: Login`, `AT-bot: Post`, etc.)
- [ ] Implement webview for rich authentication UI
- [ ] Add notification system for errors/success
- [ ] Create quick actions (post from editor selection, etc.)

### Phase 4: CLI Integration (Optional, 1 day)
- [ ] Add CLI installer command
- [ ] Download and install at-bot binary
- [ ] Integrate terminal commands
- [ ] Add PATH configuration helper

### Phase 5: Publishing (1 day)
- [ ] Create extension icon and branding
- [ ] Write comprehensive README
- [ ] Package extension as VSIX
- [ ] Publish to VS Code Marketplace
- [ ] Create GitHub release

## Extension Manifest (package.json)

```json
{
  "name": "atproto",
  "displayName": "atproto: AT Protocol & Bluesky",
  "description": "AT Protocol/Bluesky integration for AI agents via MCP",
  "version": "0.1.0",
  "publisher": "p3ngu1nzz",
  "engines": {
    "vscode": "^1.96.0"
  },
  "categories": [
    "AI",
    "Chat"
  ],
  "keywords": [
    "atproto",
    "at protocol",
    "bluesky",
    "mcp",
    "model context protocol",
    "ai",
    "copilot",
    "social media"
  ],
  "activationEvents": [
    "onStartupFinished"
  ],
  "main": "./dist/extension.js",
  "contributes": {
    "mcpServerDefinitionProviders": [
      {
        "id": "atproto.mcp-server",
        "label": "atproto (AT Protocol)"
      }
    ],
    "commands": [
      {
        "command": "atproto.login",
        "title": "Login to Bluesky",
        "category": "atproto"
      },
      {
        "command": "atproto.logout",
        "title": "Logout",
        "category": "atproto"
      },
      {
        "command": "atproto.post",
        "title": "Create Post",
        "category": "atproto"
      },
      {
        "command": "atproto.installCli",
        "title": "Install CLI Tool",
        "category": "atproto"
      }
    ],
    "configuration": {
      "title": "atproto",
      "properties": {
        "atproto.pdsEndpoint": {
          "type": "string",
          "default": "https://bsky.social",
          "description": "AT Protocol PDS endpoint"
        },
        "atproto.autoLogin": {
          "type": "boolean",
          "default": true,
          "description": "Automatically login on startup"
        }
      }
    }
  },
  "scripts": {
    "vscode:prepublish": "npm run compile",
    "compile": "tsc -p ./",
    "watch": "tsc -watch -p ./",
    "package": "vsce package"
  },
  "devDependencies": {
    "@types/node": "^20.x",
    "@types/vscode": "^1.96.0",
    "typescript": "^5.3.0",
    "@vscode/vsce": "^2.22.0"
  }
}
```

## Key Implementation: McpServerDefinitionProvider

```typescript
// src/mcp-provider.ts
import * as vscode from 'vscode';
import * as path from 'path';

export class AtprotoMcpProvider implements vscode.McpServerDefinitionProvider {
    private _onDidChange = new vscode.EventEmitter<void>();
    onDidChangeMcpServerDefinitions = this._onDidChange.event;

    constructor(private context: vscode.ExtensionContext) {}

    async provideMcpServerDefinitions(): Promise<vscode.McpServerDefinition[]> {
        // Path to bundled MCP server in extension
        const serverPath = path.join(
            this.context.extensionPath,
            'mcp-server',
            'dist',
            'index.js'
        );

        return [{
            id: 'atproto',
            name: 'atproto (AT Protocol)',
            command: 'node',
            args: [serverPath],
            env: {
                ATP_PDS: vscode.workspace.getConfiguration('atproto').get('pdsEndpoint', 'https://bsky.social')
            }
        }];
    }

    async resolveMcpServerDefinition(
        server: vscode.McpServerDefinition,
        token: vscode.CancellationToken
    ): Promise<vscode.McpServerDefinition> {
        // Check if user is authenticated
        const credentials = await this.context.secrets.get('atproto.credentials');
        
        if (!credentials) {
            // Prompt for authentication
            const shouldLogin = await vscode.window.showInformationMessage(
                'atproto requires authentication to access Bluesky',
                'Login Now',
                'Cancel'
            );

            if (shouldLogin === 'Login Now') {
                await vscode.commands.executeCommand('atproto.login');
            } else {
                throw new Error('Authentication required');
            }
        }

        return server;
    }
}
```

## Extension Activation

```typescript
// src/extension.ts
import * as vscode from 'vscode';
import { AtprotoMcpProvider } from './mcp-provider';

export function activate(context: vscode.ExtensionContext) {
    console.log('atproto extension is now active');

    // Register MCP server provider
    const mcpProvider = new AtprotoMcpProvider(context);
    context.subscriptions.push(
        vscode.lm.registerMcpServerDefinitionProvider(
            'atproto.mcp-server',
            mcpProvider
        )
    );

    // Register commands
    context.subscriptions.push(
        vscode.commands.registerCommand('atproto.login', async () => {
            // Show authentication webview
            // Store credentials in SecretStorage
        })
    );

    // Add status bar item
    const statusBar = vscode.window.createStatusBarItem(
        vscode.StatusBarAlignment.Right,
        100
    );
    statusBar.text = '$(at-sign) atproto';
    statusBar.command = 'atproto.login';
    statusBar.show();
    context.subscriptions.push(statusBar);
}

export function deactivate() {}
```

## User Experience Flow

### First-Time User
1. Install extension from marketplace
2. Extension activates automatically
3. When user tries to use atproto in Copilot:
   - Extension prompts for Bluesky login
   - User enters handle + app password in webview
   - Credentials stored securely
   - MCP server starts automatically
4. User can now use all 31 atproto tools in Copilot

### Existing User
1. Install extension
2. Extension auto-detects existing `~/.config/atproto/session.json`
3. MCP server starts immediately
4. Ready to use in Copilot

## Comparison: Manual vs Extension

| Feature | Manual Install | VS Code Extension |
|---------|---------------|-------------------|
| Installation | 6+ steps, terminal commands | 1 click in VS Code |
| Configuration | Manual JSON editing | Automatic |
| Dependencies | Node.js, npm, git | None (bundled) |
| Updates | Manual pull + rebuild | Auto-update from marketplace |
| Error handling | Manual troubleshooting | Built-in error UI |
| Authentication | CLI commands | Integrated webview |
| Discoverability | GitHub search | VS Code marketplace search |
| Cross-platform | POSIX systems only | Windows/Mac/Linux via extension |

## Distribution Strategy

### Open Beta (Week 1-2)
- Release as pre-release version on marketplace
- Share with atproto community for testing
- Gather feedback on GitHub issues

### Stable Release (Week 3-4)
- Polish based on feedback
- Create promotional materials (GIFs, screenshots)
- Submit to VS Code marketplace
- Announce on Bluesky using atproto itself! 🎉

### Long-term
- GitHub Copilot official extension catalog
- VS Code "Featured" extensions
- Integration with other AI tools (Claude Desktop, etc.)

## Next Steps

1. **Rebranding**: Rename GitHub repo to `atproto` and fresh checkout
2. **Decision Point**: Proceed with creating the VS Code extension
3. **Timeline**: Estimate 5-7 days for full implementation + testing
4. **Repo Structure**: Keep extension in same repo or separate `atproto-vscode` repo?
5. **Branding**: Create icon, logo, marketplace screenshots

## References

- [VS Code Extension API - MCP](https://code.visualstudio.com/api/references/vscode-api#lm.registerMcpServerDefinitionProvider)
- [markitdown-vscode](https://github.com/BioInfo/vscode-markitdown) - Similar architecture
- [Azure MCP Server](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azure-mcp-server) - Microsoft's implementation
- [VS Code Extension Samples](https://github.com/microsoft/vscode-extension-samples)
