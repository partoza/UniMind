import 'package:flutter/material.dart';
import 'package:unimind/views/loadingpage.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  // Ensures binding is ready before Firebase init
  WidgetsFlutterBinding.ensureInitialized(); 
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp()); 
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoadingPage(),
    );
  }
}
