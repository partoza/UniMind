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
    "Coding", "UI/UX Design", "Research Writing", "Video Editing", "Math", "Writing",
    "Thinking", "Problem Solving", "Speaking", "Leadership", "Creativity", "Management",
    "Timekeeping", "Experimentation", "Statistics", "Design", "Business", "Debate",
    "Language", "Technology", "Humanities", "Engineering", "Innovation", "Teaching",
    "Learning", "Analysis", "Communication", "Organization", "Collaboration", 
    "Presentation", "Strategy", "Exploration",
  ];

  final List<String> _selectedSkills = [];
  
  // 💡 Controller and flags for the scroll indicator logic
  final ScrollController _scrollController = ScrollController();
  bool _showRightFade = true;

  @override
  void initState() {
    super.initState();
    // Initialize listener for scroll position
    _scrollController.addListener(_updateScrollFade);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollFade);
    _scrollController.dispose();
    super.dispose();
  }

  // Logic to determine if the right fade/shadow should be shown
  void _updateScrollFade() {
    if (!_scrollController.hasClients) return;

    // Check if we are near the end of the scrollable content
    final shouldHide = _scrollController.position.maxScrollExtent - _scrollController.offset < 20;

    if (shouldHide != _showRightFade) {
      setState(() {
        _showRightFade = !shouldHide;
      });
    }
  }

  void _toggleSkill(String skill) {
    setState(() {
      if (_selectedSkills.contains(skill)) {
        _selectedSkills.remove(skill);
      } else {
        if (_selectedSkills.length < 3) {
          _selectedSkills.add(skill);
        }
      }
    });
    widget.onSelect(_selectedSkills);
  }

  // Refactored the selected skills display
  Widget _buildSelectedSkillsSection(Size size) {
    if (_selectedSkills.isEmpty) {
      return Padding(
        // 💡 Ensure padding aligns with the main content area
        padding: EdgeInsets.only(left: size.width * 0.075),
        child: Text(
          "Select your top 3 strengths from the list above.",
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
        // Title fixed to the left
        Padding(
          padding: EdgeInsets.only(left: size.width * 0.075, right: size.width * 0.075),
          child: Text(
            "My Top Skills:", // 💡 This title is now left-aligned
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
            children: _selectedSkills.map((item) {
              return Chip(
                onDeleted: () => _toggleSkill(item),
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

          // Selection counter (Left-aligned)
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

          // 🔹 Skills list Container (Scrollable Content with Identifier)
          Center(
            child: Container(
              width: size.width * 0.85,
              height: size.height * 0.35,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Stack( // 💡 Use Stack for the scroll indicator fade effect
                children: [
                  // Scrollable Content
                  SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(10.0), // Padding inside the scrollable area
                    child: Wrap(
                      spacing: 8, 
                      runSpacing: 8,
                      children: _skills.map((skill) {
                        final isSelected = _selectedSkills.contains(skill);
                        final canSelect = _selectedSkills.length < 3 || isSelected;
                        
                        return ChoiceChip(
                          label: Text(
                            skill,
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
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

          // 🔹 Selected Skills Display (Aligned to the left)
          _buildSelectedSkillsSection(size),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}