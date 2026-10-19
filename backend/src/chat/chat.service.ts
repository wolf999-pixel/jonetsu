import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Chat } from './chat.entity';

@Injectable()
export class ChatService {
  constructor(
    @InjectRepository(Chat)
    private readonly chatRepository: Repository<Chat>,
  ) {}

  async create(chatData: Partial<Chat>): Promise<Chat> {
    const chat = this.chatRepository.create(chatData);
    return await this.chatRepository.save(chat);
  }

  async findAll(): Promise<Chat[]> {
    return await this.chatRepository.find({ relations: ['members'] });
  }

  async findOne(id: string): Promise<Chat | null> {
    return await this.chatRepository.findOne({
      where: { id },
      relations: ['members', 'messages']
    });
  }

  async findUserChats(userId: string): Promise<Chat[]> {
    return await this.chatRepository
      .createQueryBuilder('chat')
      .leftJoin('chat.members', 'user')
      .where('user.id = :userId', { userId })
      .leftJoinAndSelect('chat.members', 'allMembers')
      .getMany();
  }
}
