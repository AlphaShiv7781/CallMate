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
      appBar: AppBar(title: const Text("Friend Requests")),
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

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final user = requests[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user['photoUrl'] ?? ""),
                ),
                title: Text(user['name'] ?? ""),
                subtitle: Text(user['email'] ?? ""),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: ()async{
                             await userRetrieval.acceptFriendRequest(user['uid']);
                             ScaffoldMessenger.of(context).showSnackBar(
                                     const SnackBar(content: Text("Friend request accepted")),
                                   );

                                   setState(() {});
                         },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: ()async{
                        await userRetrieval.rejectRequest(user['uid']);
                        ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Friend request rejected")),
                              );

                              setState(() {}); // refresh list
                        },
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
