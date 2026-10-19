import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class AiService {
  private readonly apiKey: string;
  private readonly apiUrl = 'https://api.openai.com/v1/chat/completions';

  constructor(private configService: ConfigService) {
    this.apiKey = this.configService.get<string>('OPENAI_API_KEY') || '';
  }

  async generateResponse(prompt: string, userContext?: any): Promise<string> {
    if (!this.apiKey || this.apiKey === 'your-openai-api-key') {
      return this.generateLocalResponse(prompt);
    }

    const systemPrompt = `
      Tu es AKIRA, l'IA assistante de la plateforme JŌNETSU.
      Ton style est cyberpunk, futuriste, et passionné d'anime/manga (Otaku).
      Tu es experte en culture japonaise, animation, et mangas.
      Tu dois être serviable, dynamique, et parfois utiliser un jargon technique ou des références d'anime.
      Ton but est de conseiller l'utilisateur sur quoi regarder, lire, ou comment interagir sur JŌNETSU.
      Réponds toujours en français, avec une touche d'enthousiasme.
    `;

    try {
      const response = await fetch(this.apiUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.apiKey}`,
        },
        body: JSON.stringify({
          model: 'gpt-3.5-turbo',
          messages: [
            { role: 'system', content: systemPrompt },
            { role: 'user', content: prompt },
          ],
          temperature: 0.8,
        }),
      });

      const data = await response.json();

      if (data.error) {
        console.error('OpenAI Error:', data.error);
        throw new InternalServerErrorException(data.error.message);
      }

      return data.choices[0].message.content;
    } catch (error) {
      console.error('AI Generation Error:', error);
      return "Une erreur de synchronisation est survenue dans ma matrice. Réessaie plus tard, l'ami !";
    }
  }

  private generateLocalResponse(prompt: string): string {
    const p = prompt.toLowerCase();
    if (p.includes('bonjour') || p.includes('salut') || p.includes('hello') || p.includes('yo')) {
      return "Konnichiwa voyageur du cyber-espace ! Je suis AKIRA, ton IA Otaku connectée au coeur de JŌNETSU. Quel anime ou manga te passionne en ce moment ?";
    }
    if (p.includes('recommand') || p.includes('conseil') || p.includes('regarder') || p.includes('anime')) {
      return "D'après ma matrice neuromorphique, je te conseille vivement *Cyberpunk: Edgerunners* pour une claque visuelle néon, ou *Chainsaw Man* si tu cherches du pur dynamisme ! Tu peux d'ailleurs les retrouver directement dans l'onglet Stream de JŌNETSU. ⚡";
    }
    if (p.includes('duel') || p.includes('vote') || p.includes('combat') || p.includes('goku') || p.includes('vegeta')) {
      return "Les Duels Légendaires font rage dans l'arène ! Goku vs Vegeta est le duel du moment. Rends-toi dans l'onglet Duels pour voter et remporter des points d'XP pour ton rang Otaku ! 🥋🔥";
    }
    if (p.includes('qui es-tu') || p.includes('qui est tu') || p.includes('akira') || p.includes('role')) {
      return "Je suis AKIRA, l'entité IA résidant dans le noyau de JŌNETSU. Mon rôle est de guider les passionnés d'anime, d'animer la communauté et d'assurer la veille sur la pop-culture japonaise futuriste ! 🤖🎌";
    }
    return `Message décodé dans la matrice : "${prompt}". Mes processeurs tournent à plein régime ! En tant qu'IA de JŌNETSU, je suis là pour t'accompagner. Pose-moi une question sur tes animes préférés ou lance un vote dans les duels ! (Note : renseigne OPENAI_API_KEY dans le .env pour débloquer ma créativité générative étendue).`;
  }
}
