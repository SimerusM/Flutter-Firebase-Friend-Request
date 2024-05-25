import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:asocialtest/services/firestore.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  // displays list of all current friends
  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Friends", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 199, 196, 203),
      ),

      // streambuilder for live refreshing if new friends are added
      body: StreamBuilder(

        // use the current users' friends sub sollection as the snapshot
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(currentUser!.email)
            .collection("friends")
            .snapshots(),
        builder: (context, snapshot) {
          // if theres an error
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          // loading indicator
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // if user doesn't have any friends
          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No friends"));
          }

          final friends = snapshot.data!.docs;

          // build a list of the users friends
          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friendEmail = friends[index].id;
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection("Users").doc(friendEmail).get(),
                builder: (context, friendSnapshot) {
                  // loading indicator
                  if (friendSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: const Text("Loading..."),
                      subtitle: Text(friendEmail),
                    );
                  }

                  // if theres an error
                  if (friendSnapshot.hasError || !friendSnapshot.hasData) {
                    return ListTile(
                      title: const Text("Error"),
                      subtitle: Text(friendEmail),
                    );
                  }

                  // display friend data alongside button to delete them as a friend
                  final friendData = friendSnapshot.data!.data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(friendData['username']),
                    subtitle: Text(friendData['email']),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        // call deleteFriend function from firestore service
                        await firestoreService.deleteFriend(currentUser.email!, friendEmail);
                        
                        // refresh page to update ui and changes
                        setState(() {});
                      },
                      child: const Text("Remove Friend"),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
