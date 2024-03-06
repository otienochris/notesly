import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';
import 'package:notesly/constants/routes.dart';
import 'package:notesly/services/auth/auth_service.dart';

import '../../services/auth/auth_exceptions.dart';
import '../../utilities/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
        title: const Text('Register'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
                hintText: 'Enter your email', label: Text('Email')),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
                hintText: 'Enter your password', label: Text('Password')),
          ),
          OutlinedButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
                final authUser = await AuthService.firebase()
                    .createUser(email: email, password: password);

                await AuthService.firebase().sendEmailVerification();
                Navigator.of(context).pushNamed(verifyEmailRoute);

                devtools.log(authUser.toString());
              } on WeakPasswordAuthException catch (e) {
                await showErrorDialog(
                  context: context,
                  text: 'Weak Password',
                );
              } on EmailAlreadyInUseAuthException catch (e) {
                await showErrorDialog(
                  context: context,
                  text: 'Email already in use',
                );
              } on InvalidEmailAuthException catch (e) {
                await showErrorDialog(
                  context: context,
                  text: 'Invalid Email Entered',
                );
              } on GenericAuthException {
                await showErrorDialog(
                  context: context,
                  text: 'Failed to register',
                );
                devtools.log('Authentication Error');
              }
            },
            child: const Text('Register'),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRoute,
                  (route) => false,
                );
              },
              child: const Text('Have an account? login'))
        ],
      ),
    );
  }
}
