/**
 * Feed tools for MCP
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

export const feedTools: [string, ToolDefinition][] = [
  [
    'feed_read',
    {
      name: 'feed_read',
      description: 'Read the user timeline/feed',
      inputSchema: {
        type: 'object',
        properties: {
          limit: {
            type: 'number',
            description: 'Number of posts to retrieve (default: 10)',
          },
        },
      },
      handler: async (args: { limit?: number }) => {
        const limit = args.limit || 10;
        const result = await executeATBotCommand('feed', String(limit));
        return {
          success: true,
          feed: result,
        };
      },
    },
  ],
];
