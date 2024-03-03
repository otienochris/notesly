import 'package:flutter/material.dart';
import 'package:notesly/constants/routes.dart';
import 'package:notesly/services/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify email'),
      ),
      body: Column(
        children: [
          const Text(
              'We\'ve emailed you the details on how to verify your email. Use it to active your account'),
          const Text(
              'If you haven\'t received the email yet,press the button below:'),
          TextButton(
              onPressed: () async {
                await AuthService.firebase().sendEmailVerification();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRoute,
                  (route) => false,
                );
              },
              child: const Text('Send email verification')),
          OutlinedButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRoute,
                  (route) => false,
                );
              },
              child: const Text('login'))
        ],
      ),
    );
  }
}
