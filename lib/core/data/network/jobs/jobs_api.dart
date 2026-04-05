import 'package:dio/dio.dart';
import 'package:gen_motion_ai/core/data/network/api_endpoints.dart';
import 'package:gen_motion_ai/core/data/network/jobs/dto/job.dto.dart';

class JobsApi {
  JobsApi(this._dio);

  final Dio _dio;

  Future<CreateVideoJobResponseDto> createVideoJob(
    CreateVideoJobRequestDto body,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.createVideoJob,
      data: body.toJson(),
    );

    return CreateVideoJobResponseDto.fromJson(response.data!);
  }

  Future<List<JobSummaryDto>> listMyJobs() async {
    final response = await _dio.get<List<dynamic>>(ApiEndpoints.jobs);
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(JobSummaryDto.fromJson)
        .toList();
  }

  Future<JobDetailDto> getJobById(String jobId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.jobById(jobId),
    );

    return JobDetailDto.fromJson(response.data!);
  }

  Future<JobResultDto> getJobResult(String jobId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.jobResult(jobId),
    );

    return JobResultDto.fromJson(response.data!);
  }

  Future<CancelJobResponseDto> cancelJob(String jobId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.jobCancel(jobId),
    );

    return CancelJobResponseDto.fromJson(response.data!);
  }
}
