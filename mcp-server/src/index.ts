#!/usr/bin/env node
/**
 * atproto MCP Server
 * 
 * Model Context Protocol server that exposes AT Protocol/Bluesky
 * functionality to AI agents through standardized tool interfaces.
 */

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';

import { authTools } from './tools/auth-tools.js';
import { contentTools } from './tools/content-tools.js';
import { feedTools } from './tools/feed-tools.js';
import { profileTools } from './tools/profile-tools.js';
import { engagementTools } from './tools/engagement-tools.js';
import { socialTools } from './tools/social-tools.js';
import { searchTools } from './tools/search-tools.js';
import { mediaTools } from './tools/media-tools.js';
import { batchTools } from './tools/batch-tools.js';
import { executeShellCommand } from './lib/shell-executor.js';

/**
 * atproto MCP Server
 * Provides tool-based access to Bluesky/AT Protocol functionality
 */
class ATBotMCPServer {
  private server: Server;
  private tools: Map<string, any>;

  constructor() {
    this.server = new Server(
      {
        name: 'atproto-mcp-server',
        version: '0.1.0',
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );

    // Register all tools
    const allTools = [
      ...authTools,
      ...contentTools,
      ...feedTools,
      ...profileTools,
      ...engagementTools,
      ...socialTools,
      ...searchTools,
      ...mediaTools,
      ...batchTools,
    ];
    
    this.tools = new Map(allTools.map(tool => [tool.name, tool]));

    this.setupHandlers();
  }

  /**
   * Set up MCP protocol handlers
   */
  private setupHandlers(): void {
    // List available tools
    this.server.setRequestHandler(ListToolsRequestSchema, async () => ({
      tools: Array.from(this.tools.values()),
    }));

    // Execute tool
    this.server.setRequestHandler(CallToolRequestSchema, async (request: any) => {
      const tool = this.tools.get(request.params.name);
      
      if (!tool) {
        throw new Error(`Unknown tool: ${request.params.name}`);
      }

      try {
        // Execute the tool by calling the atproto CLI
        const result = await tool.handler(request.params.arguments);
        
        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify(result, null, 2),
            },
          ],
        };
      } catch (error) {
        return {
          content: [
            {
              type: 'text',
              text: `Error: ${error instanceof Error ? error.message : String(error)}`,
            },
          ],
          isError: true,
        };
      }
    });
  }

  /**
   * Start the MCP server
   */
  async start(): Promise<void> {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    
    // Log to stderr (stdout is reserved for MCP protocol)
    console.error('atproto MCP Server started successfully');
    console.error(`Registered ${this.tools.size} tools`);
  }
}

// Start server
const server = new ATBotMCPServer();
server.start().catch((error) => {
  console.error('Failed to start server:', error);
  process.exit(1);
});
