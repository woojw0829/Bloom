import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../shared/models/user_model.dart';

/// Cursor-based result page for discovery queries.
class DiscoveryPage {
  const DiscoveryPage({
    required this.profiles,
    this.lastDocument,
    required this.rawCount,
  });

  /// Profiles returned by the query, already filtered by the repository.
  final List<UserModel> profiles;

  /// Firestore cursor for fetching the next page. Null when this is the
  /// last page or when the result set is shorter than the requested limit.
  final QueryDocumentSnapshot<Map<String, dynamic>>? lastDocument;

  /// Number of raw Firestore document snapshots returned before any
  /// in-process filtering (e.g. current-user exclusion). Used to compute
  /// [hasMore] accurately when the use case applies client-side filters that
  /// may significantly reduce the result count.
  final int rawCount;
}

abstract class DiscoveryRepository {
  /// Loads a page of discovery candidate profiles.
  ///
  /// [currentUserId] is excluded defensively at the repository level in
  /// addition to any query-level exclusion.
  /// [afterDocument] is the Firestore cursor from the previous page; pass
  /// null to load the first page.
  Future<DiscoveryPage> loadPage({
    required String currentUserId,
    QueryDocumentSnapshot<Map<String, dynamic>>? afterDocument,
    required int pageSize,
  });
}
