/**
 * Content/Post tools for MCP
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

export const contentTools: ToolDefinition[] = [
  {
    name: 'post_create',
    description: 'Create a new post on Bluesky',
    inputSchema: {
      type: 'object',
      properties: {
        text: {
          type: 'string',
          description: 'The text content of the post',
        },
      },
      required: ['text'],
    },
    handler: async (args: { text: string }) => {
      const result = await executeATBotCommand('post', `"${args.text}"`);
      return {
        success: true,
        message: result,
      };
    },
  },
  {
    name: 'search_posts',
    description: 'Search for posts on Bluesky matching a query',
    inputSchema: {
      type: 'object',
      properties: {
        query: {
          type: 'string',
          description: 'The search query string',
        },
        limit: {
          type: 'number',
          description: 'Maximum number of results to return (default: 10)',
          default: 10,
        },
      },
      required: ['query'],
    },
    handler: async (args: { query: string; limit?: number }) => {
      const limit = args.limit || 10;
      const result = await executeATBotCommand('search', `"${args.query}" ${limit}`);
      return {
        success: true,
        message: result,
      };
    },
  },
  {
    name: 'user_follow',
    description: 'Follow a user on Bluesky',
    inputSchema: {
      type: 'object',
      properties: {
        handle: {
          type: 'string',
          description: 'The handle or DID of the user to follow (e.g., user.bsky.social)',
        },
      },
      required: ['handle'],
    },
    handler: async (args: { handle: string }) => {
      const result = await executeATBotCommand('follow', args.handle);
      return {
        success: true,
        message: result,
      };
    },
  },
  {
    name: 'user_unfollow',
    description: 'Unfollow a user on Bluesky',
    inputSchema: {
      type: 'object',
      properties: {
        handle: {
          type: 'string',
          description: 'The handle or DID of the user to unfollow (e.g., user.bsky.social)',
        },
      },
      required: ['handle'],
    },
    handler: async (args: { handle: string }) => {
      const result = await executeATBotCommand('unfollow', args.handle);
      return {
        success: true,
        message: result,
      };
    },
  },
];
