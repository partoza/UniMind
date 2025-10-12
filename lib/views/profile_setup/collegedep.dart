import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CollegeDepSelect extends StatefulWidget {
  final Function(String)? onSelect;

  const CollegeDepSelect({super.key, this.onSelect});

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
        if (widget.onSelect != null) {
          widget.onSelect!(value); // 👈 notify parent (SelectionPage)
        }
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
          border: Border.all(
            color: const Color.fromARGB(255, 221, 220, 220),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // 🔹 Department logo
            Image.asset(imagePath, width: 36, height: 36, fit: BoxFit.cover),
            const SizedBox(width: 12),

            // 🔹 Department name
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),

            // 🔹 Circle (check when selected, empty when not)
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
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
    return Column(
      // Keep the main Column as is
      children: [
        const SizedBox(height: 20),

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
          "What department do you belong?",
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 30),

        // Department Options
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildDepartmentOption(
                  "College of Accounting Education",
                  "assets/depLogo/caelogo.png",
                  "CAE",
                ),
                const SizedBox(height: 10),
                _buildDepartmentOption(
                  "College of Architecture and Fine Arts Education",
                  "assets/depLogo/cafaelogo.png",
                  "CAFAE",
                ),
                const SizedBox(height: 10),
                _buildDepartmentOption(
                  "College of Arts and Science Education",
                  "assets/depLogo/caselogo.png",
                  "CASE",
                ),
                const SizedBox(height: 10),
                _buildDepartmentOption(
                  "College of Business Administration Education",
                  "assets/depLogo/cbaelogo.png",
                  "CBAE",
                ),
                const SizedBox(height: 10),
                _buildDepartmentOption(
                  "College of Computing Education",
                  "assets/depLogo/ccelogo.png",
                  "CCE",
                ),
                const SizedBox(height: 10),
                _buildDepartmentOption(
                  "College of Criminal Justice Education",
                  "assets/depLogo/ccjelogo.png",
                  "CCJE",
                ),
                const SizedBox(height: 10),
                _buildDepartmentOption(
                  "College of Engineering Education",
                  "assets/depLogo/ceelogo.png",
                  "CEE",
                ),
                const SizedBox(height: 10),
                _buildDepartmentOption(
                  "College of Hopitality Education",
                  "assets/depLogo/chelogo.png",
                  "CHE",
                ),
                const SizedBox(height: 10),
                _buildDepartmentOption(
                  "College of Health and Sciences Education",
                  "assets/depLogo/chselogo.png",
                  "CHSE",
                ),
                const SizedBox(height: 10),
                _buildDepartmentOption(
                  "College of Teacher Education",
                  "assets/depLogo/ctelogo.png",
                  "CTE",
                ),
                // Added for bottom padding when scrolling
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
