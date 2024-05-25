import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final CollectionReference users = FirebaseFirestore.instance.collection('Users');
  final CollectionReference friendRequests = FirebaseFirestore.instance.collection('friendRequests');

  // send friend request to another user
  Future<void> sendFriendRequest(String recipientEmail) async {
    // get instance of current user details, can be null
    final User? currentUser = FirebaseAuth.instance.currentUser;

    // null check
    if (currentUser == null) return;

    // creating the doc to add to the collection
    final friendRequestDoc = friendRequests.doc("${currentUser.email}_$recipientEmail");
    await friendRequestDoc.set({
      'sender': currentUser.email,
      'recipient': recipientEmail,
      'status': 'pending',
    });
  }

  // accepting a friend request
  Future<void> acceptFriendRequest(String senderEmail) async {
    // get instance of current user details
    final User? currentUser = FirebaseAuth.instance.currentUser;

    // null check
    if (currentUser == null) return;

    // finding the specific doc of the transaction
    final friendRequestDoc = friendRequests.doc("${senderEmail}_${currentUser.email}");
    
    // getting rid of waste doc to avoid doc-pollution, limiting # of read's
    await friendRequestDoc.delete();

    // make the users to be friends and update that on their specific metadata's
    await users.doc(currentUser.email).collection('friends').doc(senderEmail).set({});
    await users.doc(senderEmail).collection('friends').doc(currentUser.email).set({});
  }

  // decline a friend request sent to you
  Future<void> declineFriendRequest(String senderEmail) async {
    // get instance of current user details
    final User? currentUser = FirebaseAuth.instance.currentUser;

    // null check
    if (currentUser == null) return;

    // delete the request
    final friendRequestDoc = friendRequests.doc("${senderEmail}_${currentUser.email}");
    await friendRequestDoc.delete();
  }

  // delete a friend from the friends page
  Future<void> deleteFriend(String currentUserEmail, String friendEmail) async {
    await users.doc(currentUserEmail).collection('friends').doc(friendEmail).delete();
    await users.doc(friendEmail).collection('friends').doc(currentUserEmail).delete();
  }

  // stream class to get a snapshot of friend requests to the current user
  Stream<QuerySnapshot> getFriendRequests() {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception("User not logged in");

    return friendRequests
        .where('recipient', isEqualTo: currentUser.email)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }
}
