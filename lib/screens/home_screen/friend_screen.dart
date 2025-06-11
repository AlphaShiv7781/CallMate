import 'dart:convert';
import 'package:callmate/services/user_retrieval_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:callmate/screens/call_screen/call_screen.dart';
import 'package:http/http.dart' as http;

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  UserRetrieval userRetrieval=UserRetrieval();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Friends")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: userRetrieval.fetchFriends(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final friends = snapshot.data ?? [];

          if (friends.isEmpty) {
            return const Center(child: Text("No friends yet"));
          }

          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(friend['photoUrl'] ?? ""),
                ),
                title: Text(friend['name'] ?? ""),
                subtitle: Text(friend['email'] ?? ""),
                trailing: ElevatedButton(
                  onPressed: () async {
                    final callerUid = currentUser!.uid;
                    final calleeUid = friend['uid'];
                    final channelName = '${callerUid}_$calleeUid';

                    // New cloud function call
                    await http.post(
                      Uri.parse('https://us-central1-callmate-663f9.cloudfunctions.net/sendCallNotification'),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({
                        'targetUid': calleeUid,
                        'channelName': channelName,
                      }),
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CallScreen(channelName: channelName),
                      ),
                    );
                  },
                  child: const Text("Call"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
