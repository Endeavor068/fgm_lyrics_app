import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Manages the local HarmonyForge lyrics cache (JSON file in app documents).
///
/// The cache file is versioned. Increment [_cacheVersion] whenever the
/// [HarmonyForgeContent] model gains new fields so stale caches are
/// automatically invalidated instead of silently serving incomplete data.
class HarmonyForgeSyncService {
  HarmonyForgeSyncService({this.fileNamePrefix = 'harmonyforge'});

  final String fileNamePrefix;

  static const String _exportFileName = 'harmonyforge_export.json';

  /// Bump this whenever fields are added/removed from [HarmonyForgeContent].
  /// Any cached file written with a different version is discarded.
  static const int _cacheVersion = 3;

  Future<File> _cacheFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File(p.join(directory.path, _exportFileName));
  }

  /// Reads the cached hymn list.
  ///
  /// Returns null when the file is absent, unreadable, or was written by a
  /// different [_cacheVersion] (triggering a fresh load from Firestore).
  Future<List<dynamic>?> readLocalExport() async {
    final file = await _cacheFile();
    if (!file.existsSync()) return null;
    try {
      final raw = jsonDecode(await file.readAsString());
      if (raw is! Map<String, dynamic>) return null;
      if (raw['version'] != _cacheVersion) {
        await file.delete();
        return null;
      }
      final data = raw['data'];
      return data is List ? data : null;
    } catch (_) {
      return null;
    }
  }

  /// Saves [items] to the local cache tagged with the current [_cacheVersion].
  Future<void> saveToLocalAsArray(List<dynamic> items) async {
    final file = await _cacheFile();
    final payload = <String, dynamic>{'version': _cacheVersion, 'data': items};
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
      flush: true,
    );
  }

  /// Deletes the local cache file, forcing a fresh load on the next launch.
  Future<void> clearCache() async {
    final file = await _cacheFile();
    if (file.existsSync()) await file.delete();
  }
}
