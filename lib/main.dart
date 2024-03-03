import 'package:flutter/material.dart';
import 'package:notesly/constants/routes.dart';
import 'package:notesly/services/auth/auth_service.dart';
import 'package:notesly/services/auth/auth_user.dart';
import 'package:notesly/views/login_view.dart';
import 'package:notesly/views/notes_view.dart';
import 'package:notesly/views/register_view.dart';
import 'package:notesly/views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      useMaterial3: true,
    ),
    home: const HomePage(),
    routes: {
      loginRoute: (context) => const LoginView(),
      registerRoute: (context) => const RegisterView(),
      verifyEmailRoute: (context) => const VerifyEmailView(),
      notesRoute: (context) => const NotesView(),
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            AuthUser? currentUser = AuthService.firebase().currentUser;

            if (currentUser != null) {
              if (currentUser.isEmailVerified) {
                return const NotesView();
              } else {
                return const LoginView();
              }
            } else {
              return const LoginView();
            }

          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
