import * as vscode from 'vscode';
import { exec } from 'child_process';
import { promisify } from 'util';

const execPromise = promisify(exec);

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
        // Check if we have stored credentials
        const credentials = await this.getCredentials();
        if (!credentials) {
            return false;
        }
        
        // Verify the CLI session is still valid
        try {
            const { stdout } = await execPromise('atproto whoami', { timeout: 5000 });
            // If whoami succeeds without error, we're authenticated
            return stdout.includes('Handle:') || stdout.includes('DID:');
        } catch (error) {
            // If whoami fails, clear stored credentials and return false
            await this.clearCredentials();
            return false;
        }
    }

    async checkAuthState(): Promise<void> {
        const isAuth = await this.isAuthenticated();
        this._onAuthStateChanged.fire(isAuth);
    }

    // Method to authenticate with Bluesky using handle and password
    async authenticate(handle: string, password: string): Promise<AuthCredentials> {
        // Use the atproto CLI for actual authentication
        try {
            // Try to find atproto command
            const atprotoCmd = 'atproto';
            
            // Execute login command using environment variables
            const { stdout, stderr } = await execPromise(
                `${atprotoCmd} login`,
                {
                    env: {
                        ...process.env,
                        BLUESKY_HANDLE: handle,
                        BLUESKY_PASSWORD: password
                    },
                    timeout: 10000 // 10 second timeout
                }
            );
            
            // If login succeeded, get the session info
            const { stdout: whoamiOutput } = await execPromise(`${atprotoCmd} whoami`, {
                timeout: 5000
            });
            
            // Parse the whoami output to extract DID
            const didMatch = whoamiOutput.match(/DID:\s*(\S+)/i);
            const did = didMatch ? didMatch[1] : 'did:plc:unknown';
            
            // Store credentials (CLI manages actual tokens in session file)
            const credentials: AuthCredentials = {
                handle: handle,
                accessToken: 'managed_by_cli',
                refreshToken: 'managed_by_cli',
                did: did
            };

            await this.storeCredentials(credentials);
            return credentials;
            
        } catch (error: any) {
            console.error('Authentication failed:', error);
            throw new Error(`Authentication failed: ${error.message || 'Unknown error'}`);
        }
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