import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/user_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'user_provider.dart';

/// Reactively watches the current authenticated user's Firestore document.
/// Emits null when the user is unauthenticated or when the profile does not
/// exist yet. Emits [UserModel] once the document is available.
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authUser = ref.watch(authStateChangesProvider).valueOrNull;
  if (authUser == null) return Stream.value(null);
  return ref.read(userRepositoryProvider).watchUserProfile(authUser.uid);
});
