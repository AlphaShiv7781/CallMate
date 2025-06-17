import 'package:callmate/services/user_retrieval_services.dart';
import 'package:flutter/material.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  UserRetrieval userRetrieval = UserRetrieval();
  String buttonLabel = "Add Friend";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: userRetrieval.fetchFilteredUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data ?? [];

          return users.isEmpty?Center(
            child: Text('No User Available'),
          ):Padding(
            padding: const EdgeInsets.only(top: 40.0, left: 10, right: 10),
            child: GridView.builder(
              itemCount: users.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns
                crossAxisSpacing: 8, // Horizontal spacing between grid items
                mainAxisSpacing: 8, // Vertical spacing between grid items
                childAspectRatio: 0.75, // Width to height ratio of each item
              ),
              itemBuilder: (context, index) {
                final user = users[index];
                return Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.teal, // Border color
                      width: 1.5, // Border width
                    ),
                    color: Colors.teal[50],
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
                          backgroundImage: NetworkImage(user['photoUrl'] ?? ""),
                        ),
                      ),
                      SizedBox(height: 10,),
                      Text(user['name'] ?? "No Name" , style: TextStyle(fontWeight: FontWeight.w600, color: Colors.teal),),
                      SizedBox(height: 10,),
                      ElevatedButton(
                        onPressed: (){
                          userRetrieval.sendFriendRequest(user['uid']);
                          setState(() {
                            buttonLabel = "Request Sent";
                          });
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text("Friend Request Sent")));
                        },
                        child: Text(buttonLabel,style: TextStyle(color: Colors.teal),),
                      ),
                    ],
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

// ListTile(
// leading: CircleAvatar(
// backgroundImage: NetworkImage(user['photoUrl'] ?? ""),
// ),
// title: Text(user['name'] ?? "No Name"),
// subtitle: Text(user['email']),
// trailing: ElevatedButton(
// onPressed: () => userRetrieval.sendFriendRequest(user['uid']),
// child: const Text("Add Friend"),
// ),
// );
