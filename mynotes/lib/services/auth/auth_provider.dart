import 'package:mynotes/services/auth/auth_user.dart';

abstract class BaseAuthProvider {
  AuthUser? get currentUser;

  Future<AuthUser?> login({required String email, required String password});

  Future<AuthUser?> createUser({
    required String email,
    required String password,
  });

  Future<void> logOut();
  Future<void> sendEmailVerification();
}
