import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unimind/services/ibb_service.dart'; 


class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  // Form controllers
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  // Variables initialized to null/empty values
  String? selectedGender;
  String? selectedYear;
  String? selectedDepartment;
  String? selectedProgram;
  String? selectedBuilding; // This is now purely for background data for saving
  String bio = "";
  String? avatarPath;

  // --- START: Data Structures ---

  // Updated list of all possible skills
  final List<String> allSkills = const [
    "Coding", "UI/UX Design", "Research Writing", "Video Editing", "Math", "Writing",
    "Thinking", "Problem Solving", "Speaking", "Leadership", "Creativity", "Management",
    "Timekeeping", "Experimentation", "Statistics", "Design", "Business", "Debate",
    "Language", "Technology", "Humanities", "Engineering", "Innovation", "Teaching",
    "Learning", "Analysis", "Communication", "Organization", "Collaboration",
    "Presentation", "Strategy", "Exploration",
  ];

  // Map for Department, Program, and Building information
  final Map<String, dynamic> _departmentData = const {
    "CAE": {
      "name": "College of Accounting Education",
      "place": "BE Building",
      "logo": "assets/depLogo/caelogo.png",
      "programs": {
        "Bachelor of Science in Accountancy": "BSA",
        "Bachelor of Science in Accounting Information System": "BSAIS",
        "Bachelor of Science in Internal Audit": "BSIA",
        "Bachelor of Science in Management Accounting": "BSMA",
      }
    },
    "CAFAE": {
      "name": "College of Architecture and Fine Arts Education",
      "place": "DPT Building",
      "logo": "assets/depLogo/cafaelogo.png",
      "programs": {
        "Bachelor of Science in Architecture": "BS Arch",
        "Bachelor of Fine Arts (Major in Painting)": "BFA",
        "Bachelor of Science in Urban and Regional Planning": "BSURP",
        "Bachelor of Science in Interior Design": "BSID",
      }
    },
    "CBAE": {
      "name": "College of Business Administration Education",
      "place": "Bolton Campus",
      "logo": "assets/depLogo/cbaelogo.png",
      "programs": {
        "Bachelor of Science in Business Administration Major in Financial Management": "BSBA-FM",
        "Bachelor of Science in Business Administration Major in Human Resource Management": "BSBA-HRM",
        "Bachelor of Science in Business Administration Major in Marketing Management": "BSBA-MM",
        "Bachelor of Science in Business Administration Major in Business Economics": "BSBA-BE",
        "Bachelor of Science in Entrepreneurship": "BSEnt",
        "Bachelor of Science in Legal Management": "BSLM",
        "Bachelor of Science in Real Estate Management": "BSREM",
      }
    },
    "CCE": {
      "name": "College of Computing Education",
      "place": "PS Building",
      "logo": "assets/depLogo/ccelogo.png",
      "programs": {
        "Bachelor of Science in Information Technology": "BSIT",
        "Bachelor of Science in Information Systems": "BSIS",
        "Bachelor of Science in Computer Science": "BSCS",
        "Bachelor of Science in Entertainment and Multimedia Computing (Game Development)": "BSEMC-GD",
        "Bachelor of Science in Entertainment and Multimedia Computing (Digital Animation Technology)": "BSEMC-DA",
        "Bachelor of Library and Information Science": "BLIS",
        "Bachelor of Multimedia Arts": "BMA",
      }
    },
    "CHE": {
      "name": "College of Hospitality Education",
      "place": "FEA Building",
      "logo": "assets/depLogo/chelogo.png",
      "programs": {
        "Bachelor of Science in Hospitality Management": "BSHM",
        "Bachelor of Science in Tourism Management": "BSTM",
      }
    },
    "CCJE": {
      "name": "College of Criminal Justice Education",
      "place": "GET Building",
      "logo": "assets/depLogo/ccjelogo.png",
      "programs": {
        "Bachelor of Science in Criminology": "BSCrim",
        "Bachelor of Science in Industrial Security": "BSISec",
      }
    },
    "CASE": {
      "name": "College of Arts and Sciences Education",
      "place": "DPT Building",
      "logo": "assets/depLogo/caselogo.png",
      "programs": {
        "Bachelor of Arts in Communication": "BA Comm",
        "Bachelor of Arts in English Language": "BA English",
        "Bachelor of Arts in Political Science": "BA PolSci",
        "Bachelor of Arts in Broadcasting": "BA Broadcasting",
        "Bachelor of Public Administration": "BPA",
        "Bachelor of Arts in Multimedia Arts": "BA MMA",
        "Bachelor of Science in Psychology": "BS Psych",
        "Bachelor of Science in Environmental Science": "BS EnvSci",
        "Bachelor of Science in Forestry": "BS Forestry",
        "Bachelor of Science in Agroforestry": "BS Agroforestry",
        "Bachelor of Science in Biology": "BS Bio",
        "Bachelor of Science in Mathematics": "BS Math",
        "Bachelor of Science in Social Work": "BSSW",
      }
    },
    "CEE": {
      "name": "College of Engineering Education",
      "place": "BE Building",
      "logo": "assets/depLogo/ceelogo.png",
      "programs": {
        "Bachelor of Science in Chemical Engineering": "BSChE",
        "Bachelor of Science in Civil Engineering": "BSCE",
        "Bachelor of Science in Computer Engineering": "BSCpE",
        "Bachelor of Science in Electrical Engineering": "BSEE",
        "Bachelor of Science in Electronics Engineering": "BSECE",
        "Bachelor of Science in Mechanical Engineering": "BSME",
      }
    },
    "CHSE": {
      "name": "College of Health Sciences Education",
      "place": "DPT Building",
      "logo": "assets/depLogo/chselogo.png",
      "programs": {
        "Bachelor of Science in Medical Laboratory Science": "BSMLS/BSMT",
        "Bachelor of Science in Nursing": "BSN",
        "Bachelor of Science in Nutrition and Dietetics": "BSND",
        "Bachelor of Science in Pharmacy": "BSP",
      }
    },
    "CTE": {
      "name": "College of Teacher Education",
      "place": "GET Building",
      "logo": "assets/depLogo/ctelogo.png",
      "programs": {
        "Bachelor of Early Childhood Education": "BECEd",
        "Bachelor of Elementary Education": "BEEd",
        "Bachelor of Secondary Education": "BSEd",
        "Bachelor of Special Education": "BSEd-SPED",
        "Bachelor of Physical Education": "BPEd",
      }
    },
  };

  // List of Department Codes for easy iteration
  final List<String> _departmentCodes = const [
    'CAE', 'CAFAE', 'CBAE', 'CCE', 'CHE', 'CCJE', 'CASE', 'CEE', 'CHSE', 'CTE',
  ];

  // Available year levels (excluding 5th year as requested)
  final List<String> _yearOptions = const [
    "1st Year", "2nd Year", "3rd Year", "4th Year",
  ];

  // --- END: Data Structures ---

  List<String> selectedSkills = [];
  List<String> selectedBetterSkills = [];

  final Color primaryRed = const Color(0xFFB41214);
  final Color backgroundColor = const Color(0xFFF8F9FA);
  final Color surfaceColor = Colors.white;
  final Color textPrimary = const Color(0xFF1A1D1F);
  final Color textSecondary = const Color(0xFF6F767E);

  bool _isLoading = true;
  Map<String, dynamic>? _userData;

  // Gender options
  final List<String> _genderOptions = const ["Male", "Female", "Others"];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // --- START: Utility Methods ---
  
  // Utility function to generate the required default avatar path
  String _getDefaultAvatarPath(String departmentCode) {
    // Format: assets/avatar/[department_code]avatar.png (using lowercase code for path)
    return 'assets/avatar/${departmentCode.toLowerCase()}avatar.png';
  }

  // 🛑 New Utility function to get the program acronym
  String _getProgramAcronym(String departmentCode, String programName) {
    return _departmentData[departmentCode]?['programs']?[programName] ?? programName;
  }

  Future<void> _loadUserData() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final userDoc =
            await _firestore.collection('users').doc(currentUser.uid).get();

        if (userDoc.exists) {
          setState(() {
            _userData = userDoc.data()!;
            _populateFormWithUserData();
            _isLoading = false;
          });
        } else {
          _populateFormWithDefaults();
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error loading user data: $e");
      _populateFormWithDefaults();
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _populateFormWithDefaults() {
    const defaultDept = "CCE";
    selectedGender = "Male";
    selectedYear = "3rd Year";
    selectedDepartment = defaultDept;
    selectedProgram = _getDefaultProgram(defaultDept);
    selectedBuilding = _departmentData[defaultDept]?['place'] ?? "PS Building";
    // Set default avatar using the new format
    avatarPath = _getDefaultAvatarPath(defaultDept); 
    selectedSkills = [];
    selectedBetterSkills = [];
    _displayNameController.text = "";
    _bioController.text = "";
    bio = "";
  }

  void _populateFormWithUserData() {
    if (_userData == null) {
      _populateFormWithDefaults();
      return;
    }

    _displayNameController.text = _userData!['displayName'] ?? "";

    final genderFromFirebase = _userData!['gender'] ?? "Male";
    selectedGender = _genderOptions.contains(genderFromFirebase)
        ? genderFromFirebase
        : "Others";

    // Keep the avatarPath loaded from Firebase, but ensure a valid default if missing
    avatarPath = _userData!['avatarPath'] ?? _getDefaultAvatarPath("CCE");

    final yearLevel = _userData!['yearLevel'] ?? 3;
    selectedYear = _getYearString(yearLevel);

    final deptFromFirebase = _userData!['department'] ?? "CCE";
    selectedDepartment = _departmentData.containsKey(deptFromFirebase)
        ? deptFromFirebase
        : "CCE";

    final defaultProgram = _getDefaultProgram(selectedDepartment!);
    // Note: 'program' field in Firestore might contain the full name or acronym. 
    // We try to match to the full name for the dropdown to work.
    final programFromFirebase = _userData!['program'] ?? defaultProgram;
    selectedProgram = _isProgramValid(selectedDepartment!, programFromFirebase)
        ? programFromFirebase
        : defaultProgram;
    
    // Auto-set building based on loaded department
    selectedBuilding = _departmentData[selectedDepartment]?['place'] ?? "PS Building";

    bio = _userData!['bio'] ?? "";
    _bioController.text = bio;

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
        if (yearLevel.contains('1')) return '1st Year';
        if (yearLevel.contains('2')) return '2nd Year';
        if (yearLevel.contains('3')) return '3rd Year';
        if (yearLevel.contains('4')) return '4th Year';
        level = 3;
      } else {
        level = 3;
      }

      switch (level) {
        case 1:
          return '1st Year';
        case 2:
          return '2nd Year';
        case 3:
          return '3rd Year';
        case 4:
          return '4th Year';
        default:
          return '3rd Year';
      }
    } catch (e) {
      print("Error parsing year level: $e");
      return '3rd Year';
    }
  }

  int _getYearNumber(String yearString) {
    switch (yearString) {
      case '1st Year':
        return 1;
      case '2nd Year':
        return 2;
      case '3rd Year':
        return 3;
      case '4th Year':
        return 4;
      default:
        return 3;
    }
  }

  String _getDepartmentDisplayName(String? value) {
    return _departmentData[value]?['name'] ?? 'College of Computing Education';
  }

  String _getDepartmentLogoPath(String? departmentValue) {
    return _departmentData[departmentValue]?['logo'] ?? 'assets/depLogo/ccelogo.png';
  }

  List<String> _getProgramsForSelectedDepartment() {
    return _departmentData[selectedDepartment]?['programs']?.keys.toList() ??
        ['Bachelor of Science in Information Technology'];
  }

  String _getDefaultProgram(String departmentCode) {
    final programs = _departmentData[departmentCode]?['programs']?.keys.toList();
    return programs != null && programs.isNotEmpty ? programs.first : "Program not found";
  }

  bool _isProgramValid(String departmentCode, String programName) {
    final programs = _departmentData[departmentCode]?['programs']?.keys.toList();
    return programs?.contains(programName) ?? false;
  }

  void _setAvatarPath(String newPath) {
    setState(() {
      avatarPath = newPath;
      Navigator.of(context).pop();
    });
  }

  Future<void> _handleImageUpload() async {
    Navigator.of(context).pop();
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CircularProgressIndicator(color: surfaceColor),
                SizedBox(width: 16),
                Text('Uploading image...', style: GoogleFonts.montserrat()),
              ],
            ),
            duration: Duration(days: 365),
            backgroundColor: textSecondary,
          ),
        );

        // Assuming IBBService is implemented correctly elsewhere
        final String? imageUrl =
            await IBBService.uploadImage(File(pickedFile.path));

        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        if (imageUrl != null) {
          setState(() {
            avatarPath = imageUrl;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image upload failed. Please try again.'),
              backgroundColor: primaryRed,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      print("Image picking/upload error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred during image selection.'),
          backgroundColor: primaryRed,
        ),
      );
    }
  }

  // --- END: Utility Methods ---

  // --- START: Save Changes ---
  Future<void> _saveChanges() async {
    if (selectedGender == null ||
        selectedYear == null ||
        selectedDepartment == null ||
        selectedProgram == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please wait for the profile data to load before saving.'),
          backgroundColor: primaryRed,
        ),
      );
      return;
    }

    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final String programAcronym = _getProgramAcronym(selectedDepartment!, selectedProgram!);

        // 2. Prepare update data
        final updateData = {
          'displayName': _displayNameController.text.trim(),
          'gender': selectedGender,
          'yearLevel': _getYearNumber(selectedYear!),
          'department': selectedDepartment,
          'program': selectedProgram,
          'programAcronym': programAcronym, 
          'place': selectedBuilding, 
          'bio': _bioController.text.trim(),
          'strengths': selectedSkills,
          'weaknesses': selectedBetterSkills,
          'avatarPath': avatarPath,
          'updatedAt': FieldValue.serverTimestamp(),
          'profileComplete': true,
        };

        // Update Firestore
        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .update(updateData);

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
  // --- END: Save Changes ---

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
                          _buildTextField("Display Name",
                              "Enter your display name", _displayNameController),
                          SizedBox(height: 12),
                          _buildDropdown(
                            "Gender",
                            _genderOptions,
                            selectedGender!,
                            (val) {
                              setState(() => selectedGender = val);
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
                          // Year Level
                          _buildDropdown(
                            "Year Level",
                            _yearOptions,
                            selectedYear!,
                            (val) {
                              setState(() => selectedYear = val);
                            },
                          ),
                          SizedBox(height: 12),
                          // Department Dropdown (updates building/avatar in background)
                          _buildDepartmentDropdown(),
                          SizedBox(height: 12),
                          // Program Dropdown (filtered by department)
                          _buildDropdown(
                            "Program",
                            _getProgramsForSelectedDepartment(),
                            selectedProgram!,
                            (val) {
                              setState(() => selectedProgram = val);
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
                            "My Top Skills (Strengths) (Max 3)", // Updated label
                            allSkills,
                            selectedSkills,
                            (skill, selected) {
                              setState(() {
                                if (selected) {
                                  // Add skill, but check limit
                                  if (selectedSkills.length < 3) {
                                    selectedSkills.add(skill);
                                    selectedBetterSkills.remove(skill);
                                  } else {
                                    // Show error if limit reached
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('You can only select a maximum of 3 Top Skills (Strengths).'),
                                        backgroundColor: primaryRed,
                                      ),
                                    );
                                  }
                                } else {
                                  // Remove skill
                                  selectedSkills.remove(skill);
                                }
                              });
                            },
                            disabledSkills: selectedBetterSkills,
                          ),
                          SizedBox(height: 20),
                          _buildSkillsSection(
                            "Things I'd like to get better at (Weaknesses) (Max 3)", // Updated label
                            allSkills,
                            selectedBetterSkills,
                            // 🛑 UPDATED LOGIC FOR MAXIMUM 3 SKILLS
                            (skill, selected) {
                              setState(() {
                                if (selected) {
                                  // Add skill, but check limit
                                  if (selectedBetterSkills.length < 3) {
                                    selectedBetterSkills.add(skill);
                                    selectedSkills.remove(skill);
                                  } else {
                                    // Show error if limit reached
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('You can only select a maximum of 3 skills you want to get better at (Weaknesses).'),
                                        backgroundColor: primaryRed,
                                      ),
                                    );
                                  }
                                } else {
                                  // Remove skill
                                  selectedBetterSkills.remove(skill);
                                }
                              });
                            },
                            disabledSkills: selectedSkills,
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
  
  // --- START: Building Widget Methods ---

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
    final displayAvatarPath = avatarPath ?? _getDefaultAvatarPath("CCE");
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
                  backgroundImage: displayAvatarPath.startsWith('http')
                      ? NetworkImage(displayAvatarPath) as ImageProvider
                      : AssetImage(displayAvatarPath),
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
              _showAvatarOptionsModal();
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

  // --- START: New Avatar Modal/Dialog Implementation ---
  void _showAvatarOptionsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Change Profile Picture",
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              SizedBox(height: 20),
              // Option 1: Upload Image (IBB)
              _buildModalOption(
                icon: Icons.upload_file_rounded,
                title: "Upload Photo",
                subtitle: "Upload from your gallery",
                onTap: _handleImageUpload,
              ),
              SizedBox(height: 10),
              // Option 2: Select Avatar
              _buildModalOption(
                icon: Icons.person_pin_rounded,
                title: "Select Department Avatar",
                subtitle: "Use your college's default avatar",
                onTap: () {
                  Navigator.of(context).pop(); // Close current sheet
                  _showDepartmentAvatarSelection();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: primaryRed.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: primaryRed, size: 24),
      ),
      title: Text(
        title,
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.montserrat(
          color: textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios_rounded,
          color: textSecondary, size: 16),
    );
  }

  void _showDepartmentAvatarSelection() {
    final String departmentCode = selectedDepartment ?? "CCE";
    final String departmentName = _getDepartmentDisplayName(departmentCode);
    final String defaultAvatarPath = _getDefaultAvatarPath(departmentCode);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
                child: Text(
                  "Default Department Avatar",
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                // 🛑 Only show the one option for the current department
                child: _buildDepartmentOption(
                  departmentName,
                  defaultAvatarPath,
                  defaultAvatarPath,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDepartmentOption(String name, String logoPath, String avatarPath) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _setAvatarPath(logoPath),
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: this.avatarPath == logoPath ? primaryRed : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  margin: EdgeInsets.only(right: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: AssetImage(logoPath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    name,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textPrimary,
                    ),
                  ),
                ),
                if (this.avatarPath == logoPath)
                  Icon(Icons.check_circle_rounded, color: primaryRed, size: 24),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
  // --- END: New Avatar Modal/Dialog Implementation ---

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

  Widget _buildTextField(
      String label, String hint, TextEditingController controller) {
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
              hintText:
                  "Tell us about yourself, your interests, goals, or what makes you unique...",
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
          items: _departmentCodes
              .map(
                (code) => DropdownMenuItem<String>(
                  value: code,
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        margin: EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          image: DecorationImage(
                            image: AssetImage(
                                _getDepartmentLogoPath(code)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          _getDepartmentDisplayName(code),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (String? val) {
            setState(() {
              String? oldDepartment = selectedDepartment;
              selectedDepartment = val;
              if (val != null) {
                // Update building
                selectedBuilding = _departmentData[val]?['place'] ?? "N/A";
                // Update program
                selectedProgram = _getDefaultProgram(val);
                
                if (oldDepartment != null) {
                  final String oldAvatarPath = _getDefaultAvatarPath(oldDepartment);
                  final String newAvatarPath = _getDefaultAvatarPath(val);

                  // If the user currently has the old default department avatar selected,
                  // automatically switch to the new department's default.
                  if (avatarPath == oldAvatarPath) {
                      avatarPath = newAvatarPath;
                  }
                }
              }
            });
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
    // NOTE: 'context' is required for selectedItemBuilder and is assumed available.

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
            // 💡 Keep vertical padding minimal (e.g., 4) so the Text widget's height dictates the field height.
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4), 
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
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: textSecondary),
          style: GoogleFonts.montserrat(fontSize: 14, color: textPrimary),
          
          // Use selectedItemBuilder to control the selected item's height
          selectedItemBuilder: (BuildContext context) {
            return items.map((String item) {
              return Text(
                item,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(fontSize: 14, color: textPrimary),
              );
            }).toList();
          },

          items: items
              .map((item) => DropdownMenuItem(
                  value: item,
                  // Menu item text wrapping
                  child: Text(
                    item,
                    maxLines: 4, 
                    overflow: TextOverflow.ellipsis, 
                  )))
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
    Function(String, bool) onSkillSelected, {
    required List<String> disabledSkills,
  }) {
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
          spacing: 6,
          runSpacing: 6,
          children: skills.map((skill) {
            final isSelected = selectedSkills.contains(skill);
            final isDisabled = disabledSkills.contains(skill);

            return Opacity(
              opacity: isDisabled ? 0.4 : 1.0,
              child: GestureDetector(
                onTap: isDisabled
                    ? null
                    : () {
                        onSkillSelected(skill, !isSelected);
                      },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryRed : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? primaryRed : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    skill,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : textSecondary,
                    ),
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