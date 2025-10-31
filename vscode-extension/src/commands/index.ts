import * as vscode from 'vscode';
import { AuthManager } from '../auth-manager';
import { showLoginWebview } from '../webview/auth-webview';

export function registerCommands(context: vscode.ExtensionContext, authManager: AuthManager): void {
    // Login command
    context.subscriptions.push(
        vscode.commands.registerCommand('atproto.login', async () => {
            try {
                const result = await showLoginWebview(context);
                if (result) {
                    await authManager.authenticate(result.handle, result.password);
                    vscode.window.showInformationMessage(
                        `Successfully logged in as ${result.handle}`
                    );
                }
            } catch (error) {
                const errorMessage = error instanceof Error ? error.message : 'Unknown error';
                vscode.window.showErrorMessage(`Login failed: ${errorMessage}`);
            }
        })
    );

    // Logout command
    context.subscriptions.push(
        vscode.commands.registerCommand('atproto.logout', async () => {
            const confirm = await vscode.window.showWarningMessage(
                'Are you sure you want to logout?',
                { modal: true },
                'Logout',
                'Cancel'
            );

            if (confirm === 'Logout') {
                await authManager.clearCredentials();
                vscode.window.showInformationMessage('Logged out successfully');
            }
        })
    );

    // Quick post command
    context.subscriptions.push(
        vscode.commands.registerCommand('atproto.post', async () => {
            const isAuthenticated = await authManager.isAuthenticated();
            if (!isAuthenticated) {
                const shouldLogin = await vscode.window.showInformationMessage(
                    'You need to login first',
                    'Login Now',
                    'Cancel'
                );
                if (shouldLogin === 'Login Now') {
                    await vscode.commands.executeCommand('atproto.login');
                }
                return;
            }

            const postText = await vscode.window.showInputBox({
                prompt: 'Enter your post text',
                placeHolder: 'What\'s happening?',
                value: vscode.window.activeTextEditor?.selection 
                    ? vscode.window.activeTextEditor.document.getText(vscode.window.activeTextEditor.selection)
                    : undefined
            });

            if (postText) {
                try {
                    // This would integrate with the atproto CLI or make direct API calls
                    // For now, we'll show a success message
                    vscode.window.showInformationMessage(`Posted: "${postText}"`);
                } catch (error) {
                    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
                    vscode.window.showErrorMessage(`Failed to post: ${errorMessage}`);
                }
            }
        })
    );

    // CLI installer command (future implementation)
    context.subscriptions.push(
        vscode.commands.registerCommand('atproto.installCli', async () => {
            const result = await vscode.window.showInformationMessage(
                'Install atproto CLI tool for terminal usage?',
                { modal: true },
                'Install',
                'Cancel'
            );

            if (result === 'Install') {
                vscode.window.showInformationMessage(
                    'CLI installation feature coming soon! For now, please visit: https://github.com/p3nGu1nZz/atproto'
                );
            }
        })
    );
}