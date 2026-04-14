import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gen_motion_ai/core/data/network/api_endpoints.dart';
import 'package:gen_motion_ai/core/data/network/assets/dto/asset.dto.dart';
import 'package:http_parser/http_parser.dart';

class AssetsApi {
  AssetsApi(this._dio);

  final Dio _dio;

  Future<AssetDto> uploadAsset({
    required Uint8List bytes,
    required String fileName,
    String? mimeType,
    String? jobId,
    String? type,
    String? role,
    String? folder,
  }) async {
    final resolvedMimeType = mimeType ?? _inferMimeType(fileName);

    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: fileName,
        contentType: MediaType.parse(resolvedMimeType),
      ),
      if (jobId != null) 'jobId': jobId,
      if (type != null) 'type': type,
      if (role != null) 'role': role,
      if (folder != null) 'folder': folder,
    });

    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.assetUpload,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    return AssetDto.fromJson(response.data!);
  }

  Future<AssetDto> getAssetById(String assetId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.assetById(assetId),
    );

    return AssetDto.fromJson(response.data!);
  }

  Future<AssetDownloadUrlDto> getDownloadSignedUrl(String assetId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.assetDownload(assetId),
    );

    return AssetDownloadUrlDto.fromJson(response.data!);
  }

  String _inferMimeType(String fileName) {
    final normalized = fileName.toLowerCase();
    if (normalized.endsWith('.png')) {
      return 'image/png';
    }
    if (normalized.endsWith('.webp')) {
      return 'image/webp';
    }
    if (normalized.endsWith('.heic')) {
      return 'image/heic';
    }
    return 'image/jpeg';
  }
}
