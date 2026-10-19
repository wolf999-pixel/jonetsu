import { Column, Entity, PrimaryGeneratedColumn, CreateDateColumn } from 'typeorm';

@Entity('analytics_events')
export class AnalyticsEvent {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ length: 100 })
  eventType!: string; // 'page_view', 'click', 'search', 'video_play'

  @Column({ length: 255, nullable: true })
  eventValue?: string;

  @Column('uuid', { nullable: true })
  userId?: string;

  @Column({ type: 'jsonb', default: '{}' })
  metadata!: any;

  @CreateDateColumn({ type: 'timestamptz' })
  createdAt!: Date;
}
