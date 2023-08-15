import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialmediaapp/auth/login_or_register.dart';
import 'package:socialmediaapp/pages/home_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          //user is loged in
          if (snapshot.hasData) {
            return const HomePage();
          }
          //user is not loged in
          else {
            return const LoginorRegister();
          }
        },
      ),
    );
  }
}
