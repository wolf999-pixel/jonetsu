import { IsString, IsUUID, IsOptional, IsArray, IsBoolean } from 'class-validator';

export class CreateMessageDto {
  @IsUUID()
  chatId!: string;

  @IsUUID()
  senderId!: string;

  @IsString()
  @IsOptional()
  content?: string;

  @IsArray()
  @IsOptional()
  attachments?: any[];

  @IsString()
  @IsOptional()
  messageType?: string;

  @IsBoolean()
  @IsOptional()
  isEphemeral?: boolean;

  @IsUUID()
  @IsOptional()
  repliedTo?: string;
}
