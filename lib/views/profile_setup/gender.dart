import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unimind/views/profile_setup/collegedep.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GenderSelectionPage extends StatefulWidget {
  const GenderSelectionPage({super.key});

  @override
  State<GenderSelectionPage> createState() => _GenderSelectionPageState();
}

class _GenderSelectionPageState extends State<GenderSelectionPage> {
  String? _selectedGender; // 🔹 Track which button is selected

  Widget _buildGenderButton(String text, double width) {
    final isSelected = _selectedGender == text;

    return SizedBox(
      width: width * 0.6,
      height: 46,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? const Color.fromARGB(255, 122, 9, 11) // darker red if selected
              : const Color(0xFFB41214), // normal red
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () {
          setState(() {
            _selectedGender = text; // update state
          });
          debugPrint("$text selected");
        },
        child: Text(
          text,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/background1.jpg",
              fit: BoxFit.cover,
            ),
          ),

          Column(
            children: [
              // 🔴 App Bar Section
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

              const SizedBox(height: 40), // 🔹 below App Bar

              // 🔴 Progress Bar
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
                    width: size.width * 0.12, // 12% width (progress step)
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB41214),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40), // 🔹 below Progress Bar

              // 🔴 Title
              Text(
                "Choose your Gender",
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFB41214),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "How do you identify?",
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 30),

              // 🔹 Gender Buttons
              Column(
                children: [
                  _buildGenderButton("Male", size.width),
                  const SizedBox(height: 15),
                  _buildGenderButton("Female", size.width),
                  const SizedBox(height: 15),
                  _buildGenderButton("Others", size.width),
                ],
              ),

              const Spacer(),

              // 🔹 Bottom Navigation
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.1, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFB41214)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        minimumSize: Size(size.width * 0.38, 50), // 🔹 wider & taller
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center, // centers content
                        children: [
                          const Icon(Icons.arrow_back, size: 18, color: Color(0xFFB41214)),
                          const SizedBox(width: 6),
                          Text(
                            "Back",
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFB41214),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Continue Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedGender == null
                            ? Colors.grey // 🔹 Disabled state
                            : const Color(0xFFB41214),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        minimumSize: Size(size.width * 0.38, 50), // 🔹 wider & taller
                      ),
                      onPressed: _selectedGender == null
                      ? null
                      : () async {
                          final user = FirebaseAuth.instance.currentUser;

                          if (user != null) {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .update({
                              'gender': _selectedGender,
                            });

                            debugPrint("Gender saved: $_selectedGender");
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CollegeDepSelect(),
                            ),
                          );
                        },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center, // centers content
                        children: [
                          Text(
                            "Continue",
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),
            ],
          ),
        ],
      ),
    );
  }
}