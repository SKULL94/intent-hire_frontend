import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class WatchAuthState {
  final AuthRepository _repo;

  WatchAuthState(this._repo);

  Stream<AuthUser?> call() => _repo.watchAuthState();

  AuthUser? get currentUser => _repo.currentUser;
}
