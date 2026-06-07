import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/profile/presentation/providers/user_provider.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/send_password_reset_usecase.dart';
import '../../domain/usecases/sign_in_with_apple_usecase.dart';
import '../../domain/usecases/sign_in_with_email_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_with_email_usecase.dart';

// ── Repository ────────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>(
  (_) => AuthRepositoryImpl(),
);

// ── Auth state stream ─────────────────────────────────────────────────────────
// Emits null when unauthenticated, AuthUser when authenticated.
// AsyncLoading during Firebase initialisation.

final authStateChangesProvider = StreamProvider<AuthUser?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges,
);

// ── Profile existence check (reactive) ───────────────────────────────────────
// StreamProvider so the router reacts automatically when users/{userId} is
// created at onboarding completion — no manual invalidation required.

final userProfileExistsProvider =
    StreamProvider.family<bool, String>((ref, userId) {
  return ref.read(userRepositoryProvider).watchProfileExists(userId);
});

// ── Routing state ─────────────────────────────────────────────────────────────

enum AuthRoutingState { loading, unauthenticated, needsOnboarding, authenticated }

final authRoutingProvider = Provider<AuthRoutingState>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  if (authState.isLoading) return AuthRoutingState.loading;

  final user = authState.valueOrNull;
  if (user == null) return AuthRoutingState.unauthenticated;

  final profileState = ref.watch(userProfileExistsProvider(user.uid));

  if (profileState.isLoading) return AuthRoutingState.loading;

  return (profileState.valueOrNull ?? false)
      ? AuthRoutingState.authenticated
      : AuthRoutingState.needsOnboarding;
});

// ── Auth operations notifier ──────────────────────────────────────────────────
// Handles sign-in, sign-up, sign-out, and password reset.
// State represents the in-flight operation: loading / success / error.

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, void>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<void> {
  late final AuthRepository _repository;

  @override
  Future<void> build() async {
    _repository = ref.read(authRepositoryProvider);
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => SignInWithEmailUseCase(_repository)(
        email: email,
        password: password,
      ),
    );
  }

  Future<void> signUpWithEmail(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => SignUpWithEmailUseCase(_repository)(
        email: email,
        password: password,
      ),
    );
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => SignInWithGoogleUseCase(_repository)(),
    );
  }

  Future<void> signInWithApple() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => SignInWithAppleUseCase(_repository)(),
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => SignOutUseCase(_repository)(),
    );
  }

  Future<void> sendPasswordReset(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => SendPasswordResetUseCase(_repository)(email),
    );
  }

  void clearError() {
    if (state.hasError) state = const AsyncData(null);
  }
}
