import 'dart:async';

import 'package:fgm_lyrics_app/app/locale/locale_provider.dart';
import 'package:fgm_lyrics_app/app/lyric/lyric_controller.dart';
import 'package:fgm_lyrics_app/core/models/lyric.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _favoriteIdsKey = 'favorite_lyric_ids';

bool _idEquals(dynamic a, dynamic b) =>
    a == b || a.toString().toLowerCase() == b.toString().toLowerCase();

String _idKey(dynamic id) => id.toString();

LanguageEnum _deviceLanguage(Ref ref) =>
    ref.read(deviceLocaleProvider) == LanguageEnum.en.name
    ? LanguageEnum.en
    : LanguageEnum.fr;

/// Language used to display the favorites list (toggled in the favorites screen).
final favoriteViewLanguageProvider =
    NotifierProvider<FavoriteViewLanguageNotifier, LanguageEnum>(
      FavoriteViewLanguageNotifier.new,
    );

class FavoriteViewLanguageNotifier extends Notifier<LanguageEnum> {
  @override
  LanguageEnum build() =>
      ref.watch(deviceLocaleProvider) == LanguageEnum.en.name
      ? LanguageEnum.en
      : LanguageEnum.fr;

  void toggle() {
    state = state == LanguageEnum.en ? LanguageEnum.fr : LanguageEnum.en;
  }

  void setLanguage(LanguageEnum lang) {
    state = lang;
  }
}

class FavoriteNotifier extends Notifier<List<Lyric>> {
  @override
  List<Lyric> build() {
    ref.watch(deviceLocaleProvider);
    ref.watch(favoriteViewLanguageProvider);
    _loadFromPrefs();
    return [];
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_favoriteIdsKey) ?? <String>[];
    final storedKeys = stored.map((e) => e.toLowerCase()).toSet();
    final viewLanguage = ref.read(favoriteViewLanguageProvider);
    final lyrics = viewLanguage == LanguageEnum.en
        ? ref.read(englishHymnProvider).value
        : ref.read(frenchHymnProvider).value;
    if (lyrics == null) return;
    final favoriteLyrics = lyrics
        .where((l) => storedKeys.contains(_idKey(l.id).toLowerCase()))
        .toList();
    state = favoriteLyrics;
  }

  /// Adds a lyric to favorites and persists its id with SharedPreferences.
  Future<void> _addFavorite(dynamic id) async {
    try {
      final lyrics = _deviceLanguage(ref) == LanguageEnum.en
          ? ref.read(englishHymnProvider).value
          : ref.read(frenchHymnProvider).value;
      final lyric = lyrics?.where((l) => _idEquals(l.id, id)).firstOrNull;
      if (lyric == null) throw Exception('Lyric not found');
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(_favoriteIdsKey) ?? <String>[];
      final newIds = {...stored, _idKey(id)};
      await prefs.setStringList(_favoriteIdsKey, newIds.toList());
      ref.invalidate(isFavoriteProvider(_idKey(id)));
      state = [...state, lyric];
    } catch (e) {
      debugPrint('Error adding favorite: ${e.toString()}');
    } finally {
      ref.invalidate(isFavoriteProvider(_idKey(id)));
    }
  }

  Future<void> _removeFavorite(dynamic id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(_favoriteIdsKey) ?? <String>[];
      final key = _idKey(id);
      final newIds =
          stored.where((storedId) => storedId.toLowerCase() != key.toLowerCase()).toList();
      await prefs.setStringList(_favoriteIdsKey, newIds);
      ref.invalidate(isFavoriteProvider(key));
      state = state.where((lyric) => !_idEquals(lyric.id, id)).toList();
    } catch (e) {
      debugPrint('Error removing favorite: ${e.toString()}');
    } finally {
      ref.invalidate(isFavoriteProvider(_idKey(id)));
    }
  }

  Future<void> toggleFavorite(dynamic id) async {
    try {
      final key = _idKey(id);
      final isFavorite = await ref.watch(isFavoriteProvider(key).future);
      isFavorite ? await _removeFavorite(id) : await _addFavorite(id);
    } catch (e) {
      debugPrint('Error toggling favorite: ${e.toString()}');
    } finally {
      ref.invalidate(isFavoriteProvider(_idKey(id)));
    }
  }
}

final favoriteNotifierProvider =
    NotifierProvider<FavoriteNotifier, List<Lyric>>(FavoriteNotifier.new);

final isFavoriteProvider = FutureProvider.family<bool, String>((
  ref,
  String idKey,
) async {
  final prefs = await SharedPreferences.getInstance();
  final stored = prefs.getStringList(_favoriteIdsKey) ?? <String>[];
  return stored.any((s) => s.toLowerCase() == idKey.toLowerCase());
});
