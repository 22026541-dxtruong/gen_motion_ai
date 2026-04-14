import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_motion_ai/core/data/network/api_providers.dart';
import 'package:gen_motion_ai/core/data/network/jobs/dto/job.dto.dart';
import 'package:gen_motion_ai/features/presentation/user/user_provider.dart';

final jobsQueueProvider =
    AsyncNotifierProvider<JobsQueueNotifier, List<JobSummaryDto>>(
      JobsQueueNotifier.new,
    );

final activeJobsCountProvider = Provider<int>((ref) {
  final jobsAsync = ref.watch(jobsQueueProvider);
  return jobsAsync.maybeWhen(
    data: (jobs) => jobs.where((job) => !job.isTerminal).length,
    orElse: () => 0,
  );
});

class JobsQueueNotifier extends AsyncNotifier<List<JobSummaryDto>> {
  @override
  Future<List<JobSummaryDto>> build() {
    return _fetchJobs();
  }

  Future<void> refresh() async {
    final previous = state.asData?.value;
    try {
      final jobs = await _fetchJobs();
      state = AsyncData(jobs);
    } catch (error, stackTrace) {
      if (previous == null) {
        state = AsyncError(error, stackTrace);
      }
    }
  }

  Future<CancelJobResponseDto> cancelJob(String jobId) async {
    final response = await ref.read(jobsApiProvider).cancelJob(jobId);
    await ref.read(currentUserProvider.notifier).fetchMe();
    state = await AsyncValue.guard(_fetchJobs);
    return response;
  }

  Future<List<JobSummaryDto>> _fetchJobs() {
    return ref.read(jobsApiProvider).listMyJobs();
  }
}
