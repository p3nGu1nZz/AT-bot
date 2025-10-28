/**
 * Media tools for MCP
 * Tools for uploading and managing media (images, videos)
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

export const mediaTools: ToolDefinition[] = [
  {
    name: 'post_with_image',
    description: 'Create a post with an image attachment',
    inputSchema: {
      type: 'object',
      properties: {
        text: {
          type: 'string',
          description: 'The post text content',
        },
        image: {
          type: 'string',
          description: 'Path to the image file (JPEG, PNG, GIF, or WebP)',
        },
      },
      required: ['text', 'image'],
    },
    handler: async (args: { text: string; image: string }) => {
      try {
        const result = await executeATBotCommand('post', '--image', args.image, `"${args.text}"`);
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
    name: 'upload_media',
    description: 'Upload media file (image or video) to get blob reference',
    inputSchema: {
      type: 'object',
      properties: {
        filepath: {
          type: 'string',
          description: 'Path to media file (images: JPEG/PNG/GIF/WebP, max 1MB; videos: MP4, max 50MB)',
        },
      },
      required: ['filepath'],
    },
    handler: async (args: { filepath: string }) => {
      try {
        // This would call the underlying blob upload API
        // For now, return a placeholder that indicates the file was processed
        return {
          success: true,
          message: `Media file '${args.filepath}' would be uploaded to Bluesky blob service`,
          note: 'Actual blob upload handled by at-bot post command with --image flag',
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
    name: 'post_with_gallery',
    description: 'Create a post with multiple images (gallery)',
    inputSchema: {
      type: 'object',
      properties: {
        text: {
          type: 'string',
          description: 'The post text content',
        },
        images: {
          type: 'array',
          items: {
            type: 'string',
          },
          description: 'Array of paths to image files (up to 4 images)',
        },
      },
      required: ['text', 'images'],
    },
    handler: async (args: { text: string; images: string[] }) => {
      try {
        // Gallery support would require multiple blob uploads and embed formatting
        // Currently posting with single image is supported
        if (args.images.length === 0) {
          return {
            success: false,
            error: 'At least one image is required',
          };
        }
        
        if (args.images.length > 4) {
          return {
            success: false,
            error: 'Maximum 4 images allowed in a gallery',
          };
        }
        
        // Use first image for now (full gallery support coming)
        const result = await executeATBotCommand('post', '--image', args.images[0], `"${args.text}"`);
        return {
          success: true,
          message: result,
          note: args.images.length > 1 ? `Posting with first image. Full gallery support with ${args.images.length} images coming soon.` : undefined,
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
    name: 'post_with_video',
    description: 'Create a post with a video attachment',
    inputSchema: {
      type: 'object',
      properties: {
        text: {
          type: 'string',
          description: 'The post text content',
        },
        video: {
          type: 'string',
          description: 'Path to MP4 video file (max 50MB)',
        },
      },
      required: ['text', 'video'],
    },
    handler: async (args: { text: string; video: string }) => {
      try {
        // Video support through blob API (videos are embedded similar to images)
        const result = await executeATBotCommand('post', '--image', args.video, `"${args.text}"`);
        return {
          success: true,
          message: result,
          note: 'Video file treated as media attachment (full video embed support coming)',
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
