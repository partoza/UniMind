import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StrengthsSelect extends StatefulWidget {
  const StrengthsSelect({super.key, required this.onSelect});

  final ValueChanged<List<String>> onSelect;

  @override
  State<StrengthsSelect> createState() => _StrengthsSelectState();
}

class _StrengthsSelectState extends State<StrengthsSelect> {
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
        if (_selectedSkills.length < 3) { // Limit to 3 selections
          _selectedSkills.add(skill);
        }
      }
    });
    
    // Notify parent about the selection change
    widget.onSelect(_selectedSkills);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SingleChildScrollView( // ✅ Prevents overflow
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🔹 Title
          Text(
            "Strengths",
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFB41214),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Things you excel at (select up to 3)",
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 30),

          // Selection counter
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: size.width * 0.075),
              child: Text(
                "Selected: ${_selectedSkills.length}/3",
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 🔹 Skills list
          Center(
            child: SizedBox(
              width: size.width * 0.85,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _skills.map((skill) {
                  final isSelected = _selectedSkills.contains(skill);
                  final canSelect = _selectedSkills.length < 3 || isSelected;
                  
                  return ChoiceChip(
                    label: Text(
                      skill,
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isSelected 
                          ? Colors.white 
                          : canSelect 
                            ? Colors.black 
                            : Colors.grey,
                      ),
                    ),
                    selected: isSelected,
                    showCheckmark: false,
                    selectedColor: const Color(0xFFB41214),
                    backgroundColor: canSelect ? Colors.white : Colors.grey[200],
                    shape: StadiumBorder(
                      side: BorderSide(
                        color: isSelected 
                          ? const Color(0xFFB41214) 
                          : canSelect 
                            ? Colors.black 
                            : Colors.grey,
                      ),
                    ),
                    onSelected: canSelect ? (_) => _toggleSkill(skill) : null,
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // 🔹 Selected Skills Box
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "My Top Skills:",
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              Container(
                height: 250, // ✅ Responsive instead of fixed 350
                width: size.width * 0.85,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedSkills.map((skill) {
                      return Chip(
                        label: Text(
                          skill,
                          style: GoogleFonts.montserrat(fontSize: 12),
                        ),
                        backgroundColor: const Color(0xFFB41214),
                        labelStyle: const TextStyle(color: Colors.white),
                        deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white),
                        onDeleted: () {
                          setState(() {
                            _selectedSkills.remove(skill);
                          });
                          // Notify parent about the selection change
                          widget.onSelect(_selectedSkills);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
