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
import { logger } from './lib/logger.js';

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

    logger.info('MCP Server initialized', {
      toolCount: this.tools.size,
      tools: Array.from(this.tools.keys()),
    });

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
      const toolName = request.params.name;
      const tool = this.tools.get(toolName);
      
      logger.debug('Tool execution requested', {
        tool: toolName,
        arguments: request.params.arguments,
      });
      
      if (!tool) {
        logger.error('Unknown tool requested', { tool: toolName });
        throw new Error(`Unknown tool: ${toolName}`);
      }

      try {
        const startTime = Date.now();
        
        // Execute the tool by calling the atproto CLI
        const result = await tool.handler(request.params.arguments);
        
        const duration = Date.now() - startTime;
        logger.info('Tool executed successfully', {
          tool: toolName,
          duration: `${duration}ms`,
        });
        
        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify(result, null, 2),
            },
          ],
        };
      } catch (error) {
        logger.error('Tool execution failed', {
          tool: toolName,
          error: error instanceof Error ? error.message : String(error),
        });
        
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
    
    logger.info('MCP Server started successfully', {
      toolCount: this.tools.size,
      logLevel: process.env.MCP_LOG_LEVEL || 'INFO',
    });
    
    // Log to stderr (stdout is reserved for MCP protocol)
    console.error('atproto MCP Server started successfully');
    console.error(`Registered ${this.tools.size} tools`);
  }
}

// Start server
const server = new ATBotMCPServer();
server.start().catch((error) => {
  logger.error('Failed to start server', { error: error.message });
  console.error('Failed to start server:', error);
  process.exit(1);
});
