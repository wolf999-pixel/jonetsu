import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AnalyticsEvent } from './event.entity';

@Injectable()
export class AnalyticsService {
  constructor(
    @InjectRepository(AnalyticsEvent)
    private readonly eventRepository: Repository<AnalyticsEvent>,
  ) {}

  async trackEvent(eventType: string, userId?: string, eventValue?: string, metadata: any = {}): Promise<void> {
    const event = this.eventRepository.create({
      eventType,
      userId,
      eventValue,
      metadata,
    });
    await this.eventRepository.save(event);
  }

  async getGlobalStats() {
    const totalViews = await this.eventRepository.count({ where: { eventType: 'page_view' } });
    const totalPlays = await this.eventRepository.count({ where: { eventType: 'video_play' } });

    // Statistiques par type d'événement
    const stats = await this.eventRepository
      .createQueryBuilder('event')
      .select('event.eventType', 'type')
      .addSelect('COUNT(*)', 'count')
      .groupBy('event.eventType')
      .getRawMany();

    return {
      summary: {
        pageViews: totalViews,
        videoPlays: totalPlays,
      },
      details: stats,
    };
  }
}
