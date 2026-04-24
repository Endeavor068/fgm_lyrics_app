import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Describes why a media download failed.
enum MediaDownloadFailure {
  /// The hymn has no URL configured for this media type.
  noUrl,

  /// The URL string is malformed and cannot be parsed.
  invalidUrl,

  /// The device has no internet connection.
  noInternet,

  /// The server refused access (HTTP 401 or 403).
  forbidden,

  /// The remote file was not found (HTTP 404).
  notFound,

  /// The server returned an unexpected non-200 response.
  serverError,
}

/// Thrown by [HarmonyForgeMediaService] when a download cannot proceed.
class MediaDownloadException implements Exception {
  /// Creates a [MediaDownloadException] with the given [failure] reason.
  const MediaDownloadException(this.failure, {this.statusCode});

  /// Why the download failed.
  final MediaDownloadFailure failure;

  /// HTTP status code when [failure] is [MediaDownloadFailure.serverError].
  final int? statusCode;

  @override
  String toString() =>
      'MediaDownloadException(${failure.name}, '
      'statusCode: $statusCode)';
}

/// Downloads hymn audio and partition files from direct URLs.
///
/// Files are stored in the app's documents directory, keyed by hymn number
/// and [contentLanguage] (e.g. `en` / `fr`) so each locale can cache different
/// assets:
/// - Audio:
///   `{appDocumentsDir}/songs/song_{songNumber}_{contentLanguage}.mp3`
/// - Partition:
///   `{appDocumentsDir}/partitions/partition_{songNumber}_{contentLanguage}.{ext}`
///   where `{ext}` is inferred from the remote URL (pdf, png, jpg, jpeg, webp).
class HarmonyForgeMediaService {
  HarmonyForgeMediaService({
    this.audioSubdir = 'songs',
    this.partitionSubdir = 'partitions',
    this.audioExtension = 'mp3',
  });

  final String audioSubdir;
  final String partitionSubdir;
  final String audioExtension;

  /// All partition file extensions the service recognises.
  static const List<String> supportedPartitionExtensions = [
    'pdf',
    'png',
    'jpg',
    'jpeg',
    'webp',
  ];

  /// Extracts the file extension from [url], defaulting to `pdf`.
  static String partitionExtensionFromUrl(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? '';
    return supportedPartitionExtensions.firstWhere(
      (ext) => path.endsWith('.$ext'),
      orElse: () => 'pdf',
    );
  }

  static String _normalizedLanguage(String contentLanguage) {
    final raw = contentLanguage.trim().toLowerCase();
    if (raw.isEmpty) return 'en';
    final safe = raw.replaceAll(RegExp(r'[^a-z0-9_-]'), '');
    return safe.isEmpty ? 'en' : safe;
  }

  /// Returns the local file path if a valid (non-empty) audio file for
  /// [songNumber] is cached, else null.
  ///
  /// A zero-byte file — left by a previously interrupted download — is
  /// treated as absent and deleted automatically.
  Future<String?> getLocalAudioPath(
    int songNumber,
    String contentLanguage,
  ) async {
    final dir = await _getSongsDirectory();
    final file = File(_audioFilePath(dir.path, songNumber, contentLanguage));
    final path = await _validPathOrNull(file);
    if (path != null) return path;
    final legacy = File('${dir.path}/song_$songNumber.$audioExtension');
    return _validPathOrNull(legacy);
  }

  /// Returns the local file path if a valid (non-empty) partition for
  /// [songNumber] is cached in any supported format, else null.
  ///
  /// Checks every extension in [supportedPartitionExtensions] so that files
  /// downloaded as PDF, PNG, JPG, or WEBP are all discovered.
  /// A zero-byte file is treated as absent and deleted automatically.
  Future<String?> getLocalPartitionPath(
    int songNumber,
    String contentLanguage,
  ) async {
    final dir = await _getPartitionsDirectory();
    final lang = _normalizedLanguage(contentLanguage);
    for (final ext in supportedPartitionExtensions) {
      final file = File('${dir.path}/partition_${songNumber}_$lang.$ext');
      final valid = await _validPathOrNull(file);
      if (valid != null) return valid;
    }
    for (final ext in supportedPartitionExtensions) {
      final legacy = File('${dir.path}/partition_$songNumber.$ext');
      final valid = await _validPathOrNull(legacy);
      if (valid != null) return valid;
    }
    return null;
  }

  /// Returns [file.path] when the file exists and has content; otherwise
  /// deletes any leftover empty file and returns null.
  Future<String?> _validPathOrNull(File file) async {
    if (!file.existsSync()) return null;
    if (file.lengthSync() == 0) {
      await file.delete();
      return null;
    }
    return file.path;
  }

  /// Downloads audio from [audioUrl] and returns the local file path.
  ///
  /// The file is stored as `song_{songNumber}.mp3`.
  ///
  /// Throws [MediaDownloadException] with:
  /// - [MediaDownloadFailure.noUrl] when [audioUrl] is empty.
  /// - [MediaDownloadFailure.invalidUrl] when [audioUrl] is malformed.
  /// - [MediaDownloadFailure.noInternet] when the device is offline.
  /// - [MediaDownloadFailure.forbidden] on HTTP 401/403.
  /// - [MediaDownloadFailure.notFound] on HTTP 404.
  /// - [MediaDownloadFailure.serverError] on any other non-200 response.
  Future<String> downloadAudio(
    int songNumber,
    String audioUrl,
    String contentLanguage,
  ) async {
    _assertUrl(audioUrl);
    final dir = await _getSongsDirectory();
    final localPath = _audioFilePath(dir.path, songNumber, contentLanguage);
    await _downloadToFile(audioUrl, localPath);
    return localPath;
  }

  /// Downloads partition from [partitionUrl] and returns the local file path.
  ///
  /// The file extension is inferred from the URL path (pdf, png, jpg, jpeg,
  /// webp). Falls back to `pdf` when the extension cannot be determined.
  ///
  /// Throws [MediaDownloadException] with the same cases as [downloadAudio].
  Future<String> downloadPartition(
    int songNumber,
    String partitionUrl,
    String contentLanguage,
  ) async {
    _assertUrl(partitionUrl);
    final ext = partitionExtensionFromUrl(partitionUrl);
    final dir = await _getPartitionsDirectory();
    final lang = _normalizedLanguage(contentLanguage);
    final localPath = '${dir.path}/partition_${songNumber}_$lang.$ext';
    await _downloadToFile(partitionUrl, localPath);
    return localPath;
  }

  void _assertUrl(String url) {
    if (url.trim().isEmpty) {
      throw const MediaDownloadException(MediaDownloadFailure.noUrl);
    }
  }

  Future<void> _downloadToFile(String url, String localPath) async {
    final Uri uri;
    try {
      uri = Uri.parse(url);
    } on FormatException {
      throw const MediaDownloadException(MediaDownloadFailure.invalidUrl);
    }

    try {
      final response = await http.get(uri);
      switch (response.statusCode) {
        case 200:
          await File(localPath).writeAsBytes(response.bodyBytes);
        case 401 || 403:
          throw MediaDownloadException(
            MediaDownloadFailure.forbidden,
            statusCode: response.statusCode,
          );
        case 404:
          throw MediaDownloadException(
            MediaDownloadFailure.notFound,
            statusCode: response.statusCode,
          );
        default:
          throw MediaDownloadException(
            MediaDownloadFailure.serverError,
            statusCode: response.statusCode,
          );
      }
    } on MediaDownloadException {
      rethrow;
    } on SocketException {
      throw const MediaDownloadException(MediaDownloadFailure.noInternet);
    }
  }

  Future<Directory> _getSongsDirectory() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/$audioSubdir');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<Directory> _getPartitionsDirectory() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/$partitionSubdir');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Deletes all downloaded audio files from device storage.
  Future<void> clearDownloadedAudio() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/$audioSubdir');
    if (await dir.exists()) await dir.delete(recursive: true);
  }

  /// Deletes all downloaded partition files from device storage.
  Future<void> clearDownloadedPartitions() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/$partitionSubdir');
    if (await dir.exists()) await dir.delete(recursive: true);
  }

  String _audioFilePath(
    String dirPath,
    int songNumber,
    String contentLanguage,
  ) {
    final lang = _normalizedLanguage(contentLanguage);
    return '$dirPath/song_${songNumber}_$lang.$audioExtension';
  }
}

final harmonyForgeMediaServiceProvider = Provider<HarmonyForgeMediaService>(
  (ref) => HarmonyForgeMediaService(),
);
