import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/discovery_filters.dart';

/// Holds the active discovery filter criteria.
///
/// In-memory only — no Firestore writes, no local-storage persistence.
/// Both [discoveryFeedProvider] and [browseFeedProvider] watch this provider
/// so they automatically reload when filters change.
final discoveryFiltersProvider =
    NotifierProvider<DiscoveryFiltersNotifier, DiscoveryFilters>(
  DiscoveryFiltersNotifier.new,
);

class DiscoveryFiltersNotifier extends Notifier<DiscoveryFilters> {
  @override
  DiscoveryFilters build() => const DiscoveryFilters();

  /// Applies [filters] as the active filter set.
  ///
  /// Both feed providers watch this provider and will rebuild automatically,
  /// triggering a reload from page 1 with the new filters.
  void apply(DiscoveryFilters filters) {
    state = filters;
  }

  /// Resets all filters to defaults and triggers a feed reload.
  void reset() => apply(const DiscoveryFilters());
}
