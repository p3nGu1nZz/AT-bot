/**
 * Logger utility for MCP server
 * Provides structured logging with different levels
 */

export enum LogLevel {
  DEBUG = 0,
  INFO = 1,
  WARN = 2,
  ERROR = 3,
}

interface LogEntry {
  timestamp: string;
  level: string;
  message: string;
  data?: any;
}

class Logger {
  private level: LogLevel;
  private enableConsole: boolean;
  private logs: LogEntry[] = [];

  constructor() {
    const levelStr = process.env.MCP_LOG_LEVEL?.toUpperCase() || 'INFO';
    this.level = (LogLevel as any)[levelStr] ?? LogLevel.INFO;
    this.enableConsole = process.env.MCP_LOG_CONSOLE !== 'false';
  }

  private shouldLog(level: LogLevel): boolean {
    return level >= this.level;
  }

  private formatMessage(level: string, message: string, data?: any): string {
    const timestamp = new Date().toISOString();
    const logEntry: LogEntry = { timestamp, level, message, data };
    
    if (data) {
      return `[${timestamp}] ${level}: ${message} ${JSON.stringify(data)}`;
    }
    return `[${timestamp}] ${level}: ${message}`;
  }

  private log(level: LogLevel, levelStr: string, message: string, data?: any): void {
    if (!this.shouldLog(level)) return;

    const formatted = this.formatMessage(levelStr, message, data);
    
    // Store in memory
    this.logs.push({
      timestamp: new Date().toISOString(),
      level: levelStr,
      message,
      data,
    });

    // Keep only last 1000 logs
    if (this.logs.length > 1000) {
      this.logs = this.logs.slice(-1000);
    }

    // Console output
    if (this.enableConsole) {
      // Write to stderr to keep stdout clean for MCP protocol
      console.error(formatted);
    }
  }

  debug(message: string, data?: any): void {
    this.log(LogLevel.DEBUG, 'DEBUG', message, data);
  }

  info(message: string, data?: any): void {
    this.log(LogLevel.INFO, 'INFO', message, data);
  }

  warn(message: string, data?: any): void {
    this.log(LogLevel.WARN, 'WARN', message, data);
  }

  error(message: string, data?: any): void {
    this.log(LogLevel.ERROR, 'ERROR', message, data);
  }

  // Get recent logs
  getLogs(count: number = 100): LogEntry[] {
    return this.logs.slice(-count);
  }

  // Clear logs
  clear(): void {
    this.logs = [];
  }
}

// Export singleton instance
export const logger = new Logger();
