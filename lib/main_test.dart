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
import 'package:unimind/views/home/skeleton_test.dart';
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
      title: "UniMind Test",
      home: const TestNavigationPage(),
    );
  }
}

class TestNavigationPage extends StatelessWidget {
  const TestNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('UniMind Test Navigation'),
        backgroundColor: const Color(0xFFB41214),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test Screens',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB41214),
              ),
            ),
            const SizedBox(height: 20),
            
            // Authentication & Setup Screens
            _buildSectionTitle('Authentication & Setup'),
            _buildTestButton(
              context,
              'Loading Page',
              'Initial loading screen',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoadingPage())),
            ),
            _buildTestButton(
              context,
              'Login Page',
              'User authentication screen',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())),
            ),
            _buildTestButton(
              context,
              'Profile Setup (SelectionPage)',
              'Complete profile setup flow',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SelectionPage())),
            ),
            
            const SizedBox(height: 20),
            
            // Individual Profile Setup Steps
            _buildSectionTitle('Profile Setup Steps'),
            _buildTestButton(
              context,
              'Gender Selection',
              'Gender selection step',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GenderSelectionPage())),
            ),
            _buildTestButton(
              context,
              'College Department',
              'Department selection step',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CollegeDepSelect())),
            ),
            _buildTestButton(
              context,
              'Program & Year',
              'Program and year selection step',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProgramYearSelect(onSelect: (program, year) {}))),
            ),
            _buildTestButton(
              context,
              'Strengths Selection',
              'Strengths selection step',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => StrengthsSelect(onSelect: (strengths) {}))),
            ),
            _buildTestButton(
              context,
              'Weaknesses Selection',
              'Weaknesses selection step',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => WeaknessesSelect(onSelect: (weaknesses) {}))),
            ),
            _buildTestButton(
              context,
              'Avatar Selection',
              'Avatar selection step',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => AvatarSelect(onSelect: (avatar) {}))),
            ),
            
            const SizedBox(height: 20),
            
            // Main App Screens
            _buildSectionTitle('Main App Screens'),
            _buildTestButton(
              context,
              'Home Page',
              'Main home screen',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomePage())),
            ),
            _buildTestButton(
              context,
              'Matched Page',
              'Study partner match screen',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MatchedPage())),
            ),
            _buildTestButton(
              context,
              'Skeleton Loading Test',
              'Test skeleton loading effects',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SkeletonTestPage())),
            ),
            
            const SizedBox(height: 20),
            
            // Firebase Test
            _buildSectionTitle('Firebase Test'),
            _buildTestButton(
              context,
              'Test Firebase Connection',
              'Check Firebase connectivity',
              () => _testFirebaseConnection(context),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF333333),
        ),
      ),
    );
  }

  Widget _buildTestButton(
    BuildContext context,
    String title,
    String description,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFB41214),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          subtitle: Text(
            description,
            style: const TextStyle(
              color: Color(0xFF666666),
              fontSize: 12,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Color(0xFFB41214),
          ),
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
