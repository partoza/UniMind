import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Form controllers
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  
  // Form variables with defaults
  String selectedGender = "Male";
  String selectedYear = "3rd Year";
  String selectedDepartment = "CCE"; // Default to CCE
  String selectedProgram = "Bachelor of Science in Information Technology";
  String selectedBuilding = "PS Building";
  String bio = "";
  String avatarPath = "assets/cce_male.jpg";

  List<String> skills = [
    "Coding",
    "UI/UX Design",
    "Math",
    "Video Editing",
    "Research Writing",
    "Problem Solving",
    "Graphic Design",
    "Public Speaking",
    "Team Leadership",
    "Machine Learning",
  ];
  
  List<String> betterSkills = [
    "Coding",
    "UI/UX Design",
    "Math",
    "Video Editing",
    "Research Writing",
    "Advanced Algorithms",
    "Backend Development",
    "Data Analysis",
    "Mobile Development",
    "Cloud Computing",
  ];
  
  List<String> selectedSkills = [];
  List<String> selectedBetterSkills = [];

  final Color primaryRed = const Color(0xFFB41214);
  final Color backgroundColor = const Color(0xFFF8F9FA);
  final Color surfaceColor = Colors.white;
  final Color textPrimary = const Color(0xFF1A1D1F);
  final Color textSecondary = const Color(0xFF6F767E);

  bool _isLoading = true;
  Map<String, dynamic>? _userData;

  // Department mapping - Firebase values to display values
  final List<Map<String, String>> _departmentOptions = [
    {'value': 'CCE', 'display': 'College of Computing Education', 'image': 'assets/ccelogo.png'},
    {'value': 'CEE', 'display': 'College of Engineering Education', 'image': 'assets/ceelogo.png'},
    {'value': 'CASE', 'display': 'College of Arts and Sciences Education', 'image': 'assets/caselogo.png'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
        
        if (userDoc.exists) {
          setState(() {
            _userData = userDoc.data()!;
            _populateFormWithUserData();
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error loading user data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _populateFormWithUserData() {
    if (_userData == null) return;

    // Personal Information
    _displayNameController.text = _userData!['displayName'] ?? "";
    selectedGender = _userData!['gender'] ?? "Male";
    avatarPath = _userData!['avatarPath'] ?? "assets/cce_male.jpg";

    // Academic Information
    final yearLevel = _userData!['yearLevel'] ?? 3;
    selectedYear = _getYearString(yearLevel);
    
    // Handle department - use the actual value from Firebase
    selectedDepartment = _userData!['department'] ?? "CCE";
    
    selectedProgram = _userData!['program'] ?? "Bachelor of Science in Information Technology";
    selectedBuilding = "PS Building"; // Default since not in Firebase

    // Bio
    bio = _userData!['bio'] ?? "";
    _bioController.text = bio;

    // Skills
    final strengths = _userData!['strengths'] ?? [];
    final weaknesses = _userData!['weaknesses'] ?? [];
    
    selectedSkills = List<String>.from(strengths);
    selectedBetterSkills = List<String>.from(weaknesses);
  }

  String _getYearString(dynamic yearLevel) {
    try {
      int level;
      if (yearLevel is int) {
        level = yearLevel;
      } else if (yearLevel is String) {
        // Handle string year levels like "3rd Year College"
        if (yearLevel.contains('1')) return '1st Year';
        if (yearLevel.contains('2')) return '2nd Year';
        if (yearLevel.contains('3')) return '3rd Year';
        if (yearLevel.contains('4')) return '4th Year';
        if (yearLevel.contains('5')) return '5th Year';
        level = 3;
      } else {
        level = 3;
      }

      switch (level) {
        case 1: return '1st Year';
        case 2: return '2nd Year';
        case 3: return '3rd Year';
        case 4: return '4th Year';
        case 5: return '5th Year';
        default: return '3rd Year';
      }
    } catch (e) {
      print("Error parsing year level: $e");
      return '3rd Year';
    }
  }

  int _getYearNumber(String yearString) {
    switch (yearString) {
      case '1st Year': return 1;
      case '2nd Year': return 2;
      case '3rd Year': return 3;
      case '4th Year': return 4;
      case '5th Year': return 5;
      default: return 3;
    }
  }

  // Get display name for department
  String _getDepartmentDisplayName(String value) {
    final department = _departmentOptions.firstWhere(
      (dept) => dept['value'] == value,
      orElse: () => _departmentOptions.first,
    );
    return department['display']!;
  }

  Future<void> _saveChanges() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Prepare update data
        final updateData = {
          'displayName': _displayNameController.text.trim(),
          'gender': selectedGender,
          'yearLevel': _getYearNumber(selectedYear),
          'department': selectedDepartment, // Save the actual value (CCE, CEE, etc.)
          'program': selectedProgram,
          'bio': _bioController.text.trim(),
          'strengths': selectedSkills,
          'weaknesses': selectedBetterSkills,
          'avatarPath': avatarPath,
          'updatedAt': FieldValue.serverTimestamp(),
          'profileComplete': true,
        };

        // Update Firestore
        await _firestore.collection('users').doc(currentUser.uid).update(updateData);

        // Show success and pop
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.of(context).pop();
      }
    } catch (e) {
      print("Error saving profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
      body: _isLoading 
          ? _buildLoadingIndicator()
          : Stack(
              children: [
                // Scrollable Content
                SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: 100,
                  ),
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
                          _buildTextField("Display Name", "Enter your display name", _displayNameController),
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
                            ["1st Year", "2nd Year", "3rd Year", "4th Year", "5th Year"],
                            selectedYear,
                            (val) {
                              setState(() => selectedYear = val!);
                            },
                          ),
                          SizedBox(height: 12),
                          _buildDepartmentDropdown(),
                          SizedBox(height: 12),
                          _buildDropdown(
                            "Program",
                            [
                              "Bachelor of Science in Information Technology",
                              "BS Information Technology",
                              "Bachelor of Science in Computer Science",
                              "BS Computer Science",
                              "Bachelor of Science in Entertainment and Multimedia Computing",
                              "BS Entertainment and Multimedia Computing",
                            ],
                            selectedProgram,
                            (val) {
                              setState(() => selectedProgram = val!);
                            },
                          ),
                          SizedBox(height: 12),
                          _buildDropdown(
                            "Building",
                            ["PS Building", "CS Building", "ENG Building"],
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

                      // Bio Section Card
                      _buildCard(
                        children: [
                          _buildSectionHeader(
                            "About Me",
                            Icons.edit_note_rounded,
                          ),
                          SizedBox(height: 16),
                          _buildBioTextField(),
                        ],
                      ),
                      SizedBox(height: 20),
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

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primaryRed),
          SizedBox(height: 16),
          Text(
            "Loading your profile...",
            style: GoogleFonts.montserrat(
              fontSize: 16,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: _saveChanges,
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
                  backgroundImage: AssetImage(avatarPath),
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
            onPressed: () {
              // Handle profile picture change
              _showAvatarSelectionDialog();
            },
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

  void _showAvatarSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Choose Avatar", style: GoogleFonts.montserrat()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage("assets/avatar1.jpg"),
              ),
              title: Text("Avatar 1"),
              onTap: () {
                setState(() {
                  avatarPath = "assets/avatar1.jpg";
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage("assets/avatar2.jpg"),
              ),
              title: Text("Avatar 2"),
              onTap: () {
                setState(() {
                  avatarPath = "assets/avatar2.jpg";
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage("assets/avatar3.jpg"),
              ),
              title: Text("Avatar 3"),
              onTap: () {
                setState(() {
                  avatarPath = "assets/avatar3.jpg";
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage("assets/avatar4.jpg"),
              ),
              title: Text("Avatar 4"),
              onTap: () {
                setState(() {
                  avatarPath = "assets/avatar4.jpg";
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage("assets/avatar5.jpg"),
              ),
              title: Text("Avatar 5"),
              onTap: () {
                setState(() {
                  avatarPath = "assets/avatar5.jpg";
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
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

  Widget _buildTextField(String label, String hint, TextEditingController controller) {
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
            controller: controller,
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

  Widget _buildBioTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Bio",
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
        ),
        SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: _bioController,
            maxLines: 4,
            maxLength: 150,
            onChanged: (value) {
              setState(() {
                bio = value;
              });
            },
            decoration: InputDecoration(
              hintText: "Tell us about yourself, your interests, goals, or what makes you unique...",
              hintStyle: GoogleFonts.montserrat(
                color: textSecondary,
                fontSize: 13,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              counterStyle: GoogleFonts.montserrat(
                fontSize: 12,
                color: textSecondary,
              ),
            ),
            style: GoogleFonts.montserrat(
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDepartmentDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "College Department",
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
        ),
        SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: selectedDepartment,
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
          menuMaxHeight: MediaQuery.of(context).size.height * 0.5,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: textSecondary),
          style: GoogleFonts.montserrat(fontSize: 14, color: textPrimary),
          items: _departmentOptions
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
                          item['display']!,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (val) {
            setState(() => selectedDepartment = val!);
          },
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
          menuMaxHeight: MediaQuery.of(context).size.height * 0.5,
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

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}