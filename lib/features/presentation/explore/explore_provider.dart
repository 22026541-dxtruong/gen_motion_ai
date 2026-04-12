import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_motion_ai/core/data/network/api_providers.dart';
import 'package:gen_motion_ai/core/data/network/explore/dto/explore_item.dto.dart';

/// Explore filter state
class ExploreFilter {
  final String? topic;
  final String? trending;
  final String? sort;
  final String? cursor;

  ExploreFilter({
    this.topic,
    this.trending,
    this.sort,
    this.cursor,
  });

  ExploreFilter copyWith({
    String? topic,
    String? trending,
    String? sort,
    String? cursor,
  }) {
    return ExploreFilter(
      topic: topic ?? this.topic,
      trending: trending ?? this.trending,
      sort: sort ?? this.sort,
      cursor: cursor ?? this.cursor,
    );
  }
}

/// Notifier for explore items
class ExploreNotifier extends AsyncNotifier<List<ExploreItem>> {
  ExploreFilter _filter = ExploreFilter();

  @override
  Future<List<ExploreItem>> build() async {
    final exploreApi = ref.watch(exploreApiProvider);
    return exploreApi.getExplore(
      topic: _filter.topic,
      trending: _filter.trending,
      sort: _filter.sort,
      limit: 20,
      cursor: _filter.cursor,
    );
  }

  // Update filter and reload
  Future<void> updateFilter(ExploreFilter filter) async {
    _filter = filter;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard<List<ExploreItem>>(() => build());
  }

  // Load more (pagination)
  Future<void> loadMore(String cursor) async {
    final exploreApi = ref.watch(exploreApiProvider);
    final current = state.maybeWhen(
      data: (items) => items,
      orElse: () => [],
    );

    state = await AsyncValue.guard<List<ExploreItem>>(() async {
      final newItems = await exploreApi.getExplore(
        topic: _filter.topic,
        trending: _filter.trending,
        sort: _filter.sort,
        limit: 20,
        cursor: cursor,
      );
      return [...current, ...newItems];
    });
  }

  // Refresh data
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard<List<ExploreItem>>(() => build());
  }

  // Set current filter
  ExploreFilter get filter => _filter;
}

/// Main explore provider with filtering
final exploreProvider =
    AsyncNotifierProvider<ExploreNotifier, List<ExploreItem>>(
  ExploreNotifier.new,
);
