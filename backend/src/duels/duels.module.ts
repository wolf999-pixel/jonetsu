import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Duel } from './duel.entity';
import { Character } from './character.entity';
import { DuelVote } from './vote.entity';
import { DuelsService } from './duels.service';
import { DuelsController } from './duels.controller';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Duel, Character, DuelVote]),
    UsersModule,
  ],
  controllers: [DuelsController],
  providers: [DuelsService],
  exports: [DuelsService],
})
export class DuelsModule {}
