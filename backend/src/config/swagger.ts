import swaggerJsdoc from 'swagger-jsdoc';
import { env } from './env';

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
        url: `http://localhost:${env.port}`,
        description: 'Development server',
      },
      {
        url: 'https://your-app-name.onrender.com',
        description: 'Production server',
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
  apis: ['./src/routes/*.ts'],
};

export const swaggerSpec = swaggerJsdoc(options);

