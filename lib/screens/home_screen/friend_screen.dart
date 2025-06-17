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
      body: Padding(
        padding: const EdgeInsets.only(top: 40.0, left: 10, right: 10),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: userRetrieval.fetchFriends(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final friends = snapshot.data ?? [];

            if (friends.isEmpty) {
              return const Center(child: Text("No friends yet"));
            }


            return GridView.builder(
              itemCount: friends.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns
                crossAxisSpacing: 8, // Horizontal spacing between grid items
                mainAxisSpacing: 8, // Vertical spacing between grid items
                childAspectRatio: 0.75, // Width to height ratio of each item
              ),
              itemBuilder: (context, index) {
                final friend = friends[index];
                return Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.teal, // Border color
                        width: 1.5, // Border width
                      ),
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 10,),
                      Container(
                        padding: EdgeInsets.all(2), // Border width
                        decoration: BoxDecoration(
                          color: Colors.transparent, // Background color
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.teal, // Border color
                            width: 3.0,         // Border width
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(friend['photoUrl'] ?? ""),
                        ),
                      ),
                      SizedBox(height: 10,),
                      Text(friend['name'] ?? "No Name" , style: TextStyle(fontWeight: FontWeight.w600, color: Colors.teal),),
                      SizedBox(height: 10,),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[50],),
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
                        child: const Text("Call",style: TextStyle(color: Colors.teal),),
                      ),

                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}



