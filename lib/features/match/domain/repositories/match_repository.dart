import '../models/match_record.dart';

abstract class MatchRepository {
  Stream<List<MatchRecord>> watchActiveMatches(String currentUserId);

  Future<void> unmatch({
    required String matchId,
    required String currentUserId,
  });
}
