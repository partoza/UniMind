import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WeaknessesSelect extends StatefulWidget {
  // 💡 1. Add required parameter for disabled skills (Strengths)
  const WeaknessesSelect({
    super.key, 
    required this.onSelect,
    required this.disabledWeaknesses, // Pass selected Strengths here
  });

  final ValueChanged<List<String>> onSelect;
  final List<String> disabledWeaknesses; // Skills that are already selected as Strengths
  
  @override
  State<WeaknessesSelect> createState() => _WeaknessesSelectState();
}

class _WeaknessesSelectState extends State<WeaknessesSelect> {
  // 💡 2. Expanded list of available skills/weaknesses
  final List<String> _weaknesses = [
    "Coding", "UI/UX Design", "Research Writing", "Video Editing", "Math", "Writing",
    "Thinking", "Problem Solving", "Speaking", "Leadership", "Creativity", "Management",
    "Timekeeping", "Experimentation", "Statistics", "Design", "Business", "Debate",
    "Language", "Technology", "Humanities", "Engineering", "Innovation", "Teaching",
    "Learning", "Analysis", "Communication", "Organization", "Collaboration", 
    "Presentation", "Strategy", "Exploration",
  ];

  final List<String> _selectedWeaknesses = [];

  // 💡 3. Controller and flags for the scroll indicator logic
  final ScrollController _scrollController = ScrollController();
  bool _showRightFade = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollFade);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollFade);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _updateScrollFade() {
    if (!_scrollController.hasClients) return;
    final shouldHide = _scrollController.position.maxScrollExtent - _scrollController.offset < 20;

    if (shouldHide != _showRightFade) {
      setState(() {
        _showRightFade = !shouldHide;
      });
    }
  }

  void _toggleWeakness(String weakness) {
    // 💡 Prevent selection if the weakness is in the disabled list (selected as strength)
    if (widget.disabledWeaknesses.contains(weakness)) {
      return; 
    }
    
    setState(() {
      if (_selectedWeaknesses.contains(weakness)) {
        _selectedWeaknesses.remove(weakness);
      } else {
        if (_selectedWeaknesses.length < 3) { // Limit to 3 selections
          _selectedWeaknesses.add(weakness);
        }
      }
    });
    
    // Notify parent about the selection change
    widget.onSelect(_selectedWeaknesses);
  }

  // 💡 4. Refactored display for selected weaknesses (based on StrengthsSelect style)
  Widget _buildSelectedWeaknessesSection(Size size) {
    if (_selectedWeaknesses.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(left: size.width * 0.075),
        child: Text(
          "Select up to 3 things you want to improve.",
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return Column(
      // 💡 Align title and content to the start (left)
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: size.width * 0.075, right: size.width * 0.075),
          child: Text(
            "Things I'm working on:", // Updated title
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFB41214),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Chips display
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.075),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedWeaknesses.map((item) {
              return Chip(
                onDeleted: () => _toggleWeakness(item), 
                deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white),
                label: Text(
                  item,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: const Color(0xFFB41214),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide.none,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SingleChildScrollView( 
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

          // Selection counter (Left-aligned)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: size.width * 0.075),
              child: Text(
                "Selected: ${_selectedWeaknesses.length}/3",
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 🔹 Weaknesses list Container (Scrollable Content with Indicator)
          Center(
            child: Container(
              width: size.width * 0.85,
              height: size.height * 0.35,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Stack( // Use Stack for the scroll indicator fade effect
                children: [
                  // Scrollable Content
                  SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(10.0), // Padding inside the scrollable area
                    child: Wrap(
                      spacing: 8, 
                      runSpacing: 8,
                      children: _weaknesses.map((weakness) {
                        final isSelected = _selectedWeaknesses.contains(weakness);
                        final isDisabled = widget.disabledWeaknesses.contains(weakness); // 💡 Check for disabled
                        final canSelect = (_selectedWeaknesses.length < 3 || isSelected) && !isDisabled;
                        
                        return ChoiceChip(
                          label: Text(
                            weakness,
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              // 💡 Adjust color based on selection AND disabled status
                              color: isSelected 
                                ? Colors.white 
                                : isDisabled 
                                  ? Colors.grey[500] 
                                  : Colors.black,
                            ),
                          ),
                          selected: isSelected,
                          showCheckmark: false,
                          selectedColor: const Color(0xFFB41214),
                          // 💡 Adjust background color when disabled
                          backgroundColor: isDisabled ? Colors.grey[100] : (canSelect ? Colors.white : Colors.grey[200]),
                          shape: StadiumBorder(
                            side: BorderSide(
                              // 💡 Adjust border color when disabled
                              color: isSelected 
                                ? const Color(0xFFB41214) 
                                : isDisabled 
                                  ? Colors.grey[400]! 
                                  : (canSelect ? Colors.black : Colors.grey),
                            ),
                          ),
                          onSelected: canSelect ? (_) => _toggleWeakness(weakness) : null,
                        );
                      }).toList(),
                    ),
                  ),

                  // 💡 Scroll Indicator (Right Fade)
                  if (_showRightFade)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: IgnorePointer(
                        child: Container(
                          width: 25,
                          decoration: BoxDecoration(
                            // Gradient to simulate fading out content
                            gradient: LinearGradient(
                              colors: [Colors.white.withOpacity(0.0), Colors.white],
                              stops: const [0.0, 1.0],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // 🔹 Selected Weaknesses Display (Left-aligned)
          _buildSelectedWeaknessesSection(size),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}