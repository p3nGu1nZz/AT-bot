/**
 * Shell command executor
 * Executes AT-bot CLI commands and returns results
 */

import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

/**
 * Execute a shell command and return the output
 */
export async function executeShellCommand(command: string): Promise<string> {
  try {
    const { stdout, stderr } = await execAsync(command, {
      env: {
        ...process.env,
        // Ensure non-interactive mode
        NONINTERACTIVE: '1',
      },
    });
    
    if (stderr && !stdout) {
      throw new Error(stderr);
    }
    
    return stdout.trim();
  } catch (error) {
    if (error instanceof Error) {
      throw new Error(`Shell command failed: ${error.message}`);
    }
    throw error;
  }
}

/**
 * Execute AT-bot CLI command
 */
export async function executeATBotCommand(
  command: string,
  ...args: string[]
): Promise<string> {
  const fullCommand = `at-bot ${command} ${args.join(' ')}`;
  return executeShellCommand(fullCommand);
}
