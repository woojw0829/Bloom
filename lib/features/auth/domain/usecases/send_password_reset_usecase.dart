import '../failures/auth_failure.dart';
import '../repositories/auth_repository.dart';

class SendPasswordResetUseCase {
  const SendPasswordResetUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call(String email) {
    if (email.trim().isEmpty) throw const InvalidEmailFailure();
    return _repository.sendPasswordResetEmail(email.trim());
  }
}
