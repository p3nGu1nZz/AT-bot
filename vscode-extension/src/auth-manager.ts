import * as vscode from 'vscode';

export interface AuthCredentials {
    handle: string;
    accessToken: string;
    refreshToken: string;
    did: string;
}

export class AuthManager {
    private static readonly CREDENTIALS_KEY = 'atproto.credentials';
    private _onAuthStateChanged: vscode.EventEmitter<boolean> = new vscode.EventEmitter<boolean>();
    public readonly onAuthStateChanged: vscode.Event<boolean> = this._onAuthStateChanged.event;

    constructor(private secrets: vscode.SecretStorage) {}

    async storeCredentials(credentials: AuthCredentials): Promise<void> {
        const credentialsJson = JSON.stringify({
            handle: credentials.handle,
            accessToken: credentials.accessToken,
            refreshToken: credentials.refreshToken,
            did: credentials.did,
            timestamp: Date.now()
        });

        await this.secrets.store(AuthManager.CREDENTIALS_KEY, credentialsJson);
        this._onAuthStateChanged.fire(true);
    }

    async getCredentials(): Promise<AuthCredentials | null> {
        const stored = await this.secrets.get(AuthManager.CREDENTIALS_KEY);
        if (!stored) {
            return null;
        }

        try {
            const parsed = JSON.parse(stored);
            return {
                handle: parsed.handle,
                accessToken: parsed.accessToken,
                refreshToken: parsed.refreshToken,
                did: parsed.did
            };
        } catch (error) {
            console.error('Failed to parse stored credentials:', error);
            await this.clearCredentials();
            return null;
        }
    }

    async clearCredentials(): Promise<void> {
        await this.secrets.delete(AuthManager.CREDENTIALS_KEY);
        this._onAuthStateChanged.fire(false);
    }

    async isAuthenticated(): Promise<boolean> {
        const credentials = await this.getCredentials();
        return credentials !== null;
    }

    async checkAuthState(): Promise<void> {
        const isAuth = await this.isAuthenticated();
        this._onAuthStateChanged.fire(isAuth);
    }

    // Method to authenticate with Bluesky using handle and password
    async authenticate(handle: string, password: string): Promise<AuthCredentials> {
        // This would integrate with the existing atproto CLI authentication
        // For now, we'll simulate the authentication flow
        
        // In a real implementation, this would:
        // 1. Call the atproto CLI login command or
        // 2. Make direct API calls to the AT Protocol server
        // 3. Parse the response and extract tokens
        
        // For development, we'll use a placeholder
        const credentials: AuthCredentials = {
            handle: handle,
            accessToken: 'placeholder_access_token',
            refreshToken: 'placeholder_refresh_token',
            did: 'did:plc:placeholder'
        };

        await this.storeCredentials(credentials);
        return credentials;
    }

    // Method to refresh tokens if needed
    async refreshTokens(): Promise<boolean> {
        const credentials = await this.getCredentials();
        if (!credentials || !credentials.refreshToken) {
            return false;
        }

        try {
            // This would integrate with the atproto CLI or make direct API calls
            // For now, return true to indicate success
            return true;
        } catch (error) {
            console.error('Failed to refresh tokens:', error);
            await this.clearCredentials();
            return false;
        }
    }
}