import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fgm_lyrics_app/app/harmonyforge/harmonyforge_sync_service.dart';
import 'package:fgm_lyrics_app/core/models/harmony_forge_hymn.dart';
import 'package:fgm_lyrics_app/core/models/lyric.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Thrown when hymns cannot be loaded from any source.
class LyricsUnavailableException implements Exception {
  const LyricsUnavailableException(this.message);
  final String message;

  @override
  String toString() => 'LyricsUnavailableException: $message';
}

/// Firestore collection name for hymns (must match HarmonyForge dashboard).
const String kSongsCollectionId = 'songs';

/// Loads lyrics using a Firestore-first strategy.
///
/// Priority on every launch: Firestore → local cache → bundled asset.
class LyricRepository {
  LyricRepository({
    HarmonyForgeSyncService? harmonyForgeSync,
    FirebaseFirestore? firestore,
  }) : _cache = harmonyForgeSync ?? HarmonyForgeSyncService(),
       _firestore = firestore ?? FirebaseFirestore.instance;

  final HarmonyForgeSyncService _cache;
  final FirebaseFirestore _firestore;

  /// How long to wait for a Firestore response before falling back to cache.
  static const Duration _firestoreTimeout = Duration(seconds: 10);

  /// Fetches all hymns from Firestore in HarmonyForge shape.
  ///
  /// Forces a server fetch (bypasses Firestore's internal cache) and times out
  /// after [_firestoreTimeout] so the app never hangs on a slow connection.
  Future<List<HarmonyForgeHymn>> fetchFromFirestore() async {
    final snapshot = await _firestore
        .collection(kSongsCollectionId)
        .get(const GetOptions(source: Source.server))
        .timeout(_firestoreTimeout);
    return snapshot.docs.map((doc) {
      final data = doc.data();
      final map = Map<String, dynamic>.from(data);
      if (!map.containsKey('id')) map['id'] = doc.id;
      return HarmonyForgeHymn.fromJson(map);
    }).toList();
  }

  /// Saves hymns to local cache (HarmonyForge export format: root array).
  Future<void> _saveToCacheHymns(List<HarmonyForgeHymn> hymns) async {
    try {
      final list = hymns.map((h) => h.toJson()).toList();
      await _cache.saveToLocalAsArray(list);
    } catch (_) {}
  }

  /// Loads from the local HarmonyForge cache.
  ///
  /// Returns null when the cache is absent, invalid, or version-mismatched.
  Future<List<Lyric>?> _loadFromCache({required bool french}) async {
    final raw = await _cache.readLocalExport();
    if (raw == null) return null;
    try {
      final hymns = raw
          .map(
            (e) =>
                HarmonyForgeHymn.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
      return hymns.map((h) => Lyric.fromHarmonyForge(h, french)).toList();
    } catch (_) {
      return null;
    }
  }

  Future<List<Lyric>?> _loadFromAssetHarmonyForge({
    required bool french,
  }) async {
    try {
      final response = await rootBundle.loadString('assets/harmonyforge.json');
      final raw = jsonDecode(response);
      if (raw is! List) return null;
      final hymns = raw
          .map(
            (e) =>
                HarmonyForgeHymn.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
      return hymns.map((h) => Lyric.fromHarmonyForge(h, french)).toList();
    } catch (_) {
      return null;
    }
  }

  Future<List<Lyric>> loadEnglishLyrics() => _loadLyrics(french: false);

  Future<List<Lyric>> loadFrenchLyrics() => _loadLyrics(french: true);

  /// Firestore-first load: Firestore → local cache → bundled asset.
  ///
  /// On success, the fresh Firestore data is saved to the local cache in the
  /// background so subsequent offline launches stay up-to-date.
  /// The returned list is sorted ascending by hymn number; hymns without a
  /// number are placed at the end.
  /// Throws [LyricsUnavailableException] only if all three sources fail.
  Future<List<Lyric>> _loadLyrics({required bool french}) async {
    try {
      final hymns = await fetchFromFirestore();
      unawaited(_saveToCacheHymns(hymns));
      return _sorted(
        hymns.map((h) => Lyric.fromHarmonyForge(h, french)).toList(),
      );
    } catch (_) {
      final cached = await _loadFromCache(french: french);
      if (cached != null && cached.isNotEmpty) return _sorted(cached);

      final fromAsset = await _loadFromAssetHarmonyForge(french: french);
      if (fromAsset != null && fromAsset.isNotEmpty) return _sorted(fromAsset);

      throw const LyricsUnavailableException(
        'Firestore unreachable, no local cache, and bundled asset failed.',
      );
    }
  }

  /// Sorts [lyrics] ascending by [Lyric.songId].
  /// Hymns with no number (songId == 0) are placed after numbered ones.
  List<Lyric> _sorted(List<Lyric> lyrics) {
    return lyrics..sort((a, b) {
      if (a.songId == 0 && b.songId == 0) return 0;
      if (a.songId == 0) return 1;
      if (b.songId == 0) return -1;
      return a.songId.compareTo(b.songId);
    });
  }
}

final harmonyForgeSyncServiceProvider = Provider<HarmonyForgeSyncService>(
  (ref) => HarmonyForgeSyncService(),
);

final lyricRepositoryProvider = Provider<LyricRepository>(
  (ref) => LyricRepository(
    harmonyForgeSync: ref.watch(harmonyForgeSyncServiceProvider),
  ),
);
