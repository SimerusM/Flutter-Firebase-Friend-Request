import 'package:asocialtest/auth/login_or_register.dart';
import 'package:asocialtest/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        // check to see if we have a user's data loaded in cache
        stream: FirebaseAuth.instance.authStateChanges(),

        // based on if we have a user's data, load different pages
        builder: (context, snapshot) {
          // user is logged in
          if (snapshot.hasData) {
            return const HomePage();
          }

          // user not logged in
          else {
            return const LoginOrRegister();
          }
        }
      )
    );
  }
}