import * as vscode from 'vscode';

export interface LoginResult {
    handle: string;
    password: string;
}

export async function showLoginWebview(context: vscode.ExtensionContext): Promise<LoginResult | null> {
    return new Promise((resolve, reject) => {
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

        // Handle messages from the webview
        panel.webview.onDidReceiveMessage(
            async (message) => {
                switch (message.command) {
                    case 'login':
                        try {
                            // Validate input
                            if (!message.handle || !message.password) {
                                panel.webview.postMessage({
                                    command: 'error',
                                    message: 'Please provide both handle and password'
                                });
                                return;
                            }

                            // Close the panel
                            panel.dispose();
                            
                            // Return the credentials
                            resolve({
                                handle: message.handle,
                                password: message.password
                            });
                        } catch (error) {
                            panel.webview.postMessage({
                                command: 'error',
                                message: error instanceof Error ? error.message : 'Login failed'
                            });
                        }
                        break;
                    case 'cancel':
                        panel.dispose();
                        resolve(null);
                        break;
                }
            },
            undefined,
            context.subscriptions
        );

        // Handle panel disposal
        panel.onDidDispose(
            () => {
                resolve(null);
            },
            null,
            context.subscriptions
        );
    });
}

function getLoginHtml(): string {
    return `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login to Bluesky</title>
    <style>
        body {
            font-family: var(--vscode-font-family);
            color: var(--vscode-foreground);
            background-color: var(--vscode-editor-background);
            padding: 20px;
        }
        
        .container {
            max-width: 400px;
            margin: 0 auto;
        }
        
        .header {
            text-align: center;
            margin-bottom: 30px;
        }
        
        .logo {
            font-size: 48px;
            margin-bottom: 10px;
        }
        
        h1 {
            color: var(--vscode-titleBar-activeForeground);
            margin-bottom: 10px;
        }
        
        .subtitle {
            color: var(--vscode-descriptionForeground);
            font-size: 14px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: 500;
        }
        
        input[type="text"], input[type="password"] {
            width: 100%;
            padding: 10px;
            border: 1px solid var(--vscode-input-border);
            background-color: var(--vscode-input-background);
            color: var(--vscode-input-foreground);
            border-radius: 4px;
            font-size: 14px;
            box-sizing: border-box;
        }
        
        input[type="text"]:focus, input[type="password"]:focus {
            outline: none;
            border-color: var(--vscode-focusBorder);
        }
        
        .button-group {
            display: flex;
            gap: 10px;
            margin-top: 30px;
        }
        
        button {
            flex: 1;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            font-size: 14px;
            cursor: pointer;
            font-weight: 500;
        }
        
        .primary-button {
            background-color: var(--vscode-button-background);
            color: var(--vscode-button-foreground);
        }
        
        .primary-button:hover {
            background-color: var(--vscode-button-hoverBackground);
        }
        
        .primary-button:disabled {
            background-color: var(--vscode-button-secondaryBackground);
            cursor: not-allowed;
        }
        
        .secondary-button {
            background-color: var(--vscode-button-secondaryBackground);
            color: var(--vscode-button-secondaryForeground);
        }
        
        .secondary-button:hover {
            background-color: var(--vscode-button-secondaryHoverBackground);
        }
        
        .error {
            color: var(--vscode-errorForeground);
            background-color: var(--vscode-inputValidation-errorBackground);
            border: 1px solid var(--vscode-inputValidation-errorBorder);
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 20px;
        }
        
        .info {
            background-color: var(--vscode-textCodeBlock-background);
            border-left: 3px solid var(--vscode-textLink-foreground);
            padding: 10px;
            margin-bottom: 20px;
            font-size: 13px;
        }
        
        .loading {
            display: none;
            text-align: center;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">@</div>
            <h1>Login to Bluesky</h1>
            <div class="subtitle">Connect your AT Protocol account</div>
        </div>
        
        <div class="info">
            <strong>Tip:</strong> Use an App Password instead of your main password for better security. 
            Create one at <strong>Settings → App Passwords</strong> in Bluesky.
        </div>
        
        <div id="error-message" class="error" style="display: none;"></div>
        
        <form id="login-form">
            <div class="form-group">
                <label for="handle">Handle or Email</label>
                <input type="text" id="handle" name="handle" placeholder="yourname.bsky.social" required>
            </div>
            
            <div class="form-group">
                <label for="password">Password (or App Password)</label>
                <input type="password" id="password" name="password" placeholder="Your password" required>
            </div>
            
            <div class="button-group">
                <button type="button" class="secondary-button" id="cancel-button">Cancel</button>
                <button type="submit" class="primary-button" id="login-button">Login</button>
            </div>
        </form>
        
        <div id="loading" class="loading">
            <div>Logging in...</div>
        </div>
    </div>

    <script>
        const vscode = acquireVsCodeApi();
        
        document.getElementById('login-form').addEventListener('submit', (e) => {
            e.preventDefault();
            
            const handle = document.getElementById('handle').value.trim();
            const password = document.getElementById('password').value;
            
            if (!handle || !password) {
                showError('Please provide both handle and password');
                return;
            }
            
            // Show loading state
            document.getElementById('loading').style.display = 'block';
            document.getElementById('login-button').disabled = true;
            
            // Send login message to extension
            vscode.postMessage({
                command: 'login',
                handle: handle,
                password: password
            });
        });
        
        document.getElementById('cancel-button').addEventListener('click', () => {
            vscode.postMessage({ command: 'cancel' });
        });
        
        // Handle messages from the extension
        window.addEventListener('message', event => {
            const message = event.data;
            
            switch (message.command) {
                case 'error':
                    showError(message.message);
                    document.getElementById('loading').style.display = 'none';
                    document.getElementById('login-button').disabled = false;
                    break;
            }
        });
        
        function showError(message) {
            const errorDiv = document.getElementById('error-message');
            errorDiv.textContent = message;
            errorDiv.style.display = 'block';
        }
        
        // Focus the handle input on load
        document.getElementById('handle').focus();
    </script>
</body>
</html>`;
}