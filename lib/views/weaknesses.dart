import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WeaknessesSelect extends StatefulWidget {
  const WeaknessesSelect({super.key, required this.onSelect});

  final ValueChanged<List<String>> onSelect;
  
  @override
  State<WeaknessesSelect> createState() => _WeaknessesSelectState();
}

class _WeaknessesSelectState extends State<WeaknessesSelect> {
  final List<String> weaknesses = [
    "Coding",
    "UI/UX Design",
    "Research Writing",
    "Video Editing",
    "Math",
  ];

  final List<String> selectedWeaknesses = [];

  void toggleWeakness(String weakness) {
    setState(() {
      if (selectedWeaknesses.contains(weakness)) {
        selectedWeaknesses.remove(weakness);
      } else {
        if (selectedWeaknesses.length < 3) { // Limit to 3 selections
          selectedWeaknesses.add(weakness);
        }
      }
    });
    
    // Notify parent about the selection change
    widget.onSelect(selectedWeaknesses);
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
            "Weaknesses",
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFB41214),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Things you want to improve (select up to 3)",
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
                "Selected: ${selectedWeaknesses.length}/3",
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 🔹 Weaknesses list
          Center(
            child: SizedBox(
              width: size.width * 0.85,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: weaknesses.map((weakness) {
                  final isSelected = selectedWeaknesses.contains(weakness);
                  final canSelect = selectedWeaknesses.length < 3 || isSelected;
                  
                  return ChoiceChip(
                    label: Text(
                      weakness,
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
                    onSelected: canSelect ? (_) => toggleWeakness(weakness) : null,
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // 🔹 Selected Weaknesses Box
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Things you'd like to get better at:",
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              Container(
                height: 250,
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
                    children: selectedWeaknesses.map((weakness) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB41214),
                          borderRadius: BorderRadius.circular(20), // Stadium-like border radius
                          border: Border.all(
                            color: const Color(0xFFB41214), // Same red border as selected ChoiceChip
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              weakness,
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedWeaknesses.remove(weakness);
                                });
                                // Notify parent about the selection change
                                widget.onSelect(selectedWeaknesses);
                              },
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
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
