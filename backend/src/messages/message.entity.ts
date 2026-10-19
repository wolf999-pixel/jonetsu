import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { Chat } from '../chat/chat.entity';
import { User } from '../users/user.entity';

@Entity('messages')
export class Message {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ name: 'chat_id', type: 'uuid' })
  chatId!: string;

  @ManyToOne(() => Chat, (chat) => chat.messages)
  @JoinColumn({ name: 'chat_id' })
  chat!: Chat;

  @Column({ name: 'sender_id', type: 'uuid' })
  senderId!: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'sender_id' })
  sender!: User;

  @Column({ type: 'text', nullable: true })
  content?: string;

  @Column({ type: 'jsonb', default: '[]' })
  attachments!: any[];

  @Column({ length: 30, default: 'text' })
  messageType!: string;

  @Column({ length: 30, default: 'sent' })
  status!: string;

  @Column({ default: false })
  isEphemeral!: boolean;

  @Column({ type: 'uuid', nullable: true })
  repliedTo?: string;

  @CreateDateColumn({ type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ type: 'timestamptz' })
  updatedAt!: Date;
}
