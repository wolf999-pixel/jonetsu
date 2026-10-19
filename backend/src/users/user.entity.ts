import { Column, CreateDateColumn, Entity, Index, PrimaryGeneratedColumn, UpdateDateColumn, ManyToMany } from 'typeorm';
import { Chat } from '../chat/chat.entity';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Index({ unique: true })
  @Column({ length: 255 })
  email!: string;

  @Index({ unique: true })
  @Column({ length: 50 })
  username!: string;

  @Column({ type: 'varchar', length: 20, default: 'user' })
  role!: 'user' | 'admin';

  @Column({ name: 'display_name', length: 100, nullable: true })
  displayName?: string;

  @Column({ name: 'avatar_url', type: 'text', nullable: true })
  avatarUrl?: string;

  @Column({ name: 'banner_url', type: 'text', nullable: true })
  bannerUrl?: string;

  @Column({ type: 'text', nullable: true })
  bio?: string;

  @Column({ name: 'favorite_anime', length: 100, nullable: true })
  favoriteAnime?: string;

  @Column({ name: 'favorite_character', length: 100, nullable: true })
  favoriteCharacter?: string;

  @Column({ name: 'otaku_level', default: 1 })
  otakuLevel!: number;

  @Column({ default: 0 })
  xp!: number;

  @Column({ type: 'jsonb', default: '[]' })
  badges!: string[];

  @Column({ name: 'password_hash', type: 'text', nullable: true })
  passwordHash?: string;

  @Column({ name: 'auth_provider', length: 50, default: 'email' })
  authProvider!: string;

  @Column({ name: 'fcm_token', type: 'text', nullable: true })
  fcmToken?: string;

  @ManyToMany(() => Chat, (chat) => chat.members)
  chats!: Chat[];

  @CreateDateColumn({ type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ type: 'timestamptz' })
  updatedAt!: Date;
}
