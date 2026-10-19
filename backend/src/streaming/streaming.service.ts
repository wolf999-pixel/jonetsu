import { Injectable, NotFoundException, OnModuleInit } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Like } from 'typeorm';
import { Anime } from './anime.entity';

@Injectable()
export class StreamingService implements OnModuleInit {
  constructor(
    @InjectRepository(Anime)
    private readonly animeRepository: Repository<Anime>,
  ) {}

  async onModuleInit() {
    await this.seedInitialAnimes();
  }

  async findAll(query?: string, genre?: string): Promise<Anime[]> {
    const where: any = {};
    if (query) {
      where.title = Like(`%${query}%`);
    }
    if (genre) {
      where.genre = genre;
    }
    return await this.animeRepository.find({ where, order: { rating: 'DESC' } });
  }

  async findOne(id: string): Promise<Anime> {
    const anime = await this.animeRepository.findOne({ where: { id } });
    if (!anime) throw new NotFoundException('Anime non trouvé');
    return anime;
  }

  async seedInitialAnimes() {
    const count = await this.animeRepository.count();
    if (count === 0) {
      await this.animeRepository.save([
        {
          title: 'Cyberpunk: Edgerunners',
          description: 'Dans une dystopie rongée par la corruption et les cyber-implants...',
          genre: 'Cyberpunk',
          rating: 4.9,
          releaseYear: 2022,
          imageUrl: 'https://images.api-anime.com/edgerunners.jpg',
          episodes: [
            { title: 'Episode 1', url: 'https://video.link/1', number: 1 },
            { title: 'Episode 2', url: 'https://video.link/2', number: 2 },
          ]
        },
        {
          title: 'Chainsaw Man',
          description: 'Denji est un jeune homme pauvre qui travaille comme chasseur de démons...',
          genre: 'Action',
          rating: 4.8,
          releaseYear: 2022,
          imageUrl: 'https://images.api-anime.com/chainsawman.jpg',
          episodes: [
            { title: 'Episode 1', url: 'https://video.link/c1', number: 1 },
          ]
        }
      ]);
    }
  }
}
