import '../entities/auth_user.dart';
import '../failures/auth_failure.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmailUseCase {
  const SignInWithEmailUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call({
    required String email,
    required String password,
  }) {
    if (email.trim().isEmpty) throw const InvalidEmailFailure();
    if (password.isEmpty) throw const WrongPasswordFailure();
    return _repository.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }
}
