import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/notification_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    NotificationService.globalContext = context; // 👈 Set context here
    checkAuth();
  }

  void checkAuth() async {
    await Future.delayed(const Duration(seconds: 3)); // splash delay
    if (FirebaseAuth.instance.currentUser != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            Image(
                image: AssetImage(
                    'assets/images/CallMate-Bg.png'),
            ),

            const Text(
                'Connect with people around you via Videochat',
              style: TextStyle(
                fontSize: 15 ,
                 color: Colors.blueGrey,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic
              ),
            ),

          ],
        ),
      ),
    );
  }
}
