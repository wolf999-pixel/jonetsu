import { Column, Entity, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity('animes')
export class Anime {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ length: 255 })
  title!: string;

  @Column({ type: 'text', nullable: true })
  description?: string;

  @Column({ type: 'text', nullable: true })
  imageUrl?: string;

  @Column({ length: 100, nullable: true })
  genre?: string;

  @Column({ type: 'float', default: 0 })
  rating!: number;

  @Column({ type: 'int', default: 0 })
  releaseYear!: number;

  @Column({ length: 50, default: 'ongoing' }) // 'ongoing', 'completed'
  status!: string;

  @Column({ type: 'jsonb', default: '[]' })
  episodes!: { title: string; url: string; number: number }[];

  @CreateDateColumn({ type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ type: 'timestamptz' })
  updatedAt!: Date;
}
