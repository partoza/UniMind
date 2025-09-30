import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Fixed AppBar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60), // Height of AppBar
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false, // Remove shadow
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.red,
                  width: 1,
                ), // Red bottom line
              ),
            ),
          ),
          title: Row(
            children: [
              // Logo
              Image.asset('assets/icon/logoIconMaroon.png', height: 40),
              const SizedBox(width: 8),
              // Styled Text
              RichText(
                text: TextSpan(
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  children: [
                    TextSpan(
                      text: "U",
                      style: const TextStyle(color: Color(0xFFB41214)),
                    ),
                    TextSpan(
                      text: "ni",
                      style: const TextStyle(color: Colors.black),
                    ),
                    TextSpan(
                      text: "M",
                      style: const TextStyle(color: Color(0xFFB41214)),
                    ),
                    TextSpan(
                      text: "ind",
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      body: Stack(
        children: [
          // Background image (fixed)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/bgWhite.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Foreground content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              child: Column(
                children: [
                  // Welcome text
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "WELCOME,",
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w800,
                            fontSize: 40,
                            color: const Color(0xFFB41214),
                          ),
                        ),
                        Text(
                          " John Rex", // second text
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w700,
                            fontSize: 30,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    height: 5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xffb41214), Color(0xfff7e5e5)],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Colors.black, // default text color
                      ),
                      children: [
                        const TextSpan(text: "UniMind is a "),
                        TextSpan(
                          text: "peer-to-peer study",
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFB41214), // red
                          ),
                        ),
                        const TextSpan(
                          text:
                              " mobile application designed to connect learners in university.",
                        ),
                        const TextSpan(text: " in a safe, interactive space."),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Color(0xFFB41214),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              textAlign: TextAlign.justify,
                              text: TextSpan(
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                                children: [
                                  const TextSpan(
                                    text: "Terms and Condition\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const TextSpan(text: "By using "),
                                  TextSpan(
                                    text: "UniMind",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFB41214),
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ", you agree to the following:\n\n",
                                  ),

                                  // Purpose of Use
                                  TextSpan(
                                    text: "Purpose of Use – ",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFB41214),
                                    ),
                                  ),
                                  const TextSpan(
                                    text:
                                        "The app is designed for peer-to-peer learning, study collaboration, and knowledge sharing. You agree to use it only for educational purposes.\n\n",
                                  ),

                                  // Respectful Behavior
                                  TextSpan(
                                    text: "Respectful Behavior – ",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFB41214),
                                    ),
                                  ),
                                  const TextSpan(
                                    text:
                                        "You will treat all members with respect and avoid offensive, harmful, or inappropriate content.\n\n",
                                  ),

                                  // Content Sharing
                                  TextSpan(
                                    text: "Content Sharing – ",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFB41214),
                                    ),
                                  ),
                                  const TextSpan(
                                    text:
                                        "You are responsible for any notes, files, or messages you share. Do not upload false, misleading, or copyrighted material without permission.\n\n",
                                  ),

                                  // Account Responsibility
                                  TextSpan(
                                    text: "Account Responsibility – ",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFB41214),
                                    ),
                                  ),
                                  const TextSpan(
                                    text:
                                        "You are responsible for the safety of your account. Sharing login details or impersonating others is not allowed.\n\n",
                                  ),

                                  // Compliance
                                  TextSpan(
                                    text: "Compliance – ",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFB41214),
                                    ),
                                  ),
                                  const TextSpan(
                                    text:
                                        "Users must follow the University of Mindanao’s rules and code of conduct. Violations may result in suspension or removal of your account.\n\n",
                                  ),

                                  // Privacy and Policy
                                  const TextSpan(
                                    text: "Privacy and Policy\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const TextSpan(
                                    text:
                                        "Your privacy is important to us. UniMind collects basic information such as your ",
                                  ),
                                  TextSpan(
                                    text:
                                        "name, gender, year level, department, and program",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFB41214),
                                    ),
                                  ),
                                  const TextSpan(
                                    text:
                                        " to personalize your learning experience, connect you with suitable study peers, and improve our services. We do not sell or share your personal data with third parties. All information is used solely within UniMind for educational and research purposes. You may also request account deletion and data removal at any time.",
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Checkbox + Button
                  Row(
                    children: [
                      Checkbox(
                        value: isChecked,
                        activeColor: const Color(0xFFB41214),
                        onChanged: (value) {
                          setState(() {
                            isChecked = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: Text(
                          "I agree to the Terms and Conditions and Privacy Policy",
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isChecked
                          ? () {
                              // Navigate next
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB41214),
                        disabledBackgroundColor: Colors.grey.shade400,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Continue",
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
