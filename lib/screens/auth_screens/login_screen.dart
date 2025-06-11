import 'package:callmate/screens/home_screen/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../../services/auth_services.dart' as auth;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool isLoading = false;

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
       await auth.signInWithGoogle(context);
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text("Sign-in successful")),
       );
       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomeScreen()));
    } catch (e) {
      print('Error signing in: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign-in failed")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign In")),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
          onPressed: ()=> signInWithGoogle(context),
          child: const Text("Sign in with Google"),
        ),
      ),
    );
  }
}
