import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unimind/views/selectavatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WeaknessesSelect extends StatefulWidget {
  const WeaknessesSelect({super.key});

  @override
  State<WeaknessesSelect> createState() => _WeaknessesSelectState();
}

class _WeaknessesSelectState extends State<WeaknessesSelect> {
  final List<String> _skills = [
    "Coding",
    "UI/UX Design",
    "Research Writing",
    "Video Editing",
    "Math",
  ];

  final List<String> _selectedSkills = [];

  void _toggleSkill(String skill) {
    setState(() {
      if (_selectedSkills.contains(skill)) {
        _selectedSkills.remove(skill);
      } else {
        _selectedSkills.add(skill);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 🔹 Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/background1.jpg",
              fit: BoxFit.cover,
            ),
          ),

          Column(
            children: [
              // 🔹 App Bar
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

              // 🔹 Progress Bar
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
                    width: size.width * (233 / size.width), 
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB41214),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 🔹 Title
              Text(
                "Weaknesses",
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFB41214),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Areas you want to improve",
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 30),

              // 🔹 Skills List (centered, 75% width)
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85, // 75% width
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ..._skills.map((skill) {
                        final isSelected = _selectedSkills.contains(skill);
                        return ChoiceChip(
                          label: Text(
                            skill,
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                          selected: isSelected,
                          showCheckmark: false, // 🔹 remove check icon
                          selectedColor: const Color(0xFFB41214),
                          backgroundColor: Colors.white,
                          shape: StadiumBorder(
                            side: BorderSide(
                              color: isSelected ? const Color(0xFFB41214) : Colors.black,
                            ),
                          ),
                          onSelected: (_) => _toggleSkill(skill),
                        );
                      }),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0), // Adjust the value as needed
                        child: Text(
                          "See more …",
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFB41214),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 🔹 Selected Skills Box (centered, 75% width, fixed height)
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85, // 75% width
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Things you’d like to get better at:",
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 250, // 🔹 fixed height
                        width: MediaQuery.of(context).size.width * 0.85,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color.fromARGB(255, 221, 220, 220)),
                        ),
                        child: SingleChildScrollView( // 🔹 scroll inside if overflow
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _selectedSkills.map((skill) {
                              return Chip(
                                label: Text(
                                  skill, 
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12, // Smaller font size
                                  ),
                                ),
                                backgroundColor: const Color(0xFFB41214),
                                shape: StadiumBorder(),
                                labelStyle: const TextStyle(color: Colors.white),
                                deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white), // Smaller icon
                                onDeleted: () {
                                  setState(() {
                                    _selectedSkills.remove(skill);
                                  });
                                },
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // Reduce padding
                                visualDensity: VisualDensity.compact, // Makes the chip more compact
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduces touch target size
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // 🔹 Bottom Navigation
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
                        onPressed: _selectedSkills.isEmpty
                        ? null
                        : () async {
                            final user = FirebaseAuth.instance.currentUser;

                            if (user != null) {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .update({
                                'weaknesses': _selectedSkills, // 🔹 save array of strings
                              });

                              debugPrint("Saved weaknesses: $_selectedSkills");
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AvatarSelect(),
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
              const SizedBox(height: 50),
            ],
          ),
        ],
      ),
    );
  }
}