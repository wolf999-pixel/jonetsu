import { Controller, Get, Param, Query, Post } from '@nestjs/common';
import { StreamingService } from './streaming.service';

@Controller('streaming')
export class StreamingController {
  constructor(private readonly streamingService: StreamingService) {}

  @Get()
  async findAll(
    @Query('q') query?: string,
    @Query('genre') genre?: string,
  ) {
    return await this.streamingService.findAll(query, genre);
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    return await this.streamingService.findOne(id);
  }

  @Post('seed')
  async seed() {
    await this.streamingService.seedInitialAnimes();
    return { success: true };
  }
}
