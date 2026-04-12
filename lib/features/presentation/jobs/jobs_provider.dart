import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_motion_ai/core/data/network/api_providers.dart';
import 'package:gen_motion_ai/core/data/network/jobs/dto/create_video_job_dto.dart';
import 'package:gen_motion_ai/core/data/network/jobs/dto/job_response_dto.dart';

/// Notifier for creating/managing video generation jobs
class JobsNotifier extends AsyncNotifier<List<JobResponseDto>> {
  Timer? _pollTimer;

  @override
  Future<List<JobResponseDto>> build() async {
    ref.onDispose(() {
      _pollTimer?.cancel();
    });
    return _fetchJobs();
  }

  Future<List<JobResponseDto>> _fetchJobs() async {
    final jobsApi = ref.read(jobsApiProvider);
    try {
      return await jobsApi.listMyJobs();
    } catch (_) {
      return [];
    }
  }

  /// Create a new video generation job
  Future<JobResponseDto> createVideoJob({
    required String inputAssetId,
    required String prompt,
    String? negativePrompt,
    required String modelName,
    String? aspectRatio,
    bool turboEnabled = false,
    int? duration,
  }) async {
    final jobsApi = ref.watch(jobsApiProvider);

    final createDto = CreateVideoJobDto(
      inputAssetId: inputAssetId,
      prompt: prompt,
      negativePrompt: negativePrompt,
      modelName: modelName,
      aspectRatio: aspectRatio ?? '16:9',
      turboEnabled: turboEnabled,
      duration: duration?.toString(),
    );

    final result = await jobsApi.createVideoJob(createDto);

    // Refresh entire list from server
    await refresh();

    return result;
  }

  /// Refresh jobs from server
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchJobs());
  }

  /// Cancel a job
  Future<void> cancelJob(String jobId) async {
    final jobsApi = ref.read(jobsApiProvider);
    await jobsApi.cancelJob(jobId);
    await refresh();
  }

  /// Start auto-polling for active jobs
  void startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final current = state.maybeWhen(data: (d) => d, orElse: () => <JobResponseDto>[]);
      final hasActiveJobs = current.any((j) =>
          j.status == 'PENDING' ||
          j.status == 'QUEUED' ||
          j.status == 'PROCESSING');
      if (hasActiveJobs) {
        state = await AsyncValue.guard(() => _fetchJobs());
      }
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
  }
}

/// Main jobs provider
final jobsProvider = AsyncNotifierProvider<JobsNotifier, List<JobResponseDto>>(
  JobsNotifier.new,
);

/// Active jobs count
final activeJobsCountProvider = Provider<int>((ref) {
  final jobsState = ref.watch(jobsProvider);
  final jobs = jobsState.maybeWhen(data: (d) => d, orElse: () => <JobResponseDto>[]);
  return jobs
      .where((j) =>
          j.status == 'PENDING' ||
          j.status == 'QUEUED' ||
          j.status == 'PROCESSING')
      .length;
});
