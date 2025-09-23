import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unimind/views/program_year.dart';
import 'package:unimind/views/selectavatar.dart';
import 'package:unimind/views/strengths.dart';
import 'package:unimind/views/weaknesses.dart';
import 'gender.dart';
import 'collegedep.dart';

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
  int? _selectedYear;
  List<String> _selectedStrengths = [];
  List<String> _selectedWeaknesses = [];
  File? _hasSelectedAvatar; // Default avatar is auto-selected

  late final List<Widget> _steps;

  @override
  void initState() {
    super.initState();
    _steps = [
      GenderSelectionPage(
        onSelect: (gender) {
          setState(() {
            _selectedGender = gender;
          });
        },
      ),
      CollegeDepSelect(
        onSelect: (college) {
          setState(() {
            _selectedCollege = college;
          });
        },
      ),
      ProgramYearSelect(
        onSelect: (program, year) { // Change to accept two separate parameters
          setState(() {
            _selectedProgram = program;
            _selectedYear = year;
          });
        },
      ),
      StrengthsSelect(
        onSelect: (strengths) {
          setState(() {
            _selectedStrengths = strengths;
          });
        },
      ),
      WeaknessesSelect(
        onSelect: (weaknesses) {
          setState(() {
            _selectedWeaknesses = weaknesses;
          });
        },
      ),
      AvatarSelect(
        onSelect: (hasSelection) {
          setState(() {
            _hasSelectedAvatar = hasSelection;
          });
        },
      ),
    ];
  }

  // Check if current step has valid selection
  bool _canContinue() {
    switch (_currentStep) {
      case 0: // Gender
        return _selectedGender != null;
      case 1: // College
        return _selectedCollege != null;
      case 2: // Program & Year
        return _selectedProgram != null && _selectedYear != null;
      case 3: // Strengths
        return _selectedStrengths.isNotEmpty;
      case 4: // Weaknesses
        return _selectedWeaknesses.isNotEmpty;
      case 5: // Avatar
        return _hasSelectedAvatar != null;
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
    if (_canContinue()) {
      if (_currentStep < _steps.length - 1) {
        setState(() => _currentStep++);
      } else {
        debugPrint("🎉 Finished all steps!");
        // Navigate to next screen or complete setup
      }
    }
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

          SafeArea(
            child: Column(
              children: [
                // 🔴 App Bar
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
                      Image.asset("assets/Logo2.png",
                          width: 60, height: 60),
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

                // 🔴 Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                          width: (size.width - 48) * ((_currentStep + 1) / _steps.length),
                          color: const Color(0xFFB41214),
                        ),
                      ],
                    ),
                  ),
                ),

                // 🔴 Step content
                Expanded(child: _steps[_currentStep]),
                
                // 🔴 Navigation buttons
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.1, vertical: 20),
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
                            const Icon(Icons.arrow_back,
                                size: 18, color: Color(0xFFB41214)),
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
                              _currentStep == _steps.length - 1
                                  ? "Finish"
                                  : "Continue",
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _canContinue() ? Colors.white : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward,
                              size: 18,
                              color: _canContinue() ? Colors.white : Colors.grey[600],
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
