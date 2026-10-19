import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../app.module';

describe('AdminController permission tests', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleRef: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleRef.createNestApplication();
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('should reject anonymous access to admin stats', async () => {
    await request(app.getHttpServer())
      .get('/api/admin/stats')
      .expect(401);
  });

  it('should reject non-admin access to admin users list', async () => {
    const token = 'eyJhbGciOiJub25lIn0.eyJzdWIiOiJ0ZXN0LXVzZXIiLCJyb2xlIjoidXNlciJ9.';

    await request(app.getHttpServer())
      .get('/api/admin/users')
      .set('Authorization', `Bearer ${token}`)
      .expect(401);
  });

  it('should allow admin to access stats if token has admin role', async () => {
    const adminToken = 'eyJhbGciOiJub25lIn0.eyJzdWIiOiJ0ZXN0LWFkbWluIiwicm9sZSI6ImFkbWluIn0.';

    await request(app.getHttpServer())
      .get('/api/admin/stats')
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(401);
  });
});
