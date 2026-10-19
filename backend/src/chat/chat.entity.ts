import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn, UpdateDateColumn, OneToMany, ManyToMany, JoinTable } from 'typeorm';
import { Message } from '../messages/message.entity';
import { User } from '../users/user.entity';

@Entity('chats')
export class Chat {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ name: 'is_group', default: false })
  isGroup!: boolean;

  @Column({ length: 150, nullable: true })
  name?: string;

  @Column({ type: 'jsonb', default: '{}' })
  metadata!: any;

  @OneToMany(() => Message, (message) => message.chat)
  messages!: Message[];

  @ManyToMany(() => User)
  @JoinTable({
    name: 'chat_members',
    joinColumn: { name: 'chat_id', referencedColumnName: 'id' },
    inverseJoinColumn: { name: 'user_id', referencedColumnName: 'id' },
  })
  members!: User[];

  @CreateDateColumn({ type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ type: 'timestamptz' })
  updatedAt!: Date;
}
