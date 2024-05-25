import 'package:asocialtest/helper/helper_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  // access instance of the current user logged in
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // method to check relationship between current user and another user
  Future<Map<String, dynamic>> getUserRelation(String currentUserEmail, String otherUserEmail) async {
    // check each users' friends list to see if they're friends
    final friendsList1 = await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUserEmail)
        .collection("friends")
        .doc(otherUserEmail)
        .get();
    if (friendsList1.exists) {
      return {'status': 'friends'};
    }

    // checking the other users' friends list just in case there's any delays or propogation errors
    final friendsList2 = await FirebaseFirestore.instance
        .collection("Users")
        .doc(otherUserEmail)
        .collection("friends")
        .doc(currentUserEmail)
        .get();
    if (friendsList2.exists) {
      return {'status': 'friends'};
    }

    // users are not friends, checking status of their relationship
    // check to see if the current user has already sent a request to the other user
    // doc access is usually O(1), can be slower/faster based on latency and other factors
    final friendRequestDoc = await FirebaseFirestore.instance
        .collection("friendRequests")
        .doc("${currentUserEmail}_$otherUserEmail")
        .get();
    if (friendRequestDoc.exists) {
      return {'status': 'sent'};
    }

    // check to see if current user has been requested by the other user
    final friendRequestReceivedDoc = await FirebaseFirestore.instance
        .collection("friendRequests")
        .doc("${otherUserEmail}_${currentUserEmail}")
        .get();
    if (friendRequestReceivedDoc.exists) {
      return {'status': 'received'};
    }

    // if no relationship at all return none
    return {'status': 'none'};
  }

  // method to send a friend request to a selected user
  void sendFriendRequest(String recipientEmail) async {
    // instance of current user
    final User? currentUser = _auth.currentUser;

    // null check
    if (currentUser == null) return;

    // creating new document in the collection
    final friendRequestDoc = FirebaseFirestore.instance
        .collection("friendRequests")
        .doc("${currentUser.email}_$recipientEmail");

    // creating the friend request details
    // .set will automatically create a doc with the specified id if it doesn't already exist
    // if for some reason this request is there and hasn't been deleted before, it will override it
    await friendRequestDoc.set({
      'sender': currentUser.email,
      'recipient': recipientEmail,
      'status': 'pending',
    });

    // updating ui to reflect changes
    setState(() {}); 
    displayMessageToUser("Friend request sent", context);
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Users", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 199, 196, 203),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("Users").snapshots(),
        builder: (context, snapshot) {
          // any errors
          if (snapshot.hasError) {
            displayMessageToUser("Something went wrong", context);
          }

          // show loading circle
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == null) {
            return const Text("No Data");
          }

          // get all users
          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              // get individual users
              final user = users[index];
              if (user['email'] == currentUser!.email) {
                return Container(); // Skip current user
              }

              return FutureBuilder<Map<String, dynamic>>(
                future: getUserRelation(currentUser.email!, user['email']),
                builder: (context, relationSnapshot) {
                  // loading to find relationship
                  if (relationSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text(user['username']),
                      subtitle: Text(user['email']),
                      trailing: const CircularProgressIndicator(),
                    );
                  }

                  // if theres any errors
                  if (relationSnapshot.hasError || !relationSnapshot.hasData) {
                    return ListTile(
                      title: Text(user['username']),
                      subtitle: Text(user['email']),
                      trailing: const Text("Error"),
                    );
                  }

                  // determining relationship 
                  final relation = relationSnapshot.data!;
                  return ListTile(
                    title: Text(user['username']),
                    subtitle: Text(user['email']),
                    trailing: ElevatedButton(
                      onPressed: relation['status'] == 'none'
                          ? () => sendFriendRequest(user['email'])
                          : null,
                      child: Text(relation['status'] == 'friends'
                          ? "Friends"
                          : relation['status'] == 'sent'
                              ? "Request Sent"
                              : "Add Friend"),
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
