import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRetrieval{

  final currentUser = FirebaseAuth.instance.currentUser;

  Future<List<Map<String, dynamic>>> fetchAllUsersExceptMe() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final snapshot = await FirebaseFirestore.instance.collection('users').get();

    return snapshot.docs
        .where((doc) => doc.id != currentUser?.uid)
        .map((doc) => doc.data())
        .cast<Map<String, dynamic>>()
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchFilteredUsers() async {
    final currentUserDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
    final List<dynamic> myFriends = currentUserDoc['friends'] ?? [];
    final List<dynamic> myRequests = currentUserDoc['requests'] ?? [];

    final allUsersSnapshot = await FirebaseFirestore.instance.collection('users').get();

    return allUsersSnapshot.docs
        .where((doc) {
      final data = doc.data();
      final uid = data['uid'];
      return uid != currentUser?.uid &&        // not yourself
          !myFriends.contains(uid) &&       // not already a friend
          !myRequests.contains(uid);        // not already requested
    })
        .map((doc) => doc.data())
        .cast<Map<String, dynamic>>()
        .toList();
  }


  Future<List<Map<String, dynamic>>> fetchRequests() async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
    final List<dynamic> requests = userDoc.data()?['requests'] ?? [];

    List<Map<String, dynamic>> requestUsers = [];

    for (String requesterId in requests) {
      final requesterDoc = await FirebaseFirestore.instance.collection('users').doc(requesterId).get();
      requestUsers.add(requesterDoc.data()!);
    }

    return requestUsers;
  }

  Future<void> sendFriendRequest(String targetUid) async {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    final targetRef = FirebaseFirestore.instance.collection('users').doc(targetUid);

    await targetRef.update({
      'requests': FieldValue.arrayUnion([myUid])
    });
  }

  Future<void> acceptFriendRequest(String requesterUid) async {
    final myUid = FirebaseAuth.instance.currentUser!.uid;
    final myRef = FirebaseFirestore.instance.collection('users').doc(myUid);
    final requesterRef = FirebaseFirestore.instance.collection('users').doc(requesterUid);

    // Add each other to 'friends'
    await myRef.update({
      'friends': FieldValue.arrayUnion([requesterUid]),
      'requests': FieldValue.arrayRemove([requesterUid]),
    });

    await requesterRef.update({
      'friends': FieldValue.arrayUnion([myUid]),
    });
  }

  Future<void> rejectRequest(String requesterUid) async {
    final myUid = currentUser!.uid;

    final myRef = FirebaseFirestore.instance.collection('users').doc(myUid);
    await myRef.update({
      'requests': FieldValue.arrayRemove([requesterUid]),
    });
  }

  Future<List<Map<String, dynamic>>> fetchFriends() async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
    final List<dynamic> friendUids = userDoc['friends'] ?? [];

    List<Map<String, dynamic>> friendsData = [];

    for (String uid in friendUids) {
      final friendDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      friendsData.add(friendDoc.data()!);
    }

    return friendsData;
  }

}