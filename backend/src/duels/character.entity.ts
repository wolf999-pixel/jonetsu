import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity('characters')
export class Character {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ length: 100 })
  name!: string;

  @Column({ length: 100 })
  anime!: string;

  @Column({ type: 'text', nullable: true })
  imageUrl?: string;

  @Column({ type: 'text', nullable: true })
  description?: string;
}
