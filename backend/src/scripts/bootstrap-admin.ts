import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { Repository } from 'typeorm';
import { User } from '../users/user.entity';
import { InjectRepository } from '@nestjs/typeorm';
import { hash } from 'bcryptjs';

async function bootstrapAdmin() {
  const app = await NestFactory.createApplicationContext(AppModule);

  const userRepository = app.get<Repository<User>>('UserRepository');
  const email = process.env.ADMIN_EMAIL || 'admin@jonetsu.local';
  const username = process.env.ADMIN_USERNAME || 'admin';
  const password = process.env.ADMIN_PASSWORD || 'Admin123!@#';

  const existing = await userRepository.findOne({ where: [{ email }, { username }] });

  if (existing) {
    existing.role = 'admin';
    existing.passwordHash = await hash(password, 12);
    await userRepository.save(existing);
    console.log('Admin account upgraded successfully.');
    await app.close();
    return;
  }

  const admin = userRepository.create({
    email,
    username,
    role: 'admin',
    passwordHash: await hash(password, 12),
    displayName: 'JōNETSU Admin',
    authProvider: 'email',
  });

  await userRepository.save(admin);
  console.log('Admin account created successfully.');
  await app.close();
}

bootstrapAdmin().catch((error) => {
  console.error('Bootstrap admin failed:', error);
  process.exit(1);
});
