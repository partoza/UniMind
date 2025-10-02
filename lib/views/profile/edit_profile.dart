import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String selectedGender = "Male";
  String selectedYear = "3rd Year";
  String selectedDepartment = "College of Computing Education";
  String selectedProgram = "BSIT";
  String selectedBuilding = "PS";

  List<String> skills = [
    "Coding",
    "UI/UX Design",
    "Math",
    "Video Editing",
    "Research Writing",
  ];
  List<String> betterSkills = [
    "Coding",
    "UI/UX Design",
    "Math",
    "Video Editing",
    "Research Writing",
  ];
  List<String> selectedSkills = ["Coding", "UI/UX Design"];
  List<String> selectedBetterSkills = ["Coding", "UI/UX Design"];

  final Color primaryRed = const Color(0xFFB41214);
  final Color backgroundColor = const Color(0xFFF8F9FA);
  final Color surfaceColor = Colors.white;
  final Color textPrimary = const Color(0xFF1A1D1F);
  final Color textSecondary = const Color(0xFF6F767E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            color: textPrimary,
            fontSize: 18,
          ),
        ),
        backgroundColor: surfaceColor,
        elevation: 0.5,
        foregroundColor: primaryRed,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Scrollable Content
          SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: 100,
            ), // Extra bottom padding for fixed button
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image Section
                _buildProfileImageSection(),
                SizedBox(height: 15),

                // Personal Information Card
                _buildCard(
                  children: [
                    _buildSectionHeader(
                      "Personal Information",
                      Icons.person_outline_rounded,
                    ),
                    SizedBox(height: 16),
                    _buildTextField("First Name", "John Rex"),
                    SizedBox(height: 12),
                    _buildTextField("Last Name", "Partoza"),
                    SizedBox(height: 12),
                    _buildDropdown(
                      "Gender",
                      ["Male", "Female"],
                      selectedGender,
                      (val) {
                        setState(() => selectedGender = val!);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Academic Information Card
                _buildCard(
                  children: [
                    _buildSectionHeader(
                      "Academic Information",
                      Icons.school_outlined,
                    ),
                    SizedBox(height: 16),
                    _buildDropdown(
                      "Year Level",
                      ["1st Year", "2nd Year", "3rd Year", "4th Year"],
                      selectedYear,
                      (val) {
                        setState(() => selectedYear = val!);
                      },
                    ),
                    SizedBox(height: 12),
                    _buildDropdownWithImage(
                      "College Department",
                      [
                        {
                          'value': 'College of Computing Education',
                          'image': 'assets/ccelogo.png',
                        },
                        {
                          'value': 'College of Engineering Education',
                          'image': 'assets/ceelogo.png',
                        },
                        {
                          'value': 'College of Arts and Sciences Education',
                          'image': 'assets/caselogo.png',
                        },
                      ],
                      selectedDepartment,
                      (val) {
                        setState(() => selectedDepartment = val!);
                      },
                    ),
                    SizedBox(height: 12),
                    _buildDropdown(
                      "Program",
                      ["BSIT", "BSCS", "BSEMC"],
                      selectedProgram,
                      (val) {
                        setState(() => selectedProgram = val!);
                      },
                    ),
                    SizedBox(height: 12),
                    _buildDropdown(
                      "Building",
                      ["PS", "CS", "ENG"],
                      selectedBuilding,
                      (val) {
                        setState(() => selectedBuilding = val!);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Skills Card
                _buildCard(
                  children: [
                    _buildSectionHeader(
                      "Skills & Interests",
                      Icons.psychology_outlined,
                    ),
                    SizedBox(height: 16),
                    _buildSkillsSection(
                      "My Top Skills",
                      skills,
                      selectedSkills,
                      (skill, selected) {
                        setState(() {
                          selected
                              ? selectedSkills.add(skill)
                              : selectedSkills.remove(skill);
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    _buildSkillsSection(
                      "Things I'd like to get better at",
                      betterSkills,
                      selectedBetterSkills,
                      (skill, selected) {
                        setState(() {
                          selected
                              ? selectedBetterSkills.add(skill)
                              : selectedBetterSkills.remove(skill);
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 28),
              ],
            ),
          ),

          // Fixed Save Button
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: _buildFixedSaveButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedSaveButton() {
    return Container(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: () {
              // Handle save changes
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryRed,
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Save Changes",
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primaryRed.withOpacity(0.2),
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.grey.shade100,
                  backgroundImage: AssetImage("assets/cce_male.jpg"),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: primaryRed,
                    shape: BoxShape.circle,
                    border: Border.all(color: surfaceColor, width: 2),
                  ),
                  child: Icon(Icons.edit, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: primaryRed,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              "Change Profile Picture",
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: primaryRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: primaryRed, size: 20),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
        ),
        SizedBox(height: 6),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.montserrat(color: textSecondary),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
            style: GoogleFonts.montserrat(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String selectedValue,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
        ),
        SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: selectedValue,
          isExpanded: true, // ✅ Makes text wrap nicely
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryRed, width: 2),
            ),
          ),
          dropdownColor: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          menuMaxHeight:
              MediaQuery.of(context).size.height *
              0.5, // ✅ Responsive max height
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: textSecondary),
          style: GoogleFonts.montserrat(fontSize: 14, color: textPrimary),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDropdownWithImage(
    String label,
    List<Map<String, String>> items,
    String selectedValue,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
        ),
        SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: selectedValue,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryRed, width: 2),
            ),
          ),
          dropdownColor: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          menuMaxHeight:
              MediaQuery.of(context).size.height * 0.5, // ✅ Responsive
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: textSecondary),
          style: GoogleFonts.montserrat(fontSize: 14, color: textPrimary),
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item['value'],
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        margin: EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          image: DecorationImage(
                            image: AssetImage(item['image']!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          item['value']!,
                          overflow:
                              TextOverflow.ellipsis, // ✅ Prevents text overflow
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSkillsSection(
    String title,
    List<String> skills,
    List<String> selectedSkills,
    Function(String, bool) onSkillSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills.map((skill) {
            final isSelected = selectedSkills.contains(skill);
            return GestureDetector(
              onTap: () {
                onSkillSelected(skill, !isSelected);
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? primaryRed : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? primaryRed : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  skill,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
