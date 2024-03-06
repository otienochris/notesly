import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:notesly/constants/routes.dart';
import 'package:notesly/services/auth/auth_service.dart';

import '../services/auth/auth_exceptions.dart';
import '../services/auth/auth_user.dart';
import '../utilities/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Enter your email',
              label: Text('Email'),
            ),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'Enter your password',
              label: Text('Password'),
            ),
          ),
          OutlinedButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
                final AuthUser authUser = await AuthService.firebase()
                    .logIn(email: email, password: password);
                log(authUser.toString());

                if (authUser.isEmailVerified ?? false) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    notesRoute,
                    (route) => false,
                  );
                } else {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    verifyEmailRoute,
                    (route) => false,
                  );
                }
                // log(userCredentials?.);
              } on UserNotFoundAuthException catch (e) {
                await showErrorDialog(context: context, text: 'User not found!');
              } on InvalidCredentialsAuthException catch (e) {
                await showErrorDialog(context: context, text: 'Invalid Credentials!');
              } on GenericAuthException catch (e) {
                await showErrorDialog(context: context, text: 'Authentication Error!');
              }
            },
            child: const Text('Login'),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  registerRoute,
                  (route) => false,
                );
              },
              child: const Text("Not registered? Register here!"))
        ],
      ),
    );
  }
}
