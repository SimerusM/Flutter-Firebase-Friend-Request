import 'package:asocialtest/components/my_button.dart';
import 'package:asocialtest/components/my_textfield.dart';
import 'package:asocialtest/helper/helper_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text controllers
  TextEditingController usernameController = TextEditingController();

  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  TextEditingController confirmPwController = TextEditingController();

  // register method
  void register() async {
    // show loading circle
    showDialog(
      context: context, 
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      )
    );

    // make sure passwords match
    if (passwordController.text != confirmPwController.text) {
      // pop loading circle
      Navigator.pop(context);

      displayMessageToUser("Passwords don't match", context);
    }
    else {
      // try creating user
      try {
        // create user
        UserCredential? userCredential = 
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text, 
          password: passwordController.text
        );
        
        createUserDocument(userCredential);

        // pop loading circle, waiting for async createUserDocument to finish its tasks
        if (context.mounted) Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        // pop loading circle
        Navigator.pop(context);

        // display error message to user
        displayMessageToUser(e.code, context);
      }
    }
  }

  // create user document and collect in firestore
  Future<void> createUserDocument(UserCredential? userCredential) async {
    if (userCredential != null && userCredential.user != null) {
      await FirebaseFirestore.instance
        .collection("Users")
        .doc(userCredential.user!.email)
        .set({
          'email': userCredential.user!.email,
          'username': usernameController.text
        });
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
          
              // username textfield
              MyTextField(
                hintText: "Username", 
                obscureText: false, 
                controller: usernameController
              ),

              const SizedBox(height: 10),

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

              // confirm  password textfield
              MyTextField(
                hintText: "Confirm Password", 
                obscureText: true, // can't see the password
                controller: confirmPwController
              ),

              const SizedBox(height: 10),
          
              // register button
              MyButton(
                text: "Register", 
                onTap: register
              ),

              const SizedBox(height: 10),

              // dont have an account register here, switch pages
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  GestureDetector(
                    // passing in onTap into constructor allows us to toggle between register and login from login_or_register page
                    onTap: widget.onTap,
                    child: const Text(
                      " Login here", 
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