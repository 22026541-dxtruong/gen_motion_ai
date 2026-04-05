import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VideoDownloadResult {
  const VideoDownloadResult({
    required this.filePath,
    required this.fileName,
  });

  final String filePath;
  final String fileName;
}

class VideoDownloadService {
  VideoDownloadService(this._dio);

  final Dio _dio;

  Future<VideoDownloadResult> downloadVideo({
    required String url,
    String? suggestedFileName,
    String? mimeType,
  }) async {
    final directory = await _resolveDirectory();
    final fileName = _resolveFileName(
      suggestedFileName: suggestedFileName,
      mimeType: mimeType,
      url: url,
    );
    final filePath = '${directory.path}${Platform.pathSeparator}$fileName';

    await _dio.download(
      url,
      filePath,
      options: Options(
        receiveTimeout: const Duration(minutes: 10),
        sendTimeout: const Duration(minutes: 10),
      ),
      deleteOnError: true,
    );

    return VideoDownloadResult(
      filePath: filePath,
      fileName: fileName,
    );
  }

  Future<Directory> _resolveDirectory() async {
    final downloadsDir = Directory(
      '${Directory.systemTemp.path}${Platform.pathSeparator}gen_motion_downloads',
    );
    if (!downloadsDir.existsSync()) {
      downloadsDir.createSync(recursive: true);
    }
    return downloadsDir;
  }

  String _resolveFileName({
    String? suggestedFileName,
    String? mimeType,
    required String url,
  }) {
    final extension = _resolveExtension(mimeType, url);
    final fallbackBaseName = 'gen_motion_video_${DateTime.now().millisecondsSinceEpoch}';
    final rawBaseName =
        (suggestedFileName?.trim().isNotEmpty ?? false)
            ? suggestedFileName!.trim()
            : fallbackBaseName;

    final sanitizedBaseName = rawBaseName
        .replaceAll(RegExp(r'[<>:"/\\|?*]+'), '_')
        .replaceAll(RegExp(r'\s+'), '_');

    if (sanitizedBaseName.toLowerCase().endsWith('.$extension')) {
      return sanitizedBaseName;
    }
    return '$sanitizedBaseName.$extension';
  }

  String _resolveExtension(String? mimeType, String url) {
    final lowerMimeType = mimeType?.toLowerCase();
    if (lowerMimeType == 'video/mp4') {
      return 'mp4';
    }
    if (lowerMimeType == 'video/webm') {
      return 'webm';
    }
    if (lowerMimeType == 'video/quicktime') {
      return 'mov';
    }

    final uri = Uri.tryParse(url);
    final segments = uri?.pathSegments ?? const <String>[];
    if (segments.isNotEmpty) {
      final last = segments.last.toLowerCase();
      if (last.contains('.')) {
        return last.split('.').last;
      }
    }
    return 'mp4';
  }
}

final videoDownloadServiceProvider = Provider<VideoDownloadService>((ref) {
  return VideoDownloadService(Dio());
});
