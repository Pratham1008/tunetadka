class Track {
  final String id, title, artist, album, audioFilePath, uploadedAt;
  final int durationSeconds, bitrateKbps;
  final String? coverImageUrl;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.durationSeconds,
    required this.bitrateKbps,
    required this.audioFilePath,
    required this.uploadedAt,
    this.coverImageUrl,
  });

  factory Track.fromJson(Map<String, dynamic> json) => Track(
    id: json['id'],
    title: json['title'],
    artist: json['artist'],
    album: json['album'],
    durationSeconds: json['durationSeconds'],
    bitrateKbps: json['bitrateKbps'],
    audioFilePath: json['audioFilePath'],
    coverImageUrl: json['coverImageUrl'],
    uploadedAt: json['uploadedAt'],
  );
}

class Users {
  final String id, name, email;
  Users({required this.id, required this.name, required this.email});
  factory Users.fromJson(Map<String, dynamic> json) => Users(
    id: json['id'],
    name: json['name'],
    email: json['email'],
  );
}

class Favorite {
  final String id, userId, trackId, favoritedAt;
  Favorite({required this.id, required this.userId, required this.trackId, required this.favoritedAt});
  factory Favorite.fromJson(Map<String, dynamic> json) => Favorite(
    id: json['id'],
    userId: json['userId'],
    trackId: json['trackId'],
    favoritedAt: json['favoritedAt'],
  );
}

class History {
  final String id,  userId, trackId, listenedAt;
  History({required this.id,  required this.userId, required this.trackId, required this.listenedAt});
  factory History.fromJson(Map<String, dynamic> json) => History(
    id: json['id'],
    userId: json['userId'],
    trackId: json['trackId'],
    listenedAt: json['listenedAt'],
  );
}
