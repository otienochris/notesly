import 'dart:developer' as devtools show log;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:notesly/services/auth/auth_exceptions.dart';
import 'package:notesly/services/auth/auth_provider.dart';
import 'package:notesly/services/auth/auth_user.dart';

class FirebaseAuthProvider implements AuthProviderI {
  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final currentUser = user.user;
      if (currentUser != null) {
        return AuthUser.fromFirebase(currentUser);
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        devtools.log('Weak Password');
        throw WeakPasswordAuthException();
      } else if (e.code == 'email-already-in-use') {
        devtools.log('Email Already In Use');
        throw EmailAlreadyInUseAuthException();
      } else if (e.code == 'invalid-email') {
        devtools.log('Invalid Email Entered');
        throw InvalidEmailAuthException();
      } else {
        devtools.log('Authentication Error');
        throw GenericAuthException();
      }
    } catch (e) {
      devtools.log(e.toString());
      throw GenericAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final user = currentUser;

      if (user != null) {
        return user;
      } else {
        throw UserNotFoundAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        devtools.log('Invalid Credentials');
        throw InvalidCredentialsAuthException();
      } else if (e.code == 'user-not-found') {
        devtools.log('User Not Found');
        throw UserNotFoundAuthException();
      } else {
        devtools.log('Error: ${e.code}');
        throw GenericAuthException();
      }
    } catch (e) {
      devtools.log(e.toString());
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logOut() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }
}
