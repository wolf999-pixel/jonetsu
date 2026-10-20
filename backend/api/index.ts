import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ThrottlerGuard } from '@nestjs/throttler';
import helmet from 'helmet';
import { AppModule } from '../src/app.module';

const cookieParser = require('cookie-parser');

let cachedServer: any;

async function bootstrapServer() {
  const app = await NestFactory.create(AppModule, { logger: ['error', 'warn', 'log'] });
  const configService = app.get(ConfigService);

  app.use(
    helmet({
      contentSecurityPolicy: false,
      crossOriginEmbedderPolicy: false,
    }),
  );

  app.enableCors({
    origin: '*',
    credentials: true,
    methods: ['GET', 'HEAD', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'Accept', 'Origin'],
  });

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: { enableImplicitConversion: true },
      forbidUnknownValues: true,
    }),
  );

  app.useGlobalGuards(app.get(ThrottlerGuard));
  app.use(cookieParser());
  app.setGlobalPrefix('api');

  await app.init();
  return app.getHttpAdapter().getInstance();
}

export default async function handler(req: any, res: any) {
  try {
    if (!cachedServer) {
      cachedServer = await bootstrapServer();
    }
    return cachedServer(req, res);
  } catch (error: any) {
    console.error('Vercel Serverless Function Error:', error);
    res.status(500).json({
      error: 'Serverless Function Execution Error',
      message: error?.message || 'Failed to initialize NestJS server',
    });
  }
}
