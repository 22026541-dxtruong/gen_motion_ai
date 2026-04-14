import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_motion_ai/core/data/local/storage/secure_storage.dart';
import 'package:gen_motion_ai/core/data/network/api_providers.dart';
import 'package:gen_motion_ai/core/data/network/assets/dto/asset.dto.dart';
import 'package:gen_motion_ai/core/data/network/jobs/dto/job.dto.dart';
import 'package:gen_motion_ai/core/data/network/jobs/dto/job_stream.dto.dart';
import 'package:gen_motion_ai/core/data/network/network_error.dart';
import 'package:gen_motion_ai/features/presentation/queue/queue_provider.dart';
import 'package:gen_motion_ai/features/presentation/user/user_provider.dart';
import 'package:image_picker/image_picker.dart';

final generateVideoProvider =
    NotifierProvider<GenerateVideoNotifier, GenerateVideoState>(
      GenerateVideoNotifier.new,
    );

const _unset = Object();

class GenerateVideoNotifier extends Notifier<GenerateVideoState> {
  final ImagePicker _picker = ImagePicker();
  Timer? _pollTimer;
  StreamSubscription<JobStreamEventDto>? _eventsSubscription;
  bool _pollInFlight = false;

  @override
  GenerateVideoState build() {
    ref.onDispose(() {
      _stopPolling();
      _stopRealtime();
    });
    return const GenerateVideoState();
  }

  Future<void> pickInputImage() async {
    state = state.copyWith(isPickingImage: true, errorMessage: null);

    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) {
        state = state.copyWith(isPickingImage: false);
        return;
      }

      final bytes = await picked.readAsBytes();
      _stopPolling();
      _stopRealtime();

      state = GenerateVideoState(
        selectedImageBytes: bytes,
        selectedFileName: picked.name,
        selectedMimeType: _mimeTypeFromFileName(picked.name),
      );
    } catch (error) {
      state = state.copyWith(
        isPickingImage: false,
        errorMessage: networkErrorMessage(error),
      );
    }
  }

  void clearSelectedImage() {
    _stopPolling();
    _stopRealtime();
    state = const GenerateVideoState();
  }

  Future<void> generateVideo({
    required String prompt,
    String? negativePrompt,
    required String presetId,
  }) async {
    final trimmedPrompt = prompt.trim();
    if (trimmedPrompt.isEmpty) {
      state = state.copyWith(errorMessage: 'Prompt không được để trống.');
      return;
    }

    if (state.selectedImageBytes == null || state.selectedFileName == null) {
      state = state.copyWith(errorMessage: 'Hãy chọn một ảnh đầu vào trước.');
      return;
    }

    _stopPolling();
    _stopRealtime();

    state = state.copyWith(
      isUploading: true,
      isCreatingJob: false,
      errorMessage: null,
      inputAsset: null,
      createdJob: null,
      currentResult: null,
      realtimeLogs: const <JobLogDto>[],
      isRealtimeConnecting: false,
      isRealtimeConnected: false,
    );

    try {
      final assetsApi = ref.read(assetsApiProvider);
      final asset = await assetsApi.uploadAsset(
        bytes: state.selectedImageBytes!,
        fileName: state.selectedFileName!,
        mimeType: state.selectedMimeType,
      );

      state = state.copyWith(
        isUploading: false,
        isCreatingJob: true,
        inputAsset: asset,
      );

      final jobsApi = ref.read(jobsApiProvider);
      final createdJob = await jobsApi.createVideoJob(
        CreateVideoJobRequestDto(
          inputAssetId: asset.id,
          prompt: trimmedPrompt,
          negativePrompt: negativePrompt?.trim().isEmpty == true
              ? null
              : negativePrompt?.trim(),
          presetId: presetId,
        ),
      );

      state = state.copyWith(
        isCreatingJob: false,
        createdJob: createdJob,
        currentResult: JobResultDto.fromCreateJob(createdJob),
      );

      await ref.read(currentUserProvider.notifier).fetchMe();
      ref.read(jobsQueueProvider.notifier).refresh();

      await pollCurrentJob(silent: true);
      if (state.currentResult?.isTerminal == true ||
          state.currentResult?.resultReady == true) {
        return;
      }
      _startRealtime(createdJob.jobId);
      if (!state.isRealtimeConnected) {
        _startPolling(createdJob.jobId);
      }
    } catch (error) {
      state = state.copyWith(
        isUploading: false,
        isCreatingJob: false,
        errorMessage: networkErrorMessage(error),
      );
    }
  }

  Future<void> pollCurrentJob({bool silent = false}) async {
    final jobId = state.currentJobId;
    if (jobId == null || _pollInFlight) {
      return;
    }

    _pollInFlight = true;
    try {
      final result = await ref.read(jobsApiProvider).getJobResult(jobId);
      state = state.copyWith(currentResult: result, errorMessage: null);

      if (result.isTerminal || result.resultReady) {
        _stopPolling();
        _stopRealtime();
        await ref.read(currentUserProvider.notifier).fetchMe();
        ref.read(jobsQueueProvider.notifier).refresh();
      }
    } catch (error) {
      if (!silent) {
        state = state.copyWith(errorMessage: networkErrorMessage(error));
      }
    } finally {
      _pollInFlight = false;
    }
  }

  Future<void> cancelCurrentJob() async {
    final jobId = state.currentJobId;
    if (jobId == null || !state.canCancelCurrentJob) {
      return;
    }

    try {
      final response = await ref.read(jobsApiProvider).cancelJob(jobId);
      _stopPolling();
      _stopRealtime();

      state = state.copyWith(
        currentResult: JobResultDto(
          jobId: response.jobId,
          status: response.status,
          progress: state.currentResult?.progress ?? 0,
          creditCost:
              state.currentResult?.creditCost ??
              state.createdJob?.creditCost ??
              0,
          resultReady: false,
          provider: state.currentResult?.provider ?? state.createdJob?.provider,
          modelName:
              state.currentResult?.modelName ?? state.createdJob?.modelName,
          presetId: state.currentResult?.presetId ?? state.createdJob?.presetId,
          tier: state.currentResult?.tier ?? state.createdJob?.tier,
          estimatedDurationSeconds:
              state.currentResult?.estimatedDurationSeconds ??
              state.createdJob?.estimatedDurationSeconds,
        ),
        errorMessage: null,
      );

      await ref.read(currentUserProvider.notifier).fetchMe();
      ref.read(jobsQueueProvider.notifier).refresh();
    } catch (error) {
      state = state.copyWith(errorMessage: networkErrorMessage(error));
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void _startPolling(String jobId) {
    _stopPolling();
    if (state.isRealtimeConnected) {
      return;
    }
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (state.currentJobId == jobId) {
        pollCurrentJob(silent: true);
      }
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void _startRealtime(String jobId) {
    _stopRealtime();
    state = state.copyWith(
      isRealtimeConnecting: true,
      isRealtimeConnected: false,
    );
    _eventsSubscription = _connectRealtime(jobId).listen(
      (event) {
        _handleRealtimeEvent(event);
      },
      onError: (_) {
        _handleRealtimeDisconnected(jobId);
      },
      onDone: () {
        _handleRealtimeDisconnected(jobId);
      },
      cancelOnError: true,
    );
  }

  void _stopRealtime() {
    _eventsSubscription?.cancel();
    _eventsSubscription = null;
  }

  Stream<JobStreamEventDto> _connectRealtime(String jobId) async* {
    final accessToken = await ref.read(secureStorageProvider).getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw StateError('Missing access token for SSE');
    }

    yield* ref.read(jobEventsClientProvider).streamJobEvents(
      jobId: jobId,
      accessToken: accessToken,
    );
  }

  void _handleRealtimeDisconnected(String jobId) {
    if (state.currentJobId != jobId) {
      return;
    }
    final currentStatus = state.currentResult?.status;
    if (currentStatus != null && isTerminalJobStatus(currentStatus)) {
      return;
    }

    state = state.copyWith(
      isRealtimeConnecting: false,
      isRealtimeConnected: false,
    );
    _startPolling(jobId);
  }

  Future<void> _handleRealtimeEvent(JobStreamEventDto event) async {
    state = state.copyWith(
      isRealtimeConnecting: false,
      isRealtimeConnected: true,
      errorMessage: null,
    );
    _stopPolling();

    switch (event.type) {
      case 'snapshot':
        final snapshot = event.snapshot!;
        state = state.copyWith(
          currentResult: JobResultDto(
            jobId: snapshot.jobId,
            status: snapshot.status,
            progress: snapshot.progress,
            creditCost:
                state.currentResult?.creditCost ?? state.createdJob?.creditCost ?? 0,
            resultReady: snapshot.status == 'COMPLETED',
            provider: snapshot.provider,
            modelName: snapshot.modelName,
            presetId: snapshot.presetId,
            tier: snapshot.tier,
            estimatedDurationSeconds: snapshot.estimatedDurationSeconds,
            workflow: snapshot.workflow,
          ),
          realtimeLogs: snapshot.logs,
        );
        if (isTerminalJobStatus(snapshot.status)) {
          await pollCurrentJob(silent: true);
        }
        return;
      case 'status':
        final status = event.status!;
        final current = state.currentResult;
        state = state.copyWith(
          currentResult: JobResultDto(
            jobId: status.jobId,
            status: status.status,
            progress: status.progress,
            creditCost:
                current?.creditCost ?? state.createdJob?.creditCost ?? 0,
            resultReady: status.status == 'COMPLETED',
            provider: current?.provider ?? state.createdJob?.provider,
            modelName: current?.modelName ?? state.createdJob?.modelName,
            presetId: current?.presetId ?? state.createdJob?.presetId,
            tier: current?.tier ?? state.createdJob?.tier,
            estimatedDurationSeconds:
                current?.estimatedDurationSeconds ??
                state.createdJob?.estimatedDurationSeconds,
            workflow: current?.workflow,
            downloadUrl: current?.downloadUrl,
            expiresIn: current?.expiresIn,
            thumbnail: current?.thumbnail,
            assetId: current?.assetId,
            bucket: current?.bucket,
            objectKey: current?.objectKey,
            mimeType: current?.mimeType,
            sizeBytes: current?.sizeBytes,
            createdAt: current?.createdAt,
          ),
        );
        if (isTerminalJobStatus(status.status)) {
          await pollCurrentJob(silent: true);
        }
        return;
      case 'log':
        final log = event.log!;
        final logs = [...state.realtimeLogs];
        final exists = logs.any(
          (item) =>
              item.message == log.message &&
              item.createdAt.toIso8601String() == log.createdAt.toIso8601String(),
        );
        if (!exists) {
          logs.add(log);
        }
        state = state.copyWith(realtimeLogs: logs);
        return;
      case 'heartbeat':
        return;
      default:
        return;
    }
  }

  String _mimeTypeFromFileName(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) {
      return 'image/png';
    }
    if (lower.endsWith('.webp')) {
      return 'image/webp';
    }
    if (lower.endsWith('.heic')) {
      return 'image/heic';
    }
    return 'image/jpeg';
  }
}

class GenerateVideoState {
  const GenerateVideoState({
    this.selectedImageBytes,
    this.selectedFileName,
    this.selectedMimeType,
    this.isPickingImage = false,
    this.isUploading = false,
    this.isCreatingJob = false,
    this.inputAsset,
    this.createdJob,
    this.currentResult,
    this.realtimeLogs = const [],
    this.isRealtimeConnecting = false,
    this.isRealtimeConnected = false,
    this.errorMessage,
  });

  final Uint8List? selectedImageBytes;
  final String? selectedFileName;
  final String? selectedMimeType;
  final bool isPickingImage;
  final bool isUploading;
  final bool isCreatingJob;
  final AssetDto? inputAsset;
  final CreateVideoJobResponseDto? createdJob;
  final JobResultDto? currentResult;
  final List<JobLogDto> realtimeLogs;
  final bool isRealtimeConnecting;
  final bool isRealtimeConnected;
  final String? errorMessage;

  String? get currentJobId => currentResult?.jobId ?? createdJob?.jobId;
  bool get isBusy => isPickingImage || isUploading || isCreatingJob;
  bool get hasSelectedImage => selectedImageBytes != null;
  bool get canCancelCurrentJob => currentResult?.canCancel ?? false;
  bool get hasResultVideo =>
      (currentResult?.downloadUrl?.isNotEmpty ?? false) &&
      (currentResult?.resultReady ?? false);

  GenerateVideoState copyWith({
    Object? selectedImageBytes = _unset,
    Object? selectedFileName = _unset,
    Object? selectedMimeType = _unset,
    bool? isPickingImage,
    bool? isUploading,
    bool? isCreatingJob,
    Object? inputAsset = _unset,
    Object? createdJob = _unset,
    Object? currentResult = _unset,
    Object? realtimeLogs = _unset,
    bool? isRealtimeConnecting,
    bool? isRealtimeConnected,
    Object? errorMessage = _unset,
  }) {
    return GenerateVideoState(
      selectedImageBytes: identical(selectedImageBytes, _unset)
          ? this.selectedImageBytes
          : selectedImageBytes as Uint8List?,
      selectedFileName: identical(selectedFileName, _unset)
          ? this.selectedFileName
          : selectedFileName as String?,
      selectedMimeType: identical(selectedMimeType, _unset)
          ? this.selectedMimeType
          : selectedMimeType as String?,
      isPickingImage: isPickingImage ?? this.isPickingImage,
      isUploading: isUploading ?? this.isUploading,
      isCreatingJob: isCreatingJob ?? this.isCreatingJob,
      inputAsset: identical(inputAsset, _unset)
          ? this.inputAsset
          : inputAsset as AssetDto?,
      createdJob: identical(createdJob, _unset)
          ? this.createdJob
          : createdJob as CreateVideoJobResponseDto?,
      currentResult: identical(currentResult, _unset)
          ? this.currentResult
          : currentResult as JobResultDto?,
      realtimeLogs: identical(realtimeLogs, _unset)
          ? this.realtimeLogs
          : List<JobLogDto>.from(realtimeLogs as List),
      isRealtimeConnecting: isRealtimeConnecting ?? this.isRealtimeConnecting,
      isRealtimeConnected: isRealtimeConnected ?? this.isRealtimeConnected,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
