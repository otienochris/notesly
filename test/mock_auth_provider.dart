import 'package:notesly/services/auth/auth_exceptions.dart';
import 'package:notesly/services/auth/auth_provider.dart';
import 'package:notesly/services/auth/auth_user.dart';
import 'dart:developer' as devtools show log;

import 'auth_test.dart';

class MockAuthProvider implements AuthProviderI {
  var _isInitialized = false;
  AuthUser? _currentUser;

  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    devtools.log('provider initialized');
    await Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    devtools.log('in the login section');
    if (!isInitialized) throw NotInitializedException();
    devtools.log('provider initialized');

    if (email == "foo@bar.com") {
      devtools.log('user not found');
      throw UserNotFoundAuthException();
    }

    if (password == "foobar") {
      devtools.log('invalid credentials');
      throw InvalidCredentialsAuthException();
    }

    const user = AuthUser(isEmailVerified: false, email: "abc@gmail.com");
    _currentUser = user;

    return Future.value(user);

  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if(_currentUser == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    if(_currentUser == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true, email: "abc@gmai.com");
    _currentUser = newUser;
  }
}