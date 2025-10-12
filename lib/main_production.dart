import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unimind/views/loading/loading_page.dart';
import 'package:unimind/views/profile_setup/selectionpage.dart';
import 'package:unimind/views/auth/login_page.dart';
import 'package:unimind/views/home/home_page.dart';
import 'package:unimind/widgets/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getLandingPage() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return const LoginPage();
      }

      // Show loading while checking profile
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
    } catch (e) {
      // Handle Firebase errors gracefully
      debugPrint("Error getting landing page: $e");
      return const LoginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "UniMind",
      home: FutureBuilder<Widget>(
        future: _getLandingPage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show enhanced loading screen while checking
            return const LoadingWidget(
              message: "Loading UniMind...",
              showLogo: true,
            );
          } else if (snapshot.hasError) {
            // Enhanced error handling
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Color(0xFFB41214),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Something went wrong",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Please check your internet connection and try again",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // Restart the app
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const MyApp(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB41214),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text("Try Again"),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return snapshot.data!;
          }
        },
      ),
    );
  }
}
