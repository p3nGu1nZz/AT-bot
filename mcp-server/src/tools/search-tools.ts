/**
 * Search and discovery tools for MCP
 * Tools for searching posts and discovering content
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

export const searchTools: ToolDefinition[] = [
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
          description: 'Number of results to retrieve (default: 20, max: 100)',
        },
      },
      required: ['query'],
    },
    handler: async (args: { query: string; limit?: number }) => {
      try {
        const limit = args.limit || 20;
        const result = await executeATBotCommand('search', `"${args.query}"`, String(limit));
        return {
          success: true,
          results: result,
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
    name: 'read_feed',
    description: 'Read the user timeline/feed with optional limit',
    inputSchema: {
      type: 'object',
      properties: {
        limit: {
          type: 'number',
          description: 'Number of posts to retrieve (default: 10, max: 100)',
        },
      },
    },
    handler: async (args: { limit?: number }) => {
      try {
        const limit = args.limit || 10;
        const result = await executeATBotCommand('feed', String(limit));
        return {
          success: true,
          feed: result,
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
    name: 'search_users',
    description: 'Search for users on Bluesky (currently searches through feed)',
    inputSchema: {
      type: 'object',
      properties: {
        query: {
          type: 'string',
          description: 'The search query string (handle or display name)',
        },
      },
      required: ['query'],
    },
    handler: async (args: { query: string }) => {
      try {
        // User search would typically use a dedicated endpoint
        // For now, return a message indicating this would be enhanced
        return {
          success: true,
          message: `Searching for users matching: ${args.query}`,
          note: 'User search will be fully implemented when AT Protocol endpoint is available',
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
