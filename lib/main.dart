import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:unimind/views/loading/loading_page.dart';
import 'package:unimind/views/profile_setup/selectionpage.dart';
import 'package:unimind/views/auth/login_page.dart';
import 'package:unimind/views/home/home_page.dart';
import 'package:unimind/views/match/matched.dart';
import 'package:unimind/views/profile_setup/gender.dart';
import 'package:unimind/views/profile_setup/collegedep.dart';
import 'package:unimind/views/profile_setup/program_year.dart';
import 'package:unimind/views/profile_setup/selectavatar.dart';
import 'package:unimind/views/profile_setup/strengths.dart';
import 'package:unimind/views/profile_setup/weaknesses.dart';
import 'package:unimind/widgets/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

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

  Future<void> _testFirebaseConnection(BuildContext context) async {
    try {
      // Test Firebase connection
      final firestore = FirebaseFirestore.instance;
      
      // Try to read from Firestore
      await firestore.collection('test').limit(1).get();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Firebase connection successful!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Firebase connection failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
