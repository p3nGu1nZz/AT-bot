/**
 * Engagement tools for MCP
 * Tools for interacting with posts (like, repost, reply, delete)
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

export const engagementTools: ToolDefinition[] = [
  {
    name: 'post_like',
    description: 'Like a post on Bluesky',
    inputSchema: {
      type: 'object',
      properties: {
        uri: {
          type: 'string',
          description: 'The post URI (at://... format)',
        },
      },
      required: ['uri'],
    },
    handler: async (args: { uri: string }) => {
      try {
        const result = await executeATBotCommand('like', args.uri);
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
    name: 'post_repost',
    description: 'Repost a post on Bluesky',
    inputSchema: {
      type: 'object',
      properties: {
        uri: {
          type: 'string',
          description: 'The post URI (at://... format)',
        },
      },
      required: ['uri'],
    },
    handler: async (args: { uri: string }) => {
      try {
        const result = await executeATBotCommand('repost', args.uri);
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
    name: 'post_reply',
    description: 'Reply to a post on Bluesky',
    inputSchema: {
      type: 'object',
      properties: {
        uri: {
          type: 'string',
          description: 'The post URI to reply to (at://... format)',
        },
        text: {
          type: 'string',
          description: 'The reply text content',
        },
      },
      required: ['uri', 'text'],
    },
    handler: async (args: { uri: string; text: string }) => {
      try {
        const result = await executeATBotCommand('reply', args.uri, `"${args.text}"`);
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
    name: 'post_delete',
    description: 'Delete a post from Bluesky (must be your own post)',
    inputSchema: {
      type: 'object',
      properties: {
        uri: {
          type: 'string',
          description: 'The post URI to delete (at://... format)',
        },
      },
      required: ['uri'],
    },
    handler: async (args: { uri: string }) => {
      try {
        // Note: delete command may not be implemented yet in CLI
        // This is a placeholder that will work once CLI supports it
        const result = await executeATBotCommand('delete', args.uri);
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
    name: 'post_create',
    description: 'Create a new post on Bluesky',
    inputSchema: {
      type: 'object',
      properties: {
        text: {
          type: 'string',
          description: 'The post text content',
        },
        image: {
          type: 'string',
          description: 'Optional path to image file to attach',
        },
      },
      required: ['text'],
    },
    handler: async (args: { text: string; image?: string }) => {
      try {
        const cmdArgs: string[] = [];
        if (args.image) {
          cmdArgs.push('--image', args.image);
        }
        cmdArgs.push(`"${args.text}"`);
        
        const result = await executeATBotCommand('post', ...cmdArgs);
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
