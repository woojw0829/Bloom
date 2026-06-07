import '../entities/auth_user.dart';
import '../failures/auth_failure.dart';
import '../repositories/auth_repository.dart';

class SignUpWithEmailUseCase {
  const SignUpWithEmailUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call({
    required String email,
    required String password,
  }) {
    if (email.trim().isEmpty) throw const InvalidEmailFailure();
    if (password.length < 6) throw const WeakPasswordFailure();
    return _repository.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }
}
