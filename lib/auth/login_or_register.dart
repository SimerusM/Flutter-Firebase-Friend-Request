import 'package:asocialtest/pages/login_page.dart';
import 'package:asocialtest/pages/register_page.dart';
import 'package:flutter/material.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override 
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {

  // initially show login page
  bool showLoginPage = true;

  // toggle between login and register page
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    // pass in togglePages method as a callback, toggle the value of showLoginPage
    // the variable showLoginPage isn't passed but togglePages has access to this state variable and can update the view and what to show in auth.dart then main.dart
    if (showLoginPage) {
      return LoginPage(onTap: togglePages);
    }
    else {
      return RegisterPage(onTap: togglePages);
    }
  }
}