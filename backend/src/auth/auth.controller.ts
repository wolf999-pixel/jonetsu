import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { RolesGuard } from './guards/roles.guard';
import { Roles } from './decorators/roles.decorator';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('login')
  async login(@Body() dto: LoginDto) {
    return this.authService.login(dto);
  }

  @Post('register')
  async register(@Body() dto: RegisterDto) {
    return this.authService.register(dto);
  }

  @Post('firebase')
  async firebaseLogin(@Body() body: { idToken: string }) {
    return this.authService.loginWithFirebase(body.idToken);
  }

  @Post('admin-check')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  adminCheck() {
    return { ok: true };
  }
}
