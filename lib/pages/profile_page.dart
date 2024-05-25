import 'package:asocialtest/components/my_back_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  // current logged in user
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // future to fetch user details
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>> (
        future: getUserDetails(),
        builder: (context, snapshot) {
          // loading..
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator()
            );
          }

          // error
          else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }

          // data received
          else if (snapshot.hasData) {
            // extract data
            Map<String, dynamic>? user = snapshot.data!.data();

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // back button
                  const MyBackButton(),

                  const SizedBox(height: 25),

                  // profile pic
                  Container(
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 232, 231, 231),
                    ),
                    padding: const EdgeInsets.all(25),
                    child: const Icon(Icons.person, size: 70),
                  ),

                  const SizedBox(height: 25),

                  // username
                  Text(
                    user!['username'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold
                    )
                  ),

                  const SizedBox(height: 25),

                  // email
                  Text(
                    user['email'],
                    style: TextStyle(
                      color: Colors.grey[600],
                    )
                  ),
                ],
              ),
            );
          }

          else {
            return const Text("No data");
          }
        },
      )
    );
  }
}