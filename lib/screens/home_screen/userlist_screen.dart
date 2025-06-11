import 'package:callmate/services/user_retrieval_services.dart';
import 'package:flutter/material.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {

  UserRetrieval userRetrieval = UserRetrieval();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Users")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: userRetrieval.fetchFilteredUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data ?? [];

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user['photoUrl'] ?? ""),
                ),
                title: Text(user['name'] ?? "No Name"),
                subtitle: Text(user['email']),
                trailing: ElevatedButton(
                  onPressed: () => userRetrieval.sendFriendRequest(user['uid']),
                  child: const Text("Add Friend"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
