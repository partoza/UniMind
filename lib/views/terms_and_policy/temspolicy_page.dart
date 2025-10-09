import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _isScrolled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Container(
              child: const Icon(
                Icons.arrow_back_ios_rounded,
                size: 18,
                color: Color(0xFFB41214),
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modern logo with subtle shadow
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset('assets/icon/logoIconMaroon.png', height: 36),
              ),
            ),
            const SizedBox(width: 12),
            // Brand name with modern typography
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      height: 1.1,
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
                Text(
                  "Study ta GA!",
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Empty container to balance the leading button
          Container(
            width: 56,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFFB41214).withOpacity(0.3),
                  const Color(0xFFB41214).withOpacity(0.6),
                  const Color(0xFFB41214).withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background image with modern blur effect
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/bgWhite.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content with modern design
          SafeArea(
            child: Column(
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "WELCOME,",
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w800,
                          fontSize: 32,
                          color: const Color(0xFFB41214),
                          height: 1.1,
                        ),
                      ),
                      Text(
                        "GA!",
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w700,
                          fontSize: 28,
                          color: Colors.black87,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFB41214),
                              const Color(0xFFB41214).withOpacity(0.5),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(text: "UniMind is a "),
                            TextSpan(
                              text: "peer-to-peer study",
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFB41214),
                              ),
                            ),
                            const TextSpan(
                              text: " mobile application designed to connect learners in university in a safe, interactive space.",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Terms Content with Modern Card
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFFB41214).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (scrollNotification) {
                            if (scrollNotification is ScrollUpdateNotification) {
                              setState(() {
                                _isScrolled = scrollNotification.metrics.pixels > 0;
                              });
                            }
                            return false;
                          },
                          child: Column(
                            children: [
                              // Sticky Header
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: _isScrolled
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFB41214),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "Terms & Privacy",
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Scrollable Content
                              Expanded(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildSectionTitle("Terms and Conditions"),
                                      const SizedBox(height: 8),
                                      RichText(
                                        textAlign: TextAlign.justify,
                                        text: TextSpan(
                                          style: GoogleFonts.montserrat(
                                            fontSize: 14,
                                            color: Colors.black87,
                                            height: 1.6,
                                          ),
                                          children: [
                                            const TextSpan(text: "By using "),
                                            TextSpan(
                                              text: "UniMind",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFFB41214),
                                              ),
                                            ),
                                            const TextSpan(
                                              text: ", you agree to the following:\n\n",
                                            ),
                                          ],
                                        ),
                                      ),

                                      _buildTermItem(
                                        "Purpose of Use",
                                        "The app is designed for peer-to-peer learning, study collaboration, and knowledge sharing. You agree to use it only for educational purposes.",
                                      ),
                                      _buildTermItem(
                                        "Respectful Behavior",
                                        "You will treat all members with respect and avoid offensive, harmful, or inappropriate content.",
                                      ),
                                      _buildTermItem(
                                        "Content Sharing",
                                        "You are responsible for any notes, files, or messages you share. Do not upload false, misleading, or copyrighted material without permission.",
                                      ),
                                      _buildTermItem(
                                        "Account Responsibility",
                                        "You are responsible for the safety of your account. Sharing login details or impersonating others is not allowed.",
                                      ),
                                      _buildTermItem(
                                        "Compliance",
                                        "Users must follow the University of Mindanao's rules and code of conduct. Violations may result in suspension or removal of your account.",
                                      ),

                                      const SizedBox(height: 24),

                                      _buildSectionTitle("Privacy Policy"),
                                      const SizedBox(height: 8),
                                      RichText(
                                        textAlign: TextAlign.justify,
                                        text: TextSpan(
                                          style: GoogleFonts.montserrat(
                                            fontSize: 14,
                                            color: Colors.black87,
                                            height: 1.6,
                                          ),
                                          children: [
                                            const TextSpan(
                                              text: "Your privacy is important to us. UniMind collects basic information such as your ",
                                            ),
                                            TextSpan(
                                              text: "name, gender, year level, department, and program",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFFB41214),
                                              ),
                                            ),
                                            const TextSpan(
                                              text: " to personalize your learning experience, connect you with suitable study peers, and improve our services. We do not sell or share your personal data with third parties. All information is used solely within UniMind for educational and research purposes. You may also request account deletion and data removal at any time.",
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom spacing
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: const Color(0xFFB41214),
        ),
      ),
    );
  }

  Widget _buildTermItem(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6, right: 8),
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFFB41214),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  "$title – ",
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFB41214),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Text(
              content,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.black87,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}