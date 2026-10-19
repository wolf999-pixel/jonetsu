class CharacterModel {
  final String id;
  final String name;
  final String anime;
  final String? imageUrl;

  CharacterModel({
    required this.id,
    required this.name,
    required this.anime,
    this.imageUrl,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    return CharacterModel(
      id: json['id'],
      name: json['name'],
      anime: json['anime'],
      imageUrl: json['imageUrl'],
    );
  }
}

class DuelModel {
  final String id;
  final CharacterModel characterA;
  final CharacterModel characterB;
  final int votesA;
  final int votesB;
  final DateTime endsAt;
  final bool isActive;

  DuelModel({
    required this.id,
    required this.characterA,
    required this.characterB,
    required this.votesA,
    required this.votesB,
    required this.endsAt,
    required this.isActive,
  });

  factory DuelModel.fromJson(Map<String, dynamic> json) {
    return DuelModel(
      id: json['id'],
      characterA: CharacterModel.fromJson(json['characterA']),
      characterB: CharacterModel.fromJson(json['characterB']),
      votesA: json['votesA'],
      votesB: json['votesB'],
      endsAt: DateTime.parse(json['endsAt']),
      isActive: json['isActive'],
    );
  }

  double get percentA {
    if (votesA + votesB == 0) return 0.5;
    return votesA / (votesA + votesB);
  }

  double get percentB {
    if (votesA + votesB == 0) return 0.5;
    return votesB / (votesA + votesB);
  }
}
