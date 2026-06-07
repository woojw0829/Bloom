import 'package:firebase_auth/firebase_auth.dart';

sealed class AuthFailure implements Exception {
  const AuthFailure();

  String get message;

  factory AuthFailure.fromFirebaseAuthException(FirebaseAuthException e) {
    return switch (e.code) {
      'invalid-email'          => const InvalidEmailFailure(),
      'wrong-password'         => const WrongPasswordFailure(),
      'invalid-credential'     => const WrongPasswordFailure(),
      'user-not-found'         => const UserNotFoundFailure(),
      'email-already-in-use'   => const EmailAlreadyInUseFailure(),
      'weak-password'          => const WeakPasswordFailure(),
      'network-request-failed' => const NetworkFailure(),
      'user-cancelled'         => const CancelledFailure(),
      _                        => UnknownFailure(e.message ?? 'An unexpected error occurred.'),
    };
  }
}

final class InvalidEmailFailure extends AuthFailure {
  const InvalidEmailFailure();
  @override
  String get message => 'Please enter a valid email address.';
}

final class WrongPasswordFailure extends AuthFailure {
  const WrongPasswordFailure();
  @override
  String get message => 'Incorrect password. Please try again.';
}

final class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure();
  @override
  String get message => 'No account found with this email.';
}

final class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure();
  @override
  String get message => 'An account with this email already exists.';
}

final class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure();
  @override
  String get message => 'Password must be at least 6 characters.';
}

final class NetworkFailure extends AuthFailure {
  const NetworkFailure();
  @override
  String get message => 'Network error. Please check your connection.';
}

final class CancelledFailure extends AuthFailure {
  const CancelledFailure();
  @override
  String get message => 'Sign-in was cancelled.';
}

final class UnknownFailure extends AuthFailure {
  final String _message;
  const UnknownFailure(this._message);
  @override
  String get message => _message;
}
