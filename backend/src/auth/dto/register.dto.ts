import { IsEmail, IsNotEmpty, MinLength } from 'class-validator';

export class RegisterDto {
  @IsEmail()
  email!: string;

  @IsNotEmpty()
  @MinLength(3)
  username!: string;

  @IsNotEmpty()
  @MinLength(8)
  password!: string;

  displayName?: string;
}
