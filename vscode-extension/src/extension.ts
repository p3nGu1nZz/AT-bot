import * as vscode from 'vscode';
import { AtprotoMcpProvider } from './mcp-provider';
import { AuthManager } from './auth-manager';
import { registerCommands } from './commands';

export function activate(context: vscode.ExtensionContext) {
    console.log('atproto extension is now active');

    // Initialize authentication manager
    const authManager = new AuthManager(context.secrets);

    // Register MCP server provider
    const mcpProvider = new AtprotoMcpProvider(context, authManager);
    context.subscriptions.push(
        vscode.lm.registerMcpServerDefinitionProvider(
            'atproto.mcp-server',
            mcpProvider
        )
    );

    // Register commands
    registerCommands(context, authManager);

    // Add status bar item
    const statusBar = vscode.window.createStatusBarItem(
        vscode.StatusBarAlignment.Right,
        100
    );
    statusBar.text = '$(at-sign) atproto';
    statusBar.command = 'atproto.login';
    statusBar.tooltip = 'atproto: Click to login to Bluesky';
    statusBar.show();
    context.subscriptions.push(statusBar);

    // Update status bar based on authentication state
    authManager.onAuthStateChanged(async (isAuthenticated) => {
        if (isAuthenticated) {
            const credentials = await authManager.getCredentials();
            statusBar.text = `$(at-sign) ${credentials?.handle || 'atproto'}`;
            statusBar.tooltip = 'atproto: Authenticated with Bluesky';
            statusBar.command = 'atproto.post';
        } else {
            statusBar.text = '$(at-sign) atproto';
            statusBar.tooltip = 'atproto: Click to login to Bluesky';
            statusBar.command = 'atproto.login';
        }
    });

    // Check initial authentication state
    authManager.checkAuthState();
}

export function deactivate() {
    // Clean up resources
    console.log('atproto extension deactivated');
}