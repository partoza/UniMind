import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unimind/views/loading/loading_page.dart';
import 'package:unimind/views/profile_setup/selectionpage.dart';
import 'package:unimind/views/auth/login_page.dart';
import 'package:unimind/views/home/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getLandingPage() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const LoginPage();
    }

    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    final data = snapshot.data();
    final profileComplete = data?["profileComplete"] ?? false;

    if (profileComplete) {
      return const HomePage();
    } else {
      return const SelectionPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "UniMind",
      home: Container(
        color: Colors.white, // Set background color to white
        child: FutureBuilder<Widget>(
          future: _getLandingPage(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show your loading screen while checking
              return const LoadingPage();
            } else if (snapshot.hasError) {
              return const Scaffold(
                body: Center(child: Text("Something went wrong")),
              );
            } else {
              return snapshot.data!;
            }
          },
        ),
      ),
    );
  }
}