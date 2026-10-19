import { Injectable, UnauthorizedException, OnApplicationBootstrap } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Repository } from 'typeorm';
import { InjectRepository } from '@nestjs/typeorm';
import { compare, hash } from 'bcrypt';
import { User } from '../users/user.entity';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { FirebaseService } from './firebase.service';

@Injectable()
export class AuthService implements OnApplicationBootstrap {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    private readonly jwtService: JwtService,
    private readonly firebaseService: FirebaseService,
  ) {}

  async onApplicationBootstrap() {
    try {
      const existingAdmin = await this.userRepository.findOne({ where: { email: 'admin@jonetsu.com' } });
      if (!existingAdmin) {
        const passwordHash = await hash('Jonetsu2026!', 12);
        const admin = this.userRepository.create({
          email: 'admin@jonetsu.com',
          username: 'admin',
          displayName: 'JōNETSU Admin',
          role: 'admin',
          passwordHash,
          authProvider: 'email',
        });
        await this.userRepository.save(admin);
        console.log('✔ Default admin account auto-created: admin@jonetsu.com / Jonetsu2026!');
      }

      const existingUser = await this.userRepository.findOne({ where: { email: 'otaku@jonetsu.com' } });
      if (!existingUser) {
        const passwordHash = await hash('Jonetsu2026!', 12);
        const user = this.userRepository.create({
          email: 'otaku@jonetsu.com',
          username: 'otaku',
          displayName: 'Otaku Member',
          role: 'user',
          passwordHash,
          authProvider: 'email',
        });
        await this.userRepository.save(user);
        console.log('✔ Default user account auto-created: otaku@jonetsu.com / Jonetsu2026!');
      }
    } catch (e) {
      console.warn('Auto-bootstrap default accounts skipped or already initialized:', e?.message || e);
    }
  }

  async validateUser(email: string, password: string): Promise<User> {
    const user = await this.userRepository.findOne({ where: { email } });
    if (!user || !user.passwordHash) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const isValidPassword = await compare(password, user.passwordHash);
    if (!isValidPassword) {
      throw new UnauthorizedException('Invalid credentials');
    }

    return user;
  }

  async login(dto: LoginDto) {
    const user = await this.validateUser(dto.email, dto.password);
    const payload = { sub: user.id, email: user.email, username: user.username, role: user.role ?? 'user' };
    return {
      accessToken: this.jwtService.sign(payload),
      user: {
        id: user.id,
        email: user.email,
        username: user.username,
        displayName: user.displayName,
        avatarUrl: user.avatarUrl,
        role: user.role ?? 'user',
      },
    };
  }

  async register(dto: RegisterDto) {
    const existing = await this.userRepository.findOne({ where: [{ email: dto.email }, { username: dto.username }] });
    if (existing) {
      throw new UnauthorizedException('Email or username already used');
    }

    const passwordHash = await hash(dto.password, 12);
    const user = this.userRepository.create({
      email: dto.email,
      username: dto.username,
      role: 'user',
      passwordHash,
      displayName: dto.displayName ?? dto.username,
      authProvider: 'email',
    });

    await this.userRepository.save(user);
    return this.login({ email: dto.email, password: dto.password });
  }

  async loginWithFirebase(idToken: string) {
    const decoded = await this.firebaseService.verifyIdToken(idToken);
    const email = decoded.email as string;
    const name = (decoded.name as string | undefined) ?? decoded.email?.split('@')[0] ?? 'akirabot';
    const picture = decoded.picture as string | undefined;

    let user = await this.userRepository.findOne({ where: { email } });
    if (!user) {
      const username = name.replace(/\s+/g, '').toLowerCase().substring(0, 30);
      user = this.userRepository.create({
        email,
        username,
        role: 'user',
        displayName: name,
        avatarUrl: picture,
        authProvider: 'firebase',
      });
      await this.userRepository.save(user);
    }

    const payload = { sub: user.id, email: user.email, username: user.username, role: user.role ?? 'user' };
    return {
      accessToken: this.jwtService.sign(payload),
      user: {
        id: user.id,
        email: user.email,
        username: user.username,
        displayName: user.displayName,
        avatarUrl: user.avatarUrl,
        role: user.role ?? 'user',
      },
    };
  }
}
