/**
 * Profile tools for MCP
 * Note: Most profile operations not yet implemented in CLI
 */

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

export const profileTools: [string, ToolDefinition][] = [
  // Profile tools will be added as CLI commands are implemented
  // Placeholder for future implementation
];
