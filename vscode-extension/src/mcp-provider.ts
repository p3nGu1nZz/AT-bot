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
        // Find the atproto binary
        let command = await this.findAtprotoCommand();

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

    private async findAtprotoCommand(): Promise<string> {
        const { exec } = require('child_process');
        const { promisify } = require('util');
        const execPromise = promisify(exec);
        
        // Try multiple locations in order of preference
        const locations = [
            '/usr/local/bin/atproto',           // Standard installation
            '/usr/bin/atproto',                 // Alternative installation
            process.env.HOME + '/.local/bin/atproto',  // User installation
        ];

        // Check if we're in the development workspace
        const workspaceFolder = vscode.workspace.workspaceFolders?.[0];
        if (workspaceFolder) {
            const wsPath = workspaceFolder.uri.fsPath;
            // If workspace is the atproto project, use the bin/ directory
            if (wsPath.includes('atproto')) {
                const devPath = path.join(wsPath, 'bin', 'atproto');
                locations.unshift(devPath);  // Highest priority
            }
        }

        // Try each location
        for (const location of locations) {
            try {
                const fs = require('fs');
                if (fs.existsSync(location)) {
                    return location;
                }
            } catch (error) {
                // Continue to next location
            }
        }

        // Fallback: try to find in PATH
        try {
            const { stdout } = await execPromise('which atproto');
            const pathLocation = stdout.trim();
            if (pathLocation) {
                return pathLocation;
            }
        } catch (error) {
            // Not in PATH
        }

        // Last resort: assume it's in PATH and let the system find it
        return 'atproto';
    }

    async resolveMcpServerDefinition(
        server: vscode.McpServerDefinition,
        token: vscode.CancellationToken
    ): Promise<vscode.McpServerDefinition> {
        // Check if user is authenticated (only check once per resolve)
        const isAuthenticated = await this.authManager.isAuthenticated();
        
        if (!isAuthenticated) {
            // Show a non-blocking notification with action
            const action = await vscode.window.showWarningMessage(
                'atproto: Please login to Bluesky to use MCP tools',
                'Login Now'
            );

            if (action === 'Login Now') {
                await vscode.commands.executeCommand('atproto.login');
            }
            
            // Don't throw - let the MCP server start anyway
            // Individual tool calls will fail with auth errors if not logged in
        }

        return server;
    }

    // Notify that server definitions may have changed
    refresh(): void {
        this._onDidChange.fire();
    }
}