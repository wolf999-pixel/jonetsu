import { Injectable } from '@nestjs/common';
import * as admin from 'firebase-admin';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../users/user.entity';

@Injectable()
export class NotificationsService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  async sendNotification(userId: string, title: string, body: string, data?: any) {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user || !user.fcmToken) {
      console.log(`Notification non envoyée : Aucun token FCM pour l'utilisateur ${userId}`);
      return;
    }

    const message: admin.messaging.Message = {
      notification: {
        title,
        body,
      },
      data: data || {},
      token: user.fcmToken,
    };

    try {
      await admin.messaging().send(message);
      console.log(`Notification envoyée avec succès à ${user.username}`);
    } catch (error) {
      console.error('Erreur lors de l\'envoi de la notification :', error);
    }
  }

  async broadcastNotification(title: string, body: string, data?: any) {
    // Dans une version réelle, on utiliserait les topics FCM pour plus d'efficacité
    const users = await this.userRepository.find({ where: { fcmToken: undefined } }); // Filtre simplifié
    // Pour l'exemple, on envoie à tous ceux qui ont un token
    const tokens = (await this.userRepository.find())
      .map(u => u.fcmToken)
      .filter(t => !!t) as string[];

    if (tokens.length === 0) return;

    const message: admin.messaging.MulticastMessage = {
      notification: { title, body },
      data: data || {},
      tokens: tokens,
    };

    try {
      await admin.messaging().sendEachForMulticast(message);
    } catch (error) {
      console.error('Erreur lors du broadcast :', error);
    }
  }
}
