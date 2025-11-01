/**
 * Batch Operations Tools for atproto MCP Server
 * Enables bulk operations for efficient automation
 */

import { executeShellCommand } from '../lib/shell-executor.js';

/**
 * Batch post - Create multiple posts
 */
async function batchPost(args: { posts: Array<{ text: string; image?: string }> }): Promise<any> {
  const results = [];
  
  for (const post of args.posts) {
    try {
      let command = `atproto post "${post.text.replace(/"/g, '\\"')}"`;
      
      if (post.image) {
        command = `atproto post "${post.text.replace(/"/g, '\\"')}" --image "${post.image}"`;
      }
      
      const result = await executeShellCommand(command);
      results.push({
        success: true,
        text: post.text,
        output: result,
      });
    } catch (error) {
      results.push({
        success: false,
        text: post.text,
        error: error instanceof Error ? error.message : String(error),
      });
    }
  }
  
  const successCount = results.filter(r => r.success).length;
  
  return {
    total: args.posts.length,
    successful: successCount,
    failed: args.posts.length - successCount,
    results,
  };
}

/**
 * Batch follow - Follow multiple users
 */
async function batchFollow(args: { handles: string[] }): Promise<any> {
  const results = [];
  
  for (const handle of args.handles) {
    try {
      const command = `atproto follow "${handle}"`;
      const result = await executeShellCommand(command);
      results.push({
        success: true,
        handle,
        output: result,
      });
    } catch (error) {
      results.push({
        success: false,
        handle,
        error: error instanceof Error ? error.message : String(error),
      });
    }
  }
  
  const successCount = results.filter(r => r.success).length;
  
  return {
    total: args.handles.length,
    successful: successCount,
    failed: args.handles.length - successCount,
    results,
  };
}

/**
 * Batch unfollow - Unfollow multiple users
 */
async function batchUnfollow(args: { handles: string[] }): Promise<any> {
  const results = [];
  
  for (const handle of args.handles) {
    try {
      const command = `atproto unfollow "${handle}"`;
      const result = await executeShellCommand(command);
      results.push({
        success: true,
        handle,
        output: result,
      });
    } catch (error) {
      results.push({
        success: false,
        handle,
        error: error instanceof Error ? error.message : String(error),
      });
    }
  }
  
  const successCount = results.filter(r => r.success).length;
  
  return {
    total: args.handles.length,
    successful: successCount,
    failed: args.handles.length - successCount,
    results,
  };
}

/**
 * Batch like - Like multiple posts
 */
async function batchLike(args: { uris: string[] }): Promise<any> {
  const results = [];
  
  for (const uri of args.uris) {
    try {
      const command = `atproto like "${uri}"`;
      const result = await executeShellCommand(command);
      results.push({
        success: true,
        uri,
        output: result,
      });
    } catch (error) {
      results.push({
        success: false,
        uri,
        error: error instanceof Error ? error.message : String(error),
      });
    }
  }
  
  const successCount = results.filter(r => r.success).length;
  
  return {
    total: args.uris.length,
    successful: successCount,
    failed: args.uris.length - successCount,
    results,
  };
}

/**
 * Batch operations from file
 * Read operations from a JSON file and execute them
 */
async function batchFromFile(args: { filepath: string }): Promise<any> {
  try {
    const fs = await import('fs/promises');
    const fileContent = await fs.readFile(args.filepath, 'utf-8');
    const operations = JSON.parse(fileContent);
    
    const results = {
      posts: { total: 0, successful: 0, failed: 0, results: [] as any[] },
      follows: { total: 0, successful: 0, failed: 0, results: [] as any[] },
      likes: { total: 0, successful: 0, failed: 0, results: [] as any[] },
    };
    
    // Process posts
    if (operations.posts && Array.isArray(operations.posts)) {
      results.posts = await batchPost({ posts: operations.posts });
    }
    
    // Process follows
    if (operations.follows && Array.isArray(operations.follows)) {
      results.follows = await batchFollow({ handles: operations.follows });
    }
    
    // Process likes
    if (operations.likes && Array.isArray(operations.likes)) {
      results.likes = await batchLike({ uris: operations.likes });
    }
    
    return {
      success: true,
      filepath: args.filepath,
      summary: {
        posts: `${results.posts.successful}/${results.posts.total}`,
        follows: `${results.follows.successful}/${results.follows.total}`,
        likes: `${results.likes.successful}/${results.likes.total}`,
      },
      details: results,
    };
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : String(error),
    };
  }
}

/**
 * Export batch operation tools
 */
export const batchTools = [
  {
    name: 'batch_post',
    description: 'Create multiple posts in batch. Useful for scheduling content or bulk posting.',
    inputSchema: {
      type: 'object',
      properties: {
        posts: {
          type: 'array',
          description: 'Array of posts to create',
          items: {
            type: 'object',
            properties: {
              text: {
                type: 'string',
                description: 'Post text content',
              },
              image: {
                type: 'string',
                description: 'Optional path to image file',
              },
            },
            required: ['text'],
          },
        },
      },
      required: ['posts'],
    },
    handler: batchPost,
  },
  {
    name: 'batch_follow',
    description: 'Follow multiple users in batch. Useful for bulk relationship management.',
    inputSchema: {
      type: 'object',
      properties: {
        handles: {
          type: 'array',
          description: 'Array of user handles to follow',
          items: {
            type: 'string',
            description: 'User handle (e.g., user.bsky.social)',
          },
        },
      },
      required: ['handles'],
    },
    handler: batchFollow,
  },
  {
    name: 'batch_unfollow',
    description: 'Unfollow multiple users in batch.',
    inputSchema: {
      type: 'object',
      properties: {
        handles: {
          type: 'array',
          description: 'Array of user handles to unfollow',
          items: {
            type: 'string',
            description: 'User handle (e.g., user.bsky.social)',
          },
        },
      },
      required: ['handles'],
    },
    handler: batchUnfollow,
  },
  {
    name: 'batch_like',
    description: 'Like multiple posts in batch.',
    inputSchema: {
      type: 'object',
      properties: {
        uris: {
          type: 'array',
          description: 'Array of post URIs to like',
          items: {
            type: 'string',
            description: 'Post URI (at://... format)',
          },
        },
      },
      required: ['uris'],
    },
    handler: batchLike,
  },
  {
    name: 'batch_from_file',
    description: 'Execute batch operations from a JSON file. File should contain posts, follows, and/or likes arrays.',
    inputSchema: {
      type: 'object',
      properties: {
        filepath: {
          type: 'string',
          description: 'Path to JSON file containing batch operations',
        },
      },
      required: ['filepath'],
    },
    handler: batchFromFile,
  },
];
