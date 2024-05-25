import 'package:asocialtest/auth/auth.dart';
import 'package:asocialtest/auth/login_or_register.dart';
import 'package:asocialtest/firebase_options.dart';
import 'package:asocialtest/pages/friends_page.dart';
import 'package:asocialtest/pages/home_page.dart';
import 'package:asocialtest/pages/profile_page.dart';
import 'package:asocialtest/pages/users_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthPage(),
      routes: {
        '/login_register_page': (context) => const LoginOrRegister(),
        '/home_page': (context) => const HomePage(),
        '/profile_page': (context) => ProfilePage(),
        '/users_page': (context) => const UsersPage(),
        '/friends_page': (context) => const FriendsPage()
      }
    );
  }
}