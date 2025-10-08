import 'package:flutter_test/flutter_test.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';

void main() {
  group('mock authentication', () {
    test('user should be null', () {
      final provider = MockAuthProvider();
      expect(provider.currentUser, null);
    });
  });

  test('Create badEmailUser should throw error UserNotFoundAuthException', () {
    final provider = MockAuthProvider();
    final badEmailUser = provider.createUser(
      email: 'foo@bar.com',
      password: 'anypassword',
    );

    expect(
      badEmailUser,
      throwsA(const TypeMatcher<UserNotFoundAuthException>()),
    );
  });

  test('Create badEmailUser should throw error WrongPasswordAuthException', () {
    final provider = MockAuthProvider();
    final wrongPasswordUser = provider.createUser(
      email: 'nothing@bar.com',
      password: 'foobar',
    );

    expect(
      wrongPasswordUser,
      throwsA(const TypeMatcher<WrongPasswordAuthException>()),
    );
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements BaseAuthProvider {
  AuthUser? _user;
  var isInitiallized = false;

  @override
  Future<AuthUser?> createUser({
    required String email,
    required String password,
  }) async {
    Future.delayed(const Duration(seconds: 1));
    return login(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> logOut() async {
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<AuthUser?> login({required String email, required String password}) {
    if (email == 'foo@bar.com') throw UserNotFoundAuthException();
    if (password == 'foobar') throw WrongPasswordAuthException();
    const user = AuthUser(isEmailVerified: false);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> sendEmailVerification() {
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true);
    _user = newUser;
    return Future.value();
  }
}
