import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unimind/views/profile_setup/program_year.dart';
import 'package:unimind/views/profile_setup/selectavatar.dart'; 
import 'package:unimind/views/profile_setup/strengths.dart';
import 'package:unimind/views/profile_setup/weaknesses.dart';
import 'package:unimind/views/profile_setup/gender.dart';
import 'package:unimind/views/profile_setup/collegedep.dart';
import 'package:unimind/views/home/home_page.dart';

class SelectionPage extends StatefulWidget {
  const SelectionPage({super.key});

  @override
  State<SelectionPage> createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  int _currentStep = 0;
  String? _selectedGender;
  String? _selectedCollege; 
  String? _selectedProgram;
  String? _selectedProgramAcronym;
  int? _selectedYear;
  String? _selectedPlace;
  List<String> _selectedStrengths = [];
  List<String> _selectedWeaknesses = [];

  String? _selectedAvatarPathOrUrl;

  @override
  void initState() {
    super.initState();
  }

  bool _canContinue() {
    switch (_currentStep) {
      case 0: // Gender
        return _selectedGender != null;
      case 1: // College
        return _selectedCollege != null;
      case 2: // Program & Year
        return _selectedProgram != null &&
            _selectedProgramAcronym != null &&
            _selectedYear != null &&
            _selectedPlace != null;
      case 3: // Strengths
        return _selectedStrengths.isNotEmpty;
      case 4: // Weaknesses
        return _selectedWeaknesses.isNotEmpty;
      case 5: // Avatar
        return _selectedAvatarPathOrUrl != null;
      default:
        return false;
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _goNext() {
    if (_currentStep == 1) {
      _selectedProgram = null;
      _selectedProgramAcronym = null;
      _selectedYear = null;
      _selectedPlace = null;
    }

    if (_canContinue()) {
      if (_currentStep < 5) {
        setState(() => _currentStep++);
      } else {
        _saveProfileData();
      }
    }
  }

  Future<void> _saveProfileData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Map<String, dynamic> profileData = {
          'gender': _selectedGender,
          'department': _selectedCollege,
          'program': _selectedProgram,
          'programAcronym': _selectedProgramAcronym,
          'yearLevel': _selectedYear,
          'place': _selectedPlace,
          'strengths': _selectedStrengths,
          'weaknesses': _selectedWeaknesses,
          'profileComplete': true,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (_selectedAvatarPathOrUrl != null) {
          profileData['avatarPath'] = _selectedAvatarPathOrUrl;
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update(profileData);

        debugPrint("Profile data saved successfully!");

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      }
    } catch (e) {
      debugPrint("Error saving profile data: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving profile: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final List<Widget> steps = [
      GenderSelectionPage(
        onSelect: (gender) {
          setState(() => _selectedGender = gender);
        },
      ),
      CollegeDepSelect(
        onSelect: (college) {
          setState(() => _selectedCollege = college);
        },
      ),
      ProgramYearSelect(
        departmentCode: _selectedCollege ?? 'CCE',
        onSelect: (program, acronym, year, place) {
          setState(() {
            _selectedProgram = program;
            _selectedProgramAcronym = acronym;
            _selectedYear = year;
            _selectedPlace = place;
          });
        },
      ),
      StrengthsSelect(
        onSelect: (strengths) {
          setState(() => _selectedStrengths = strengths);
        },
      ),
      WeaknessesSelect(
        disabledWeaknesses: _selectedStrengths, 
        onSelect: (weaknesses) {
          setState(() => _selectedWeaknesses = weaknesses);
        },
      ),

      AvatarSelect(
        departmentCode:
            _selectedCollege ?? 'CCE', 
        onSelect: (pathOrUrl) {
          setState(() {
            _selectedAvatarPathOrUrl =
                pathOrUrl;
          });
        },
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/background1.jpg", fit: BoxFit.cover),
          ),

          SafeArea(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 10, 10, 10),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/icon/logoIconMaroon.png",
                        width: 40,
                        height: 40,
                      ),
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

                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Stack(
                      children: [
                        Container(
                          height: 6,
                          width: double.infinity,
                          color: Colors.grey[300],
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          height: 6,
                          width:
                              (size.width - 48) *
                              ((_currentStep + 1) / steps.length),
                          color: const Color(0xFFB41214),
                        ),
                      ],
                    ),
                  ),
                ),

                  Expanded(child: steps[_currentStep]),

                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.1,
                    vertical: 20,
                  ),
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
                          minimumSize: Size(size.width * 0.38, 50),
                        ),
                        onPressed: _currentStep == 0 ? null : _goBack,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.arrow_back,
                              size: 18,
                              color: Color(0xFFB41214),
                            ),
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
                          backgroundColor: _canContinue()
                              ? const Color(0xFFB41214)
                              : Colors.grey[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          minimumSize: Size(size.width * 0.38, 50),
                        ),
                        onPressed: _canContinue() ? _goNext : null,
                        child: Row(
                          children: [
                            Text(
                              _currentStep == steps.length - 1
                                  ? "Finish"
                                  : "Continue",
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _canContinue()
                                    ? Colors.white
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward,
                              size: 18,
                              color: _canContinue()
                                  ? Colors.white
                                  : Colors.grey[600],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
