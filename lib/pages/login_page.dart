import 'package:asocialtest/components/my_button.dart';
import 'package:asocialtest/components/my_textfield.dart';
import 'package:asocialtest/helper/helper_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {

  final void Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text controllers
  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  // login method
  void login() async {
    // show loading circle
    showDialog(
      context: context, 
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      )
    );

    // try sign in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text);

      // pop loading circle
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);

      displayMessageToUser(e.code, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // logo
              const Icon(
                Icons.person,
                size: 80,
              ),
          
              const SizedBox(height: 25),
          
              // app name
              const Text(
                "aSocial",
                style: TextStyle(fontSize: 20)
              ),
          
              const SizedBox(height: 50),
          
              // email textfield
              MyTextField(
                hintText: "Email", 
                obscureText: false, 
                controller: emailController
              ),

              const SizedBox(height: 10),
          
              // password textfield
              MyTextField(
                hintText: "Password", 
                obscureText: true, // can't see the password
                controller: passwordController
              ),

              const SizedBox(height: 10),
          
              // forgot password
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("Forgot Password?")
                ],
              ),
              
              const SizedBox(height: 10),
          
              // sign in button
              MyButton(
                text: "Login", 
                onTap: login
              ),

              const SizedBox(height: 10),
              // dont have an account register here
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      " Register here", 
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  )
                ],
              )
            ]
          ),
        ),
      )
    );
  }
}