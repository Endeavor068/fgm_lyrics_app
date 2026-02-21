import 'package:flutter/foundation.dart';

class Lyric {
  final dynamic id;
  final String songTitle;
  final int songId;
  final String chorus;
  final String key;
  final String author;
  final List<String> enLyrics;
  const Lyric({
    this.songTitle = '',
    this.songId = 0,
    required this.id,
    this.chorus = '',
    this.key = '',
    this.author = '',
    this.enLyrics = const [],
  });

  Lyric copyWith({
    String? songTitle,
    int? songId,
    dynamic id,
    String? chorus,
    String? key,
    String? author,
    List<String>? enLyrics,
  }) {
    return Lyric(
      songTitle: songTitle ?? this.songTitle,
      songId: songId ?? this.songId,
      id: id ?? this.id,
      chorus: chorus ?? this.chorus,
      key: key ?? this.key,
      author: author ?? this.author,
      enLyrics: enLyrics ?? this.enLyrics,
    );
  }

  factory Lyric.fromJson(Map<String, dynamic> json) {
    return Lyric(
      songTitle: json['songTitle'],
      songId: json['songId'],
      id: json['id'],
      chorus: json['chorus'],
      key: json['key'],
      author: json['author'],
      enLyrics: List<String>.from(json['enLyrics']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'songTitle': songTitle,
      'songId': songId,
      'id': id,
      'chorus': chorus,
      'key': key,
      'author': author,
      'enLyrics': enLyrics,
    };
  }

  @override
  String toString() {
    return '''Lyric(songTitle: $songTitle, songId: $songId, id: $id, chorus: $chorus, key: $key, author: $author, enLyrics: $enLyrics)''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Lyric &&
        other.songTitle == songTitle &&
        other.songId == songId &&
        other.id == id &&
        other.chorus == chorus &&
        other.key == key &&
        other.author == author &&
        listEquals(other.enLyrics, enLyrics);
  }

  @override
  int get hashCode {
    return songTitle.hashCode ^
        songId.hashCode ^
        id.hashCode ^
        chorus.hashCode ^
        key.hashCode ^
        author.hashCode ^
        enLyrics.hashCode;
  }
}
