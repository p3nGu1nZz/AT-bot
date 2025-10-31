import * as vscode from 'vscode';
import * as path from 'path';
import { AuthManager } from './auth-manager';

export class AtprotoMcpProvider implements vscode.McpServerDefinitionProvider {
    private _onDidChange = new vscode.EventEmitter<void>();
    onDidChangeMcpServerDefinitions = this._onDidChange.event;

    constructor(
        private context: vscode.ExtensionContext,
        private authManager: AuthManager
    ) {}

    async provideMcpServerDefinitions(): Promise<vscode.McpServerDefinition[]> {
        // Use integrated binary approach from the main project
        const workspaceFolder = vscode.workspace.workspaceFolders?.[0];
        let command = 'atproto';
        
        // If we're in development (extension is in workspace), use relative path
        if (workspaceFolder && 
            workspaceFolder.uri.fsPath.includes('atproto') &&
            workspaceFolder.uri.fsPath.includes('vscode-extension')) {
            // We're in the extension development workspace
            const projectRoot = path.dirname(workspaceFolder.uri.fsPath);
            command = path.join(projectRoot, 'bin', 'atproto');
        }

        return [{
            label: 'atproto (AT Protocol)',
            command: command,
            args: ['mcp-server'],
            env: {
                ATP_PDS: vscode.workspace.getConfiguration('atproto').get('pdsEndpoint', 'https://bsky.social'),
                MCP_LOG_LEVEL: vscode.workspace.getConfiguration('atproto').get('debugMode', false) ? 'debug' : 'info'
            }
        }];
    }

    async resolveMcpServerDefinition(
        server: vscode.McpServerDefinition,
        token: vscode.CancellationToken
    ): Promise<vscode.McpServerDefinition> {
        // Check if user is authenticated
        const isAuthenticated = await this.authManager.isAuthenticated();
        
        if (!isAuthenticated) {
            // Prompt for authentication
            const shouldLogin = await vscode.window.showInformationMessage(
                'atproto requires authentication to access Bluesky',
                { modal: true },
                'Login Now',
                'Cancel'
            );

            if (shouldLogin === 'Login Now') {
                await vscode.commands.executeCommand('atproto.login');
                
                // Check if authentication was successful
                const isNowAuthenticated = await this.authManager.isAuthenticated();
                if (!isNowAuthenticated) {
                    throw new Error('Authentication failed or was cancelled');
                }
            } else {
                throw new Error('Authentication required to use atproto MCP server');
            }
        }

        return server;
    }

    // Notify that server definitions may have changed
    refresh(): void {
        this._onDidChange.fire();
    }
}