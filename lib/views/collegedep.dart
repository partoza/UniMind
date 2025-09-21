import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unimind/views/program_year.dart';

class CollegeDepSelect extends StatefulWidget {
  const CollegeDepSelect({super.key});

  @override
  State<CollegeDepSelect> createState() => _CollegeDepSelectState();
}

class _CollegeDepSelectState extends State<CollegeDepSelect> {
  String _selectedDepartment = "";

  Widget _buildDepartmentOption(String label, String imagePath, String value) {
  final isSelected = _selectedDepartment == value;

  return InkWell(
    onTap: () {
      setState(() {
        _selectedDepartment = value;
      });
      debugPrint("$label selected");
    },
    borderRadius: BorderRadius.circular(10),
    child: Container(
      width: 320,
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFB41214) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color.fromARGB(255, 221, 220, 220), width: 1),
      ),
      child: Row(
        children: [
          // 🔹 Department logo
          Image.asset(
            imagePath,
            width: 36,
            height: 36,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 12),

          // 🔹 Department name
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                // Icon color
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ),

          // 🔹 Circle (check when selected, empty when not)
          Icon(
            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
            // Icon color
            color: isSelected ? Colors.white : Colors.black,
            size: 20,
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // 🔹 get screen size

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
                width: size.width * 0.7, // 🔹 70% of screen width
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: size.width * 0.15, // 🔹 15% of screen width
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
                "College Department",
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFB41214),
                ),
              ),
              const SizedBox(height: 8),

              Text(
                "What department do you belong",
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 30),

              // Department Options
              Column(
                children: [
                  _buildDepartmentOption("College of Computing Education", "assets/ccelogo.png", "CCE"),
                  const SizedBox(height: 15), // 🔹 Consistent gap
                  _buildDepartmentOption("College of Arts and Science Education", "assets/caselogo.png", "CAS"),
                  const SizedBox(height: 15),
                  _buildDepartmentOption("College of Engineering Education", "assets/ceelogo.png", "CEE"),
                ],
              ),

              const Spacer(),

              // 🔴 Bottom Navigation
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.1, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 🔹 Back Button
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFB41214)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16), // 🔹 increase height
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

                    const SizedBox(width: 30), // space between buttons

                    // 🔹 Continue Button
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProgramYearSelect(),
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
