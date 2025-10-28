/**
 * Profile tools for MCP
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

export const profileTools: ToolDefinition[] = [
  {
    name: 'profile_get',
    description: 'Get user profile information',
    inputSchema: {
      type: 'object',
      properties: {
        handle: {
          type: 'string',
          description: 'Bluesky handle (optional, defaults to current user)',
        },
      },
    },
    handler: async (args: { handle?: string }) => {
      const handle = args.handle || '';
      const result = await executeATBotCommand('profile', handle);
      return {
        success: true,
        profile: result,
      };
    },
  },
  {
    name: 'profile_edit',
    description: 'Edit user profile (name, bio, avatar, banner)',
    inputSchema: {
      type: 'object',
      properties: {
        name: {
          type: 'string',
          description: 'Display name',
        },
        bio: {
          type: 'string',
          description: 'Profile bio/description',
        },
        avatar: {
          type: 'string',
          description: 'Path to avatar image file',
        },
        banner: {
          type: 'string',
          description: 'Path to banner image file',
        },
      },
    },
    handler: async (args: { name?: string; bio?: string; avatar?: string; banner?: string }) => {
      const cmdArgs: string[] = [];
      if (args.name) cmdArgs.push('--name', `"${args.name}"`);
      if (args.bio) cmdArgs.push('--bio', `"${args.bio}"`);
      if (args.avatar) cmdArgs.push('--avatar', args.avatar);
      if (args.banner) cmdArgs.push('--banner', args.banner);
      
      const result = await executeATBotCommand('profile-edit', ...cmdArgs);
      return {
        success: true,
        message: result,
      };
    },
  },
  {
    name: 'profile_get_followers',
    description: 'Get list of followers for a user',
    inputSchema: {
      type: 'object',
      properties: {
        handle: {
          type: 'string',
          description: 'Bluesky handle (optional, defaults to current user)',
        },
        limit: {
          type: 'number',
          description: 'Number of followers to retrieve (default: 50, max: 100)',
        },
      },
    },
    handler: async (args: { handle?: string; limit?: number }) => {
      const cmdArgs: string[] = [];
      if (args.handle) cmdArgs.push(args.handle);
      if (args.limit) cmdArgs.push(String(args.limit));
      
      const result = await executeATBotCommand('followers', ...cmdArgs);
      return {
        success: true,
        followers: result,
      };
    },
  },
  {
    name: 'profile_get_following',
    description: 'Get list of users being followed',
    inputSchema: {
      type: 'object',
      properties: {
        handle: {
          type: 'string',
          description: 'Bluesky handle (optional, defaults to current user)',
        },
        limit: {
          type: 'number',
          description: 'Number of following to retrieve (default: 50, max: 100)',
        },
      },
    },
    handler: async (args: { handle?: string; limit?: number }) => {
      const cmdArgs: string[] = [];
      if (args.handle) cmdArgs.push(args.handle);
      if (args.limit) cmdArgs.push(String(args.limit));
      
      const result = await executeATBotCommand('following', ...cmdArgs);
      return {
        success: true,
        following: result,
      };
    },
  },
];
