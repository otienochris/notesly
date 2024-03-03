import 'package:flutter_test/flutter_test.dart';
import 'package:notesly/services/auth/auth_exceptions.dart';

import 'mock_auth_provider.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();

    test('Should not be initialized to begin with',
        () => {expect(provider.isInitialized, false)});

    test('Cannot log out if not initialized', () {
      expect(provider.logOut(),
          throwsA(const TypeMatcher<NotInitializedException>()));
    });

    test('Should be able to be initialized', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('User should be null after initialization', () {
      expect(provider.currentUser, null);
    });

    test('Should be able to initialize in less than 2 seconds', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    }, timeout: const Timeout(Duration(seconds: 2)));

    test('Create user should delegate to logIn function', () async {
      // bad email
      expect(
          () async => await provider.createUser(
                email: 'foo@bar.com',
                password: 'password',
              ),
          throwsA(const TypeMatcher<UserNotFoundAuthException>()));

      // invalid credentials
      expect(
          () async => await provider.createUser(
                email: 'abc@bar.com',
                password: 'foobar',
              ),
          throwsA(const TypeMatcher<InvalidCredentialsAuthException>()));

      // actual user creation
      final user = await provider.createUser(
          email: 'abc@gmail.com', password: 'password');
      expect(provider.currentUser, user);

      // email verified
      expect(user.isEmailVerified, false);
    });

    test('Logged in user should be able to get verified', () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('Should be able to logout and login again', () async {
      await provider.logOut();
      await provider.logIn(
        email: 'email',
        password: 'password',
      );
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}
