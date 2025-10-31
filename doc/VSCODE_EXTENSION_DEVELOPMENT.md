# VS Code Extension Development Best Practices

This document outlines best practices for developing the atproto VS Code extension, incorporating official VS Code API guidance and extension development patterns.

## Overview

The atproto VS Code extension provides seamless AT Protocol/Bluesky integration through:
- **Native MCP Server** - Built-in MCP server using VS Code's `McpServerDefinitionProvider` API
- **Zero Configuration** - Automatic setup without manual dependency installation
- **Secure Authentication** - Integrated Bluesky login with VS Code SecretStorage API
- **Command Integration** - Rich command palette and status bar integration

## Development Environment Setup

### Prerequisites

```bash
# Install Node.js 18+ and npm
node --version  # Should be 18.0.0 or higher
npm --version

# Install VS Code Extension development tools
npm install -g @vscode/vsce
npm install -g yo generator-code
```

### Project Structure

Following VS Code extension anatomy best practices:

```
vscode-extension/
├── package.json              # Extension manifest
├── tsconfig.json            # TypeScript configuration
├── .vscodeignore           # Files to exclude from package
├── .gitignore              # Git ignore patterns
├── README.md               # Extension documentation
├── CHANGELOG.md            # Version history
├── src/
│   ├── extension.ts        # Main extension entry point
│   ├── mcp-provider.ts     # McpServerDefinitionProvider implementation
│   ├── server-manager.ts   # MCP server lifecycle management
│   ├── auth-manager.ts     # Authentication and credential management
│   ├── config-manager.ts   # Configuration handling
│   ├── webview/            # Authentication webview components
│   └── commands/           # Command implementations
├── media/                  # Icons, images, promotional materials
├── mcp-server/            # Bundled MCP server (from existing code)
│   └── dist/              # Pre-compiled MCP server
└── test/                  # Extension tests
    └── suite/             # Test suites
```

## VS Code API Best Practices

### Extension Activation

```typescript
// src/extension.ts
import * as vscode from 'vscode';

export function activate(context: vscode.ExtensionContext) {
    // Use activation events wisely - prefer onStartupFinished over onLanguage
    console.log('atproto extension is now active');

    // Register all providers and commands
    registerMcpProvider(context);
    registerCommands(context);
    registerStatusBar(context);
}

export function deactivate() {
    // Clean up resources
}
```

### MCP Server Integration

```typescript
// src/mcp-provider.ts
import * as vscode from 'vscode';

export class AtprotoMcpProvider implements vscode.McpServerDefinitionProvider {
    private _onDidChange = new vscode.EventEmitter<void>();
    onDidChangeMcpServerDefinitions = this._onDidChange.event;

    constructor(private context: vscode.ExtensionContext) {}

    async provideMcpServerDefinitions(): Promise<vscode.McpServerDefinition[]> {
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
            env: this.getEnvironmentVariables()
        }];
    }

    async resolveMcpServerDefinition(
        server: vscode.McpServerDefinition,
        token: vscode.CancellationToken
    ): Promise<vscode.McpServerDefinition> {
        // Check authentication before starting server
        await this.ensureAuthenticated();
        return server;
    }
}
```

### Secure Credential Storage

```typescript
// src/auth-manager.ts
export class AuthManager {
    private static readonly CREDENTIALS_KEY = 'atproto.credentials';

    constructor(private secrets: vscode.SecretStorage) {}

    async storeCredentials(handle: string, accessToken: string): Promise<void> {
        const credentials = {
            handle,
            accessToken,
            createdAt: Date.now()
        };
        
        await this.secrets.store(
            AuthManager.CREDENTIALS_KEY,
            JSON.stringify(credentials)
        );
    }

    async getCredentials(): Promise<AuthCredentials | null> {
        const stored = await this.secrets.get(AuthManager.CREDENTIALS_KEY);
        return stored ? JSON.parse(stored) : null;
    }

    async clearCredentials(): Promise<void> {
        await this.secrets.delete(AuthManager.CREDENTIALS_KEY);
    }
}
```

### Command Registration

```typescript
// src/commands/index.ts
export function registerCommands(context: vscode.ExtensionContext): void {
    const authManager = new AuthManager(context.secrets);

    // Login command
    context.subscriptions.push(
        vscode.commands.registerCommand('atproto.login', async () => {
            try {
                const credentials = await showLoginWebview(context);
                await authManager.storeCredentials(credentials.handle, credentials.token);
                vscode.window.showInformationMessage('Successfully logged in to Bluesky');
            } catch (error) {
                vscode.window.showErrorMessage(`Login failed: ${error.message}`);
            }
        })
    );

    // Post command
    context.subscriptions.push(
        vscode.commands.registerCommand('atproto.post', async () => {
            const text = await vscode.window.showInputBox({
                prompt: 'Enter your post content',
                placeHolder: 'What\'s happening?'
            });

            if (text) {
                // Use MCP server to post
                await postToBluesky(text);
            }
        })
    );
}
```

### Webview Authentication

```typescript
// src/webview/auth-webview.ts
export async function showLoginWebview(
    context: vscode.ExtensionContext
): Promise<{handle: string, token: string}> {
    const panel = vscode.window.createWebviewPanel(
        'atprotoLogin',
        'Login to Bluesky',
        vscode.ViewColumn.One,
        {
            enableScripts: true,
            retainContextWhenHidden: true
        }
    );

    panel.webview.html = getLoginHtml();

    return new Promise((resolve, reject) => {
        panel.webview.onDidReceiveMessage(async (message) => {
            switch (message.command) {
                case 'login':
                    try {
                        // Authenticate with Bluesky
                        const result = await authenticateWithBluesky(
                            message.handle,
                            message.password
                        );
                        panel.dispose();
                        resolve(result);
                    } catch (error) {
                        panel.webview.postMessage({
                            command: 'error',
                            message: error.message
                        });
                    }
                    break;
            }
        });
    });
}
```

### Configuration Management

```typescript
// src/config-manager.ts
export class ConfigManager {
    static getPdsEndpoint(): string {
        return vscode.workspace.getConfiguration('atproto')
            .get('pdsEndpoint', 'https://bsky.social');
    }

    static getAutoLogin(): boolean {
        return vscode.workspace.getConfiguration('atproto')
            .get('autoLogin', true);
    }

    static async updateConfiguration(key: string, value: any): Promise<void> {
        await vscode.workspace.getConfiguration('atproto')
            .update(key, value, vscode.ConfigurationTarget.Global);
    }
}
```

## Extension Manifest Best Practices

### package.json Structure

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
    "Chat",
    "Other"
  ],
  "keywords": [
    "atproto",
    "at-protocol",
    "bluesky",
    "mcp",
    "model-context-protocol",
    "ai",
    "copilot",
    "social-media"
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
        "category": "atproto",
        "icon": "$(sign-in)"
      },
      {
        "command": "atproto.logout",
        "title": "Logout",
        "category": "atproto",
        "icon": "$(sign-out)"
      },
      {
        "command": "atproto.post",
        "title": "Create Post",
        "category": "atproto",
        "icon": "$(edit)"
      }
    ],
    "configuration": {
      "title": "atproto",
      "properties": {
        "atproto.pdsEndpoint": {
          "type": "string",
          "default": "https://bsky.social",
          "description": "AT Protocol PDS endpoint",
          "pattern": "^https?://.+"
        },
        "atproto.autoLogin": {
          "type": "boolean",
          "default": true,
          "description": "Automatically login on startup"
        }
      }
    }
  }
}
```

### Activation Events Best Practices

- Use `onStartupFinished` instead of `*` for better performance
- Avoid heavy operations in activation
- Prefer lazy loading of components
- Register providers immediately but defer heavy initialization

## Development Workflow

### 1. Initial Setup

```bash
# Create extension scaffold
mkdir vscode-extension
cd vscode-extension
yo code

# Choose:
# - New Extension (TypeScript)
# - Name: atproto
# - Identifier: atproto
# - Description: AT Protocol/Bluesky integration for AI agents via MCP
# - Publisher: p3ngu1nzz
```

### 2. Development Script

Create `scripts/extension-dev.sh`:

```bash
#!/bin/bash
# Extension development automation script

set -e

EXTENSION_DIR="vscode-extension"
MCP_SERVER_DIR="mcp-server"

case "$1" in
    "init")
        echo "Initializing VS Code extension development..."
        cd "$EXTENSION_DIR"
        npm install
        ;;
    "build")
        echo "Building extension..."
        cd "$EXTENSION_DIR"
        npm run build
        ;;
    "watch")
        echo "Starting watch mode..."
        cd "$EXTENSION_DIR"
        npm run watch &
        ;;
    "test")
        echo "Running extension tests..."
        cd "$EXTENSION_DIR"
        npm test
        ;;
    "package")
        echo "Packaging extension..."
        cd "$EXTENSION_DIR"
        vsce package
        ;;
    "install")
        echo "Installing extension locally..."
        cd "$EXTENSION_DIR"
        code --install-extension *.vsix
        ;;
    "publish")
        echo "Publishing to marketplace..."
        cd "$EXTENSION_DIR"
        vsce publish
        ;;
    *)
        echo "Usage: $0 {init|build|watch|test|package|install|publish}"
        exit 1
        ;;
esac
```

### 3. Testing Strategy

```typescript
// test/suite/extension.test.ts
import * as assert from 'assert';
import * as vscode from 'vscode';

suite('Extension Test Suite', () => {
    vscode.window.showInformationMessage('Start all tests.');

    test('Extension should be present', () => {
        assert.ok(vscode.extensions.getExtension('p3ngu1nzz.atproto'));
    });

    test('Commands should be registered', async () => {
        const commands = await vscode.commands.getCommands();
        assert.ok(commands.includes('atproto.login'));
        assert.ok(commands.includes('atproto.post'));
    });

    test('MCP provider should be registered', () => {
        // Test MCP server definition provider registration
    });
});
```

### 4. CI/CD Integration

```yaml
# .github/workflows/extension.yml
name: Extension CI/CD

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - name: Install dependencies
        run: |
          cd vscode-extension
          npm install
      - name: Run tests
        run: |
          cd vscode-extension
          npm test
      - name: Package extension
        run: |
          cd vscode-extension
          npm run package
```

## Performance Best Practices

### 1. Lazy Loading

```typescript
// Defer heavy imports until needed
async function loadMcpServer() {
    const { McpServer } = await import('./mcp-server/dist/index.js');
    return new McpServer();
}
```

### 2. Resource Management

```typescript
// Proper disposal of resources
export function deactivate() {
    // Dispose of all subscriptions
    context.subscriptions.forEach(subscription => {
        subscription.dispose();
    });
}
```

### 3. Caching

```typescript
// Cache expensive operations
class AtprotoExtension {
    private _mcpServerCache?: McpServer;

    async getMcpServer(): Promise<McpServer> {
        if (!this._mcpServerCache) {
            this._mcpServerCache = await this.createMcpServer();
        }
        return this._mcpServerCache;
    }
}
```

## Error Handling

### 1. User-Friendly Errors

```typescript
try {
    await authenticateUser(credentials);
} catch (error) {
    if (error.code === 'INVALID_CREDENTIALS') {
        vscode.window.showErrorMessage(
            'Invalid credentials. Please check your handle and app password.'
        );
    } else {
        vscode.window.showErrorMessage(
            `Authentication failed: ${error.message}`
        );
    }
}
```

### 2. Logging

```typescript
// Use VS Code's output channel for logging
const outputChannel = vscode.window.createOutputChannel('atproto');

function log(message: string): void {
    outputChannel.appendLine(`[${new Date().toISOString()}] ${message}`);
}
```

## Publishing Strategy

### 1. Pre-release Testing

```bash
# Package for testing
vsce package --pre-release

# Test installation
code --install-extension atproto-0.1.0.vsix
```

### 2. Marketplace Publication

```bash
# First time setup
vsce create-publisher p3ngu1nzz

# Publish stable version
vsce publish

# Publish pre-release
vsce publish --pre-release
```

### 3. Update Strategy

1. **Semantic Versioning**: Follow semver (major.minor.patch)
2. **Changelog**: Maintain CHANGELOG.md with all changes
3. **Migration**: Handle breaking changes gracefully
4. **Testing**: Thorough testing before each release

## Security Considerations

### 1. Credential Security

- Use VS Code SecretStorage API exclusively
- Never log or expose credentials
- Implement token refresh logic
- Support session timeout

### 2. Content Security Policy

```html
<!-- In webview HTML -->
<meta http-equiv="Content-Security-Policy" 
      content="default-src 'none'; script-src 'nonce-${nonce}'; style-src 'unsafe-inline';">
```

### 3. Input Validation

```typescript
function validateHandle(handle: string): boolean {
    return /^[a-zA-Z0-9][a-zA-Z0-9.-]*[a-zA-Z0-9]$/.test(handle) && 
           handle.length <= 253;
}
```

## References

- [VS Code Extension API](https://code.visualstudio.com/api)
- [Your First Extension](https://code.visualstudio.com/api/get-started/your-first-extension)
- [Extension Anatomy](https://code.visualstudio.com/api/get-started/extension-anatomy)
- [Extension Guidelines](https://code.visualstudio.com/api/references/extension-guidelines)
- [Publishing Extensions](https://code.visualstudio.com/api/working-with-extensions/publishing-extension)

---

*Document created: October 31, 2025*  
*Last updated: October 31, 2025*