import swaggerJsdoc from 'swagger-jsdoc';
import { env } from './env';
import path from 'path';

// Get the base URL from environment or use default
const getBaseUrl = (): string => {
  if (process.env.BASE_URL) {
    return process.env.BASE_URL;
  }
  if (env.nodeEnv === 'production') {
    // Try to get from common deployment platforms
    if (process.env.RENDER_EXTERNAL_URL) {
      return process.env.RENDER_EXTERNAL_URL;
    }
    if (process.env.HEROKU_APP_NAME) {
      return `https://${process.env.HEROKU_APP_NAME}.herokuapp.com`;
    }
    // Default production URL - update this with your actual URL
    return 'https://your-app-name.onrender.com';
  }
  return `http://localhost:${env.port}`;
};

const baseUrl = getBaseUrl();

const options: swaggerJsdoc.Options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Plantify Backend API',
      version: '1.0.0',
      description: 'Backend API documentation for Plantify mobile application',
      contact: {
        name: 'API Support',
      },
    },
    servers: [
      {
        url: baseUrl,
        description: env.nodeEnv === 'production' ? 'Production server' : 'Development server',
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
          description: 'Enter JWT token',
        },
      },
      schemas: {
        User: {
          type: 'object',
          properties: {
            id: {
              type: 'string',
              description: 'User ID',
            },
            email: {
              type: 'string',
              format: 'email',
              description: 'User email',
            },
            name: {
              type: 'string',
              description: 'User name',
            },
            googleId: {
              type: 'string',
              description: 'Google OAuth ID (if authenticated via Google)',
            },
            createdAt: {
              type: 'string',
              format: 'date-time',
            },
          },
        },
        Plant: {
          type: 'object',
          properties: {
            id: {
              type: 'string',
              description: 'Plant ID',
            },
            name: {
              type: 'string',
              description: 'Plant name',
            },
            type: {
              type: 'string',
              description: 'Plant type',
            },
            careInstructions: {
              type: 'string',
              description: 'Care instructions',
            },
            wateringFrequency: {
              type: 'number',
              description: 'Watering frequency in days',
            },
            lastWatered: {
              type: 'string',
              format: 'date-time',
              nullable: true,
            },
            nextWatering: {
              type: 'string',
              format: 'date-time',
              nullable: true,
            },
            imageUrl: {
              type: 'string',
              format: 'uri',
              nullable: true,
            },
            createdAt: {
              type: 'string',
              format: 'date-time',
            },
            updatedAt: {
              type: 'string',
              format: 'date-time',
            },
          },
        },
        Error: {
          type: 'object',
          properties: {
            success: {
              type: 'boolean',
              example: false,
            },
            error: {
              type: 'object',
              properties: {
                message: {
                  type: 'string',
                },
                code: {
                  type: 'string',
                },
              },
            },
          },
        },
        Success: {
          type: 'object',
          properties: {
            success: {
              type: 'boolean',
              example: true,
            },
          },
        },
      },
    },
    tags: [
      {
        name: 'Authentication',
        description: 'User authentication endpoints',
      },
      {
        name: 'Plants',
        description: 'Plant management endpoints',
      },
    ],
  },
  apis: [
    // Scan TypeScript source files (for development)
    path.join(__dirname, '../routes/**/*.ts'),
    // Scan compiled JavaScript files (for production)
    path.join(__dirname, '../routes/**/*.js'),
  ],
};

export const swaggerSpec = swaggerJsdoc(options);

// Debug: Log the generated spec to help troubleshoot
if (env.nodeEnv === 'development') {
  console.log('([LOG swagger_debug] ========= Swagger spec paths:', options.apis);
  console.log('([LOG swagger_debug] ========= Swagger paths count:', Object.keys(swaggerSpec.paths || {}).length);
  if (swaggerSpec.paths) {
    console.log('([LOG swagger_debug] ========= Available paths:', Object.keys(swaggerSpec.paths));
  }
}

