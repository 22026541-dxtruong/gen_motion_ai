import 'package:dio/dio.dart';
import 'package:gen_motion_ai/core/data/network/jobs/dto/create_video_job_dto.dart';
import 'package:gen_motion_ai/core/data/network/jobs/dto/job_response_dto.dart';
import 'package:retrofit/retrofit.dart';

part 'jobs_api.g.dart';

@RestApi()
abstract class JobsApi {
  factory JobsApi(Dio dio) = _JobsApi;

  @POST('/jobs/video')
  Future<JobResponseDto> createVideoJob(
    @Body() CreateVideoJobDto body,
  );

  @GET('/jobs')
  Future<List<JobResponseDto>> listMyJobs();

  @GET('/jobs/{id}')
  Future<JobResponseDto> getJob(
    @Path('id') String id,
  );

  @GET('/jobs/{id}/result')
  Future<JobResponseDto> getJobResult(
    @Path('id') String id,
  );

  @POST('/jobs/{id}/cancel')
  Future<dynamic> cancelJob(
    @Path('id') String id,
  );
}
