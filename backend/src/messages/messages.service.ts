import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Message } from './message.entity';
import { CreateMessageDto } from './dto/create-message.dto';

@Injectable()
export class MessagesService {
  constructor(
    @InjectRepository(Message)
    private readonly messageRepository: Repository<Message>,
  ) {}

  async create(createMessageDto: CreateMessageDto): Promise<Message> {
    const message = this.messageRepository.create(createMessageDto);
    return await this.messageRepository.save(message);
  }

  async findByChatId(chatId: string, limit = 50, offset = 0): Promise<Message[]> {
    return await this.messageRepository.find({
      where: { chatId },
      order: { createdAt: 'DESC' },
      take: limit,
      skip: offset,
      relations: ['sender'],
    });
  }
}
