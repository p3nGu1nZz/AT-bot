/**
 * Social tools for MCP
 * Tools for managing social connections (follow, unfollow, view followers/following)
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

export const socialTools: ToolDefinition[] = [
  {
    name: 'follow_user',
    description: 'Follow a user on Bluesky',
    inputSchema: {
      type: 'object',
      properties: {
        handle: {
          type: 'string',
          description: 'The user handle to follow (e.g., user.bsky.social)',
        },
      },
      required: ['handle'],
    },
    handler: async (args: { handle: string }) => {
      try {
        const result = await executeATBotCommand('follow', args.handle);
        return {
          success: true,
          message: result,
        };
      } catch (error) {
        return {
          success: false,
          error: error instanceof Error ? error.message : String(error),
        };
      }
    },
  },
  {
    name: 'unfollow_user',
    description: 'Unfollow a user on Bluesky',
    inputSchema: {
      type: 'object',
      properties: {
        handle: {
          type: 'string',
          description: 'The user handle to unfollow (e.g., user.bsky.social)',
        },
      },
      required: ['handle'],
    },
    handler: async (args: { handle: string }) => {
      try {
        const result = await executeATBotCommand('unfollow', args.handle);
        return {
          success: true,
          message: result,
        };
      } catch (error) {
        return {
          success: false,
          error: error instanceof Error ? error.message : String(error),
        };
      }
    },
  },
  {
    name: 'get_followers',
    description: 'Get the list of followers for a user',
    inputSchema: {
      type: 'object',
      properties: {
        handle: {
          type: 'string',
          description: 'The user handle (optional, defaults to current user)',
        },
        limit: {
          type: 'number',
          description: 'Number of followers to retrieve (default: 50, max: 100)',
        },
      },
    },
    handler: async (args: { handle?: string; limit?: number }) => {
      try {
        const cmdArgs: string[] = [];
        if (args.handle) cmdArgs.push(args.handle);
        if (args.limit) cmdArgs.push(String(args.limit));
        
        const result = await executeATBotCommand('followers', ...cmdArgs);
        return {
          success: true,
          followers: result,
        };
      } catch (error) {
        return {
          success: false,
          error: error instanceof Error ? error.message : String(error),
        };
      }
    },
  },
  {
    name: 'get_following',
    description: 'Get the list of users that a user is following',
    inputSchema: {
      type: 'object',
      properties: {
        handle: {
          type: 'string',
          description: 'The user handle (optional, defaults to current user)',
        },
        limit: {
          type: 'number',
          description: 'Number of following to retrieve (default: 50, max: 100)',
        },
      },
    },
    handler: async (args: { handle?: string; limit?: number }) => {
      try {
        const cmdArgs: string[] = [];
        if (args.handle) cmdArgs.push(args.handle);
        if (args.limit) cmdArgs.push(String(args.limit));
        
        const result = await executeATBotCommand('following', ...cmdArgs);
        return {
          success: true,
          following: result,
        };
      } catch (error) {
        return {
          success: false,
          error: error instanceof Error ? error.message : String(error),
        };
      }
    },
  },
  {
    name: 'block_user',
    description: 'Block a user on Bluesky',
    inputSchema: {
      type: 'object',
      properties: {
        handle: {
          type: 'string',
          description: 'The user handle to block (e.g., user.bsky.social)',
        },
      },
      required: ['handle'],
    },
    handler: async (args: { handle: string }) => {
      try {
        // Note: block command may not be implemented yet in CLI
        // This is a placeholder that will work once CLI supports it
        const result = await executeATBotCommand('block', args.handle);
        return {
          success: true,
          message: result,
        };
      } catch (error) {
        return {
          success: false,
          error: error instanceof Error ? error.message : String(error),
        };
      }
    },
  },
  {
    name: 'unblock_user',
    description: 'Unblock a user on Bluesky',
    inputSchema: {
      type: 'object',
      properties: {
        handle: {
          type: 'string',
          description: 'The user handle to unblock (e.g., user.bsky.social)',
        },
      },
      required: ['handle'],
    },
    handler: async (args: { handle: string }) => {
      try {
        // Note: unblock command may not be implemented yet in CLI
        // This is a placeholder that will work once CLI supports it
        const result = await executeATBotCommand('unblock', args.handle);
        return {
          success: true,
          message: result,
        };
      } catch (error) {
        return {
          success: false,
          error: error instanceof Error ? error.message : String(error),
        };
      }
    },
  },
];
