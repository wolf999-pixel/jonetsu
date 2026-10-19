import { Column, CreateDateColumn, Entity, ManyToOne, PrimaryGeneratedColumn, JoinColumn } from 'typeorm';
import { Character } from './character.entity';

@Entity('duels')
export class Duel {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ name: 'character_a_id', type: 'uuid' })
  characterAId!: string;

  @ManyToOne(() => Character)
  @JoinColumn({ name: 'character_a_id' })
  characterA!: Character;

  @Column({ name: 'character_b_id', type: 'uuid' })
  characterBId!: string;

  @ManyToOne(() => Character)
  @JoinColumn({ name: 'character_b_id' })
  characterB!: Character;

  @Column({ default: 0 })
  votesA!: number;

  @Column({ default: 0 })
  votesB!: number;

  @Column({ type: 'timestamptz' })
  endsAt!: Date;

  @Column({ default: true })
  isActive!: boolean;

  @CreateDateColumn({ type: 'timestamptz' })
  createdAt!: Date;
}
