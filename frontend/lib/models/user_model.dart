class UserModel {
  final String id;
  final String email;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final String? bannerUrl;
  final String? bio;
  final String? favoriteAnime;
  final String? favoriteCharacter;
  final int otakuLevel;
  final int xp;
  final List<String> badges;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.bannerUrl,
    this.bio,
    this.favoriteAnime,
    this.favoriteCharacter,
    this.otakuLevel = 1,
    this.xp = 0,
    this.badges = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserModel(
        id: json['id']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        username: json['username']?.toString() ?? 'Otaku',
        displayName: json['displayName']?.toString(),
        avatarUrl: json['avatarUrl']?.toString(),
        bannerUrl: json['bannerUrl']?.toString(),
        bio: json['bio']?.toString(),
        favoriteAnime: json['favoriteAnime']?.toString(),
        favoriteCharacter: json['favoriteCharacter']?.toString(),
        otakuLevel: int.tryParse(json['otakuLevel']?.toString() ?? '1') ?? 1,
        xp: int.tryParse(json['xp']?.toString() ?? '0') ?? 0,
        badges: json['badges'] is List ? List<String>.from(json['badges']) : [],
      );
    } catch (e) {
      return UserModel(id: 'error', email: '', username: 'Error');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'bannerUrl': bannerUrl,
      'bio': bio,
      'favoriteAnime': favoriteAnime,
      'favoriteCharacter': favoriteCharacter,
      'otakuLevel': otakuLevel,
      'xp': xp,
      'badges': badges,
    };
  }
}
