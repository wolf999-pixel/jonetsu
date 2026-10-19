class AnimeEpisode {
  final String title;
  final String url;
  final int number;

  AnimeEpisode({required this.title, required this.url, required this.number});

  factory AnimeEpisode.fromJson(Map<String, dynamic> json) {
    return AnimeEpisode(
      title: json['title'],
      url: json['url'],
      number: json['number'],
    );
  }
}

class AnimeModel {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? genre;
  final double rating;
  final int releaseYear;
  final String status;
  final List<AnimeEpisode> episodes;

  AnimeModel({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.genre,
    required this.rating,
    required this.releaseYear,
    required this.status,
    required this.episodes,
  });

  factory AnimeModel.fromJson(Map<String, dynamic> json) {
    return AnimeModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      genre: json['genre'],
      rating: (json['rating'] as num).toDouble(),
      releaseYear: json['releaseYear'],
      status: json['status'],
      episodes: (json['episodes'] as List)
          .map((e) => AnimeEpisode.fromJson(e))
          .toList(),
    );
  }
}
