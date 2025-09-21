import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unimind/views/summarypage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AvatarSelect extends StatefulWidget {
  const AvatarSelect({super.key});

  @override
  State<AvatarSelect> createState() => _AvatarSelectState();
}

class _AvatarSelectState extends State<AvatarSelect> {
  int _selectedAvatar = -1;
  final List<String> _avatarImages = [
    "assets/avatar1.jpg",
    "assets/avatar2.jpg",
    "assets/avatar3.jpg",
    "assets/avatar4.jpg",
    "assets/avatar5.jpg",
  ];

  void _selectAvatar(int index) {
    setState(() {
      _selectedAvatar = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
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
                    width: size.width * (290 / size.width),
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB41214),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Title
              Text(
                "Choose Your Avatar",
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFB41214),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Select an avatar that represents you",
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 10),

              // Selected Avatar in Center
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Placeholder or selected avatar
                    if (_selectedAvatar >= 0)
                      CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        backgroundImage: AssetImage(_avatarImages[_selectedAvatar]),
                        radius: 130,
                      )
                    else
                      Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[200],
                          border: Border.all(
                            color: const Color(0xFFB41214),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 100,
                          color: Colors.grey[600],
                        ),
                      ),
                    
                    const SizedBox(height: 20),
                    
                    Text(
                      _selectedAvatar >= 0 ? "Your Selection" : "Select an avatar",
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              // Avatar Choices Grid (Below the selected avatar)
              Container(
                height: 150, // Fixed height for the grid
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5, // 5 avatars in a row
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _avatarImages.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _selectAvatar(index),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedAvatar == index
                                ? const Color(0xFFB41214)
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          backgroundImage: AssetImage(_avatarImages[index]),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              // Bottom Navigation
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.1, vertical: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFB41214)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size.fromHeight(50),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                    ),
                    const SizedBox(width: 30),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB41214),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size.fromHeight(50),
                        ),
                        onPressed: _selectedAvatar < 0
                        ? null
                        : () async {
                            final user = FirebaseAuth.instance.currentUser;

                            if (user != null) {
                              final selectedAvatarPath = _avatarImages[_selectedAvatar];

                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .update({
                                'avatarPath': selectedAvatarPath,
                                'profileComplete': true, // mark profile finished
                              });

                              debugPrint("Saved avatar: $selectedAvatarPath");
                            }

                            // Navigate to home/dashboard page after profile setup
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileSummaryPage(), 
                              ),
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
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ],
      ),
    );
  }
}