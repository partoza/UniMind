import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GenderSelectionPage extends StatefulWidget {
  final Function(String)? onSelect;

  const GenderSelectionPage({super.key, this.onSelect});

  @override
  State<GenderSelectionPage> createState() => _GenderSelectionPageState();
}

class _GenderSelectionPageState extends State<GenderSelectionPage> {
  String? _selectedGender;

  Widget _buildGenderButton(String text, double width) {
    final isSelected = _selectedGender == text;
    return SizedBox(
      width: width * 0.6,
      height: 46,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? const Color.fromARGB(255, 122, 9, 11)
              : const Color(0xFFB41214),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () {
          setState(() {
            _selectedGender = text;
          });
          if (widget.onSelect != null) widget.onSelect!(text);
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

    return Column(
      children: [
        const SizedBox(height: 40),
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
          style: GoogleFonts.montserrat(fontSize: 12, color: Colors.black),
        ),
        const SizedBox(height: 30),
        _buildGenderButton("Male", size.width),
        const SizedBox(height: 15),
        _buildGenderButton("Female", size.width),
        const SizedBox(height: 15),
        _buildGenderButton("Others", size.width),
      ],
    );
  }
}
