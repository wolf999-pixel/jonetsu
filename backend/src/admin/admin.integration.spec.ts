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

describe('Admin integration', () => {
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

    const adminUser = userRepository.create({
      email: 'admin@test.com',
      username: 'adminuser',
      passwordHash: '$2b$12$M8jPli1lZJg3m4j0l8g0Be4GqG8d8F5w6f8xV9r3L9W5qbY4P0k8e',
      role: 'admin',
      authProvider: 'email',
      displayName: 'Admin User',
    });

    await userRepository.save(adminUser);
  });

  afterAll(async () => {
    await app.close();
  });

  it('should reject access to admin stats without JWT', async () => {
    await request(app.getHttpServer())
      .get('/api/admin/stats')
      .expect(401);
  });

  it('should allow admin JWT to access stats', async () => {
    const admin = await userRepository.findOne({ where: { email: 'admin@test.com' } });
    const token = jwtService.sign({ sub: admin!.id, email: admin!.email, username: admin!.username, role: 'admin' });

    await request(app.getHttpServer())
      .get('/api/admin/stats')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);
  });

  it('should reject user JWT on admin endpoint', async () => {
    const user = userRepository.create({
      email: 'normal@test.com',
      username: 'normaluser',
      passwordHash: '$2b$12$M8jPli1lZJg3m4j0l8g0Be4GqG8d8F5w6f8xV9r3L9W5qbY4P0k8e',
      role: 'user',
      authProvider: 'email',
      displayName: 'Normal User',
    });

    await userRepository.save(user);
    const token = jwtService.sign({ sub: user.id, email: user.email, username: user.username, role: 'user' });

    await request(app.getHttpServer())
      .get('/api/admin/stats')
      .set('Authorization', `Bearer ${token}`)
      .expect(403);
  });
});
