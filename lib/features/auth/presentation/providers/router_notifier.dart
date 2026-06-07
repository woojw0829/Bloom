import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import 'auth_provider.dart';

/// Bridges Riverpod auth state with GoRouter's [refreshListenable].
///
/// Implements [ChangeNotifier] so GoRouter can call [addListener] and
/// [removeListener]. Whenever [authRoutingProvider] changes, notifyListeners
/// is called and GoRouter re-evaluates [redirect].
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen<AuthRoutingState>(
      authRoutingProvider,
      (_, _) => notifyListeners(),
    );
  }

  final Ref _ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final routing = _ref.read(authRoutingProvider);
    final loc = state.matchedLocation;

    switch (routing) {
      case AuthRoutingState.loading:
        return loc == AppRoutes.splash ? null : AppRoutes.splash;

      case AuthRoutingState.unauthenticated:
        const authPages = {
          AppRoutes.login,
          AppRoutes.register,
          AppRoutes.forgotPassword,
        };
        return authPages.contains(loc) ? null : AppRoutes.login;

      case AuthRoutingState.needsOnboarding:
        return loc == AppRoutes.onboarding ? null : AppRoutes.onboarding;

      case AuthRoutingState.authenticated:
        const preAuthPages = {
          AppRoutes.splash,
          AppRoutes.login,
          AppRoutes.register,
          AppRoutes.forgotPassword,
          AppRoutes.onboarding,
        };
        return preAuthPages.contains(loc) ? AppRoutes.explore : null;
    }
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  final notifier = RouterNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});
