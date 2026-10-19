import { Column, CreateDateColumn, Entity, ManyToOne, PrimaryGeneratedColumn, UpdateDateColumn, JoinColumn } from 'typeorm';
import { User } from '../users/user.entity';

@Entity('posts')
export class Post {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ name: 'author_id', type: 'uuid' })
  authorId!: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'author_id' })
  author!: User;

  @Column({ type: 'text' })
  content!: string;

  @Column({ type: 'jsonb', default: '[]' })
  mediaUrls!: string[];

  @Column({ default: 0 })
  likesCount!: number;

  @Column({ default: 0 })
  commentsCount!: number;

  @Column({ type: 'jsonb', default: '[]' })
  tags!: string[];

  @CreateDateColumn({ type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ type: 'timestamptz' })
  updatedAt!: Date;
}
