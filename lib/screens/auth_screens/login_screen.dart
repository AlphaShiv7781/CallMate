import 'package:callmate/screens/home_screen/home_screen.dart';
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
      setState(() {
        isLoading = true;
      });
      await auth.signInWithGoogle(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Sign-in successful")));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error signing in: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Sign-in failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 250),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                  "Welcome to CallMate",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.teal
                ),
              ),
              SizedBox(height: 14,),
              SizedBox(
                height: 140,
                width: 140,
                child: Image.asset('assets/images/CallMate-Bg.png'),
              ),
              SizedBox(height: 24,),
              SizedBox(
                width: 300,
                child: Text(
                  "Sign in to connect with friends and make video calls instantly",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 80 , right: 80 , top: 60),
                child: Center(
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.teal,)
                      : ElevatedButton(
                    style: ElevatedButton.styleFrom(

                    ),
                          onPressed: () => signInWithGoogle(context),
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Image(image: AssetImage('assets/images/Google-Icon.png'),height: 40 , width: 40,),
                                  const Text("Sign in with Google", style: TextStyle(color: Colors.teal),)
                                ],
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
