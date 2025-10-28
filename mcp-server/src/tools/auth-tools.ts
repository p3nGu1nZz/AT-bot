/**
 * Authentication tools for MCP
 * 
 * These tools handle Bluesky authentication through AT-bot CLI
 */

import { executeATBotCommand } from '../lib/shell-executor.js';

interface ToolDefinition {
  name: string;
  description: string;
  inputSchema: {
    type: string;
    properties: Record<string, any>;
    required?: string[];
  };
  handler: (args: any) => Promise<any>;
}

/**
 * Authentication tools
 */
export const authTools: [string, ToolDefinition][] = [
  [
    'auth_login',
    {
      name: 'auth_login',
      description: 'Login to Bluesky using credentials. Requires handle and password (app password recommended).',
      inputSchema: {
        type: 'object',
        properties: {
          handle: {
            type: 'string',
            description: 'Bluesky handle (e.g., user.bsky.social)',
          },
          password: {
            type: 'string',
            description: 'Bluesky app password',
          },
        },
        required: ['handle', 'password'],
      },
      handler: async (args: { handle: string; password: string }) => {
        // Set environment variables for non-interactive login
        process.env.BLUESKY_HANDLE = args.handle;
        process.env.BLUESKY_PASSWORD = args.password;
        
        try {
          const result = await executeATBotCommand('login');
          return {
            success: true,
            message: result,
          };
        } finally {
          // Clean up environment variables
          delete process.env.BLUESKY_HANDLE;
          delete process.env.BLUESKY_PASSWORD;
        }
      },
    },
  ],
  [
    'auth_logout',
    {
      name: 'auth_logout',
      description: 'Logout from Bluesky and clear session',
      inputSchema: {
        type: 'object',
        properties: {},
      },
      handler: async () => {
        const result = await executeATBotCommand('logout');
        return {
          success: true,
          message: result,
        };
      },
    },
  ],
  [
    'auth_whoami',
    {
      name: 'auth_whoami',
      description: 'Get information about the currently authenticated user',
      inputSchema: {
        type: 'object',
        properties: {},
      },
      handler: async () => {
        try {
          const result = await executeATBotCommand('whoami');
          return {
            success: true,
            user: result,
          };
        } catch (error) {
          return {
            success: false,
            error: error instanceof Error ? error.message : String(error),
          };
        }
      },
    },
  ],
  [
    'auth_is_authenticated',
    {
      name: 'auth_is_authenticated',
      description: 'Check if currently authenticated to Bluesky',
      inputSchema: {
        type: 'object',
        properties: {},
      },
      handler: async () => {
        try {
          await executeATBotCommand('whoami');
          return {
            authenticated: true,
          };
        } catch {
          return {
            authenticated: false,
          };
        }
      },
    },
  ],
];
