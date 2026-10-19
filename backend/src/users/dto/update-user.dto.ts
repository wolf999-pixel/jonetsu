import { IsString, IsOptional, MaxLength, IsUrl, MinLength, Matches, IsInt, Min, Max } from 'class-validator';

export class UpdateUserDto {
  @IsString()
  @IsOptional()
  @MinLength(2)
  @MaxLength(100)
  @Matches(/^(?!\s*$).+$/, { message: 'displayName cannot be empty' })
  displayName?: string;

  @IsString()
  @IsOptional()
  @IsUrl()
  avatarUrl?: string;

  @IsString()
  @IsOptional()
  @IsUrl()
  bannerUrl?: string;

  @IsString()
  @IsOptional()
  @MinLength(1)
  @MaxLength(500)
  bio?: string;

  @IsString()
  @IsOptional()
  @MinLength(1)
  @MaxLength(100)
  favoriteAnime?: string;

  @IsString()
  @IsOptional()
  @MinLength(1)
  @MaxLength(100)
  favoriteCharacter?: string;
}

export class UpdateUserLevelDto {
  @IsInt()
  @Min(1)
  @Max(100)
  level!: number;
}
