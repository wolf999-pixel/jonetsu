import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ThrottlerGuard } from '@nestjs/throttler';
import helmet from 'helmet';
import { AppModule } from './app.module';

const cookieParser = require('cookie-parser');

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const configService = app.get(ConfigService);

  app.use(
    helmet({
      contentSecurityPolicy: false,
      crossOriginEmbedderPolicy: false,
    }),
  );

  app.enableCors({
    origin: (origin, callback) => {
      const allowedOrigins = (configService.get<string>('ALLOWED_ORIGINS') || 'http://localhost:3001')
        .split(',')
        .map((item) => item.trim());

      if (!origin || allowedOrigins.includes(origin)) {
        callback(null, true);
        return;
      }

      callback(new Error('Not allowed by CORS'));
    },
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

  const port = Number(configService.get<number>('PORT', 3000));
  await app.listen(port);

  console.log(`\x1b[32m✔ JŌNETSU backend listening on port ${port}\x1b[0m`);
}
bootstrap();
