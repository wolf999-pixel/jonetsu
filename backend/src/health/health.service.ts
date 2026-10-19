import { Injectable } from '@nestjs/common';

@Injectable()
export class HealthService {
  check() {
    return {
      status: 'ok',
      service: 'JōNETSU backend',
      timestamp: new Date().toISOString(),
    };
  }
}
