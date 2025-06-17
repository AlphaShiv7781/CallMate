import 'package:callmate/services/user_retrieval_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  UserRetrieval userRetrieval = UserRetrieval();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: userRetrieval.fetchRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data ?? [];

          if (requests.isEmpty) {
            return const Center(child: Text("No friend requests"));
          }

          return Padding(
            padding: const EdgeInsets.only(top: 40.0 , left: 20 , right: 20),
            child: ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final user = requests[index];
                return Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.teal, // Border color
                        width: 1.5, // Border width
                      ),
                      color: Colors.teal[50],
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user['photoUrl'] ?? ""),
                    ),
                    title: Text(user['name'] ?? "",style: TextStyle(fontSize: 15),),
                    subtitle: Text(user['email'] ?? "",style: TextStyle(fontSize: 10),),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await userRetrieval.acceptFriendRequest(user['uid']);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Friend request accepted"),
                              ),
                            );

                            setState(() {});
                          },
                          child: const Icon(Icons.check, color: Colors.green),
                        ),

                        ElevatedButton(
                          onPressed: () async {
                            await userRetrieval.rejectRequest(user['uid']);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Friend request rejected"),
                              ),
                            );

                            setState(() {}); // refresh list
                          },
                          child: const Icon(Icons.close, color: Colors.red),
                        ),

                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
