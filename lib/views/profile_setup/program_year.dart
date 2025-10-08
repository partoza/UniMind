import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class ProgramYearSelect extends StatefulWidget {
  final Function(String?, int?) onSelect; // Two separate parameters

  const ProgramYearSelect({super.key, required this.onSelect});

  @override
  State<ProgramYearSelect> createState() => _ProgramYearSelectState();
}

class _ProgramYearSelectState extends State<ProgramYearSelect> {
  String? selectedProgram;
  int? selectedYear;

  void _updateSelection() {
    // Call the callback whenever either selection changes
    widget.onSelect(selectedProgram, selectedYear);
  }

  final List<String> programs = [
    "Bachelor of Science in Information Technology",
    "Bachelor of Science in Computer Science",
    "Bachelor of Science in Multimedia Arts",
  ];

  final List<String> years = [
    "1st Year College",
    "2nd Year College",
    "3rd Year College",
    "4th Year College",
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Changed from start to center
        children: [
          const SizedBox(height: 30),
          Text(
            "Choose a Program and\nYear Level",
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFB41214),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "What program do you belong to in CCE and year level?",
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 30),

          // Department Badge - now centered
          Container(
            width: size.width * 0.8,
            height: 55,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFB41214),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Image.asset("assets/ccelogo.png", width: 36, height: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "College of Computing\nEducation",
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Dropdowns remain left-aligned for better UX
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Select a Program",
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
              isExpanded: true,
              hint: Text("Choose Program",
                  style: GoogleFonts.montserrat(
                      fontSize: 14, color: Colors.grey[600])),
              value: selectedProgram,
              items: programs.map((program) {
                return DropdownMenuItem<String>(
                  value: program,
                  child: Text(program,
                      style: GoogleFonts.montserrat(
                          fontSize: 14, color: Colors.black)),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  selectedProgram = value;
                });
                _updateSelection(); // Notify parent
              },
              buttonStyleData: ButtonStyleData(
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFB41214)),
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 25),

          // Year Dropdown
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Select a Year Level",
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
              isExpanded: true,
              hint: Text("Choose Year",
                  style: GoogleFonts.montserrat(
                      fontSize: 14, color: Colors.grey[600])),
              value: selectedYear != null ? years[selectedYear! - 1] : null,
              items: years.map((year) {
                return DropdownMenuItem<String>(
                  value: year,
                  child: Text(year,
                      style: GoogleFonts.montserrat(
                          fontSize: 14, color: Colors.black)),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  selectedYear = value != null ? years.indexOf(value) + 1 : null;
                });
                _updateSelection(); // Notify parent
              },
              buttonStyleData: ButtonStyleData(
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFB41214)),
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}