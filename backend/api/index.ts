import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ThrottlerGuard } from '@nestjs/throttler';
import helmet from 'helmet';
import { AppModule } from '../src/app.module';

const cookieParser = require('cookie-parser');

let app: any;

export default async function handler(req: any, res: any) {
  if (!app) {
    app = await NestFactory.create(AppModule);
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
  }

  const instance = app.getHttpAdapter().getInstance();
  instance(req, res);
}
