import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Anime } from './anime.entity';
import { StreamingService } from './streaming.service';
import { StreamingController } from './streaming.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Anime])],
  controllers: [StreamingController],
  providers: [StreamingService],
  exports: [StreamingService],
})
export class StreamingModule {}
