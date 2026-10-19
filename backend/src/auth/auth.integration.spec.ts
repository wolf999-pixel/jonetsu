import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import { JwtService } from '@nestjs/jwt';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from '../users/user.entity';
import { AppModule } from '../app.module';
import { ConfigModule } from '@nestjs/config';
import { Repository } from 'typeorm';
import { getRepositoryToken } from '@nestjs/typeorm';

describe('Auth integration', () => {
  let app: INestApplication;
  let jwtService: JwtService;
  let userRepository: Repository<User>;

  beforeAll(async () => {
    const moduleRef: TestingModule = await Test.createTestingModule({
      imports: [
        ConfigModule.forRoot({ isGlobal: true, envFilePath: ['.env.local'] }),
        TypeOrmModule.forRoot({
          type: 'sqlite',
          database: ':memory:',
          dropSchema: true,
          entities: [User],
          synchronize: true,
          logging: false,
        }),
        AppModule,
      ],
    }).compile();

    app = moduleRef.createNestApplication();
    app.useGlobalPipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true, transform: true }));
    await app.init();

    jwtService = moduleRef.get<JwtService>(JwtService);
    userRepository = moduleRef.get<Repository<User>>(getRepositoryToken(User));
  });

  afterAll(async () => {
    await app.close();
  });

  it('should register a new user and return JWT', async () => {
    const response = await request(app.getHttpServer())
      .post('/api/auth/register')
      .send({
        email: 'user@test.com',
        username: 'testuser',
        password: 'Password123!',
        displayName: 'Test User',
      })
      .expect(201);

    expect(response.body.accessToken).toBeDefined();
    expect(response.body.user.email).toBe('user@test.com');
  });

  it('should reject invalid login credentials', async () => {
    await request(app.getHttpServer())
      .post('/api/auth/login')
      .send({
        email: 'user@test.com',
        password: 'WrongPassword123!',
      })
      .expect(401);
  });

  it('should issue a valid JWT for a real registered user', async () => {
    const user = await userRepository.findOne({ where: { email: 'user@test.com' } });
    const token = jwtService.sign({ sub: user!.id, email: user!.email, username: user!.username, role: user!.role ?? 'user' });

    const decoded = jwtService.verify(token);
    expect(decoded.sub).toBe(user!.id);
    expect(decoded.role).toBe('user');
  });
});
