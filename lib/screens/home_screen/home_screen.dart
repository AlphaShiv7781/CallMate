import 'package:callmate/screens/home_screen/userlist_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'friend_request_screen.dart';
import 'friend_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal[50],
          title: Row(
            children: [
              Text(
                'CallMate',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.teal
                ),
              ),
              SizedBox(width: 8),
              Image.asset(
                'assets/images/CallMate-Bg.png',
                width: 36,
                height: 36,
              ),
            ],
          ),
          bottom: TabBar(
            indicatorColor: Colors.teal,
            labelColor: Colors.teal,
            tabs: [
              Tab(text: "All Users"),                       // Chats Tab
              Tab(text: "Friends"),                      // Status Tab
              Tab(text: "Friend Requests"),                       // Calls Tab
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: InkWell(
                child: Row(
                  children: [
                    Text('Signout',style: TextStyle(color: Colors.teal ,fontWeight: FontWeight.w600),),
                    SizedBox(width: 2,),
                    Icon(Icons.logout , color: Colors.teal,),
                  ],
                ),
                onTap: ()async{
                   await FirebaseAuth.instance.signOut();
                   Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            )
          ],
        ),
        body: TabBarView(
          children: [
            UserListScreen(),
            FriendsScreen(),
            FriendRequestsScreen(),
          ],
        ),
      ),
    );
  }
}
