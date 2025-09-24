import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// add this import (adjust path if your file is elsewhere)
import 'package:unimind/views/homepage.dart';

class ProfileSummaryPage extends StatelessWidget {
  const ProfileSummaryPage({super.key});

  Future<Map<String, dynamic>?> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return snapshot.data();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              "assets/background1.jpg",
              fit: BoxFit.cover,
            ),
          ),

          Column(
            children: [
              // App Bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 10, 10, 10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFB41214), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Image.asset("assets/UniMind Logo.png", width: 60, height: 60),
                    const SizedBox(width: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "U",
                            style: GoogleFonts.montserrat(
                              color: const Color(0xFFB41214),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: "ni",
                            style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: "M",
                            style: GoogleFonts.montserrat(
                              color: const Color(0xFFB41214),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: "ind",
                            style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Progress Bar
              Container(
                width: size.width * 0.7,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: size.width * (1.0), // full progress since it's last step
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB41214),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Title
              Text(
                "Profile Summary",
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFB41214),
                ),
              ),

              const SizedBox(height: 20),

              // Fetch Firestore
              Expanded(
                child: FutureBuilder<Map<String, dynamic>?>(
                  future: _getUserData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFFB41214)));
                    }

                    if (!snapshot.hasData || snapshot.data == null) {
                      return const Center(
                        child: Text(
                          "No profile data found",
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    }

                    final data = snapshot.data!;
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 70,
                            backgroundImage: data['avatarPath'] != null
                                ? AssetImage(data['avatarPath'])
                                : const AssetImage("assets/avatar1.jpg"),
                          ),
                          const SizedBox(height: 20),

                          // Name
                          Text(
                            data['displayName'] ?? "Unknown",
                            style: GoogleFonts.montserrat(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Course & Year
                          Text(
                            "${data['yearLevel'] ?? ''}, ${data['program'] ?? ''}",
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // College
                          if (data['department'] != null)
                            Text(
                              data['department'],
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),

                          const SizedBox(height: 30),

                          // Strengths
                          _buildSection("Strengths", data['strengths']),
                          // Weaknesses
                          _buildSection("Weaknesses", data['weaknesses']),
                          // Skills (if you store additional fields)
                          _buildSection("Skills", data['skills']),

                          const SizedBox(height: 40),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Nav
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.1, vertical: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB41214),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Continue",
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, dynamic values) {
    if (values == null || (values is List && values.isEmpty)) {
      return const SizedBox.shrink();
    }

    final list = values is List ? values.cast<String>() : <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFB41214),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: list.map((item) {
            return Chip(
              label: Text(
                item,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              backgroundColor: const Color(0xFFB41214),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
