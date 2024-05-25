import 'package:asocialtest/components/my_drawer.dart';
import 'package:asocialtest/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 199, 196, 203),
      ),

      // side drawer to navigate between pages
      drawer: const MyDrawer(),

      // stream builder, able to do realtime updates to the snapshot as elements are added/removed to the collection
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getFriendRequests(),
        builder: (context, snapshot) {
          // check for errors
          if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }

          // loading indicator
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // if user has no friend requests
          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No friend requests"));
          }

          final friendRequests = snapshot.data!.docs;

          // build the listview based off the snapshot of friends
          return ListView.builder(
            itemCount: friendRequests.length,
            itemBuilder: (context, index) {
              final request = friendRequests[index];
              final senderEmail = request['sender'];

              return ListTile(
                title: Text("Friend request from $senderEmail"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // accept friend request button
                    ElevatedButton(
                      onPressed: () async {
                        // call accept friend function from firestore service
                        await firestoreService.acceptFriendRequest(senderEmail);

                        // call a rebuild of widget to update ui to reflect changes
                        setState(() {});
                      },
                      child: const Text("Accept"),
                    ),

                    const SizedBox(width: 8),

                    // decline friend request button
                    ElevatedButton(
                      onPressed: () async {
                        // call decline friend function from firestore service
                        await firestoreService.declineFriendRequest(senderEmail);
                        
                        // call a rebuild of widget to update ui to reflect changes
                        setState(() {});
                      },
                      child: const Text("Decline"),
                    ),
                    
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
