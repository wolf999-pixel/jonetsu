import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn, Unique } from 'typeorm';

@Entity('duel_votes')
@Unique(['duelId', 'userId'])
export class DuelVote {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ name: 'duel_id', type: 'uuid' })
  duelId!: string;

  @Column({ name: 'user_id', type: 'uuid' })
  userId!: string;

  @Column({ length: 1 }) // 'A' or 'B'
  choice!: string;

  @CreateDateColumn({ type: 'timestamptz' })
  createdAt!: Date;
}
