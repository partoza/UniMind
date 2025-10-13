import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unimind/widgets/custom_snackbar.dart';

// A class to handle all department-related data and logic.
class DepartmentData {
  // Department color map
  static const Map<String, String> _colorHexMap = {
    'CAE': '#30E8FD',
    'CAFAE': '#6D6D6D',
    'CBAE': '#FFDD00',
    'CCE': '#FFDE00',
    'CHE': '#AA00FF',
    'CCJE': '#FF3700',
    'CASE': '#299504',
    'CEE': '#FF9D00',
    'CHSE': '#75B8FF',
    'CTE': '#1E05FF',
  };

  // Converts a hex string to a Flutter Color object.
  static Color _hexToColor(String hexString) {
    final hex = hexString.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  // Generates a lighter shade of the primary color for the gradient end.
  static Color _getLighterShade(Color color) {
    return Color.fromARGB(
      255,
      (color.red + (255 - color.red) * 0.5).round(),
      (color.green + (255 - color.green) * 0.5).round(),
      (color.blue + (255 - color.blue) * 0.5).round(),
    );
  }

  // Returns the start and end colors for the LinearGradient.
  static List<Color> getGradientColors(String department) {
    final hexColor =
        _colorHexMap[department.toUpperCase()] ?? '#B0B0B0'; // Default gray
    final primaryColor = _hexToColor(hexColor);
    final lightColor = _getLighterShade(primaryColor);
    return [primaryColor, lightColor];
  }

  // Returns the asset path for the department logo.
  static String getDepartmentLogoPath(String department) {
    final String code = department.toUpperCase();
    switch (code) {
      case 'CAE':
        return 'assets/depLogo/caelogo.png';
      case 'CAFAE':
        return 'assets/depLogo/cafaelogo.png';
      case 'CBAE':
        return 'assets/depLogo/cbaelogo.png';
      case 'CCE':
        return 'assets/depLogo/ccelogo.png';
      case 'CHE':
        return 'assets/depLogo/chelogo.png';
      case 'CCJE':
        return 'assets/depLogo/ccjelogo.png';
      case 'CASE':
        return 'assets/depLogo/caselogo.png';
      case 'CEE':
        return 'assets/depLogo/ceelogo.png';
      case 'CHSE':
        return 'assets/depLogo/chselogo.png';
      case 'CTE':
        return 'assets/depLogo/ctelogo.png';
      default:
        return 'assets/depLogo/defaultlogo.png'; // Fallback
    }
  }
}

class MessageProfileView extends StatefulWidget {
  final String peerUid;
  final String peerName;
  final String peerAvatar;

  const MessageProfileView({
    Key? key,
    required this.peerUid,
    required this.peerName,
    required this.peerAvatar,
  }) : super(key: key);

  @override
  State<MessageProfileView> createState() => _MessageProfileViewState();
}

class _MessageProfileViewState extends State<MessageProfileView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _getYearLevelString(dynamic yearLevel) {
    try {
      // Handle both int and string types
      int level;
      if (yearLevel is int) {
        level = yearLevel;
      } else if (yearLevel is String) {
        final match = RegExp(r'\d+').firstMatch(yearLevel);
        level = match != null ? int.parse(match.group(0)!) : 1;
      } else {
        level = 1; // default
      }

      switch (level) {
        case 1:
          return '1st Year Student';
        case 2:
          return '2nd Year Student';
        case 3:
          return '3rd Year Student';
        case 4:
          return '4th Year Student';
        default:
          return 'Student';
      }
    } catch (e) {
      print("Error parsing year level: $e");
      return 'Student';
    }
  }

  // Helper method to safely get data from Firestore
  dynamic _getUserData(
    Map<String, dynamic>? userData,
    String key, {
    dynamic defaultValue,
  }) {
    if (userData == null || !userData.containsKey(key)) {
      return defaultValue;
    }
    return userData[key];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFB41214),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Profile",
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Red Header with Smooth Curved Bottom
            ClipPath(
              clipper: _HeaderClipper(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  bottom: 60,
                ),
                color: const Color(0xFFB41214),
                child: StreamBuilder<DocumentSnapshot>(
                  stream: _firestore
                      .collection('users')
                      .doc(widget.peerUid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildHeaderLoading();
                    }

                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return _buildHeaderPlaceholder();
                    }

                    final userData =
                        snapshot.data!.data() as Map<String, dynamic>?;
                    return _buildHeaderContent(userData, context);
                  },
                ),
              ),
            ),

            StreamBuilder<DocumentSnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(widget.peerUid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildBodyLoading();
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return _buildBodyPlaceholder();
                }

                final userData = snapshot.data!.data() as Map<String, dynamic>?;
                return _buildBodyContent(userData, context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderLoading() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CircleAvatar(
          radius: 45,
          backgroundColor: Colors.white24,
          child: Icon(Icons.person, size: 40, color: Colors.white),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 150, height: 20, color: Colors.white24),
              const SizedBox(height: 8),
              Container(width: 100, height: 16, color: Colors.white24),
              const SizedBox(height: 8),
              _buildFollowButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderPlaceholder() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CircleAvatar(
          radius: 45,
          backgroundImage: AssetImage("assets/cce_male.jpg"),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.peerName,
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "User profile",
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              _buildFollowButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderContent(
    Map<String, dynamic>? userData,
    BuildContext context,
  ) {
    final displayName = _getUserData(
      userData,
      'displayName',
      defaultValue: widget.peerName,
    );
    final yearLevel = _getUserData(userData, 'yearLevel', defaultValue: 1);
    final avatarPath = _getUserData(
      userData,
      'avatarPath',
      defaultValue: "assets/cce_male.jpg",
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 45,
          backgroundImage: avatarPath.toString().startsWith('http')
              ? NetworkImage(avatarPath.toString()) as ImageProvider
              : AssetImage(avatarPath.toString()),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName.toString(),
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                _getYearLevelString(yearLevel),
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              _buildFollowButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBodyLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickInfoSectionLoading(),
          const SizedBox(height: 15),
          _sectionTitle("College Department"),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey[200],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.school, size: 36, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 200,
                        height: 20,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 150,
                        height: 16,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          _sectionTitle("My Bio"),
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[200],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickInfoSection(),
          const SizedBox(height: 2),
          _sectionTitle("College Department"),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFCCCCCC), // Neutral Gray
                  Color(0xFFEEEEEE), // Very Light Gray
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    "assets/depLogo/defaultlogo.png",
                    height: 36,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "User profile",
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Profile information",
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          _sectionTitle("My Bio"),
          _infoCard("No bio available"),
        ],
      ),
    );
  }

  Widget _buildBodyContent(
    Map<String, dynamic>? userData,
    BuildContext context,
  ) {
    final department = _getUserData(
      userData,
      'department',
      defaultValue: "Department not set",
    );
    final program = _getUserData(
      userData,
      'program',
      defaultValue: "Program not set",
    );
    final gender = _getUserData(userData, 'gender', defaultValue: "Not set");
    final place = _getUserData(userData, 'place', defaultValue: "Not set");
    final strengths = _getUserData(
      userData,
      'strengths',
      defaultValue: <String>[],
    );
    final weaknesses = _getUserData(
      userData,
      'weaknesses',
      defaultValue: <String>[],
    );
    final bio = _getUserData(
      userData,
      'bio',
      defaultValue: "No bio available",
    );

    final departmentLogo = DepartmentData.getDepartmentLogoPath(
      department.toString(),
    );
    final departmentColors = DepartmentData.getGradientColors(
      department.toString(),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickInfoSectionWithData(gender.toString(), place.toString()),
          const SizedBox(height: 2),
          _sectionTitle("College Department"),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: departmentColors,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(departmentLogo, height: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        department.toString(),
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        program.toString(),
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          /// Bio Section - Always show this
          _sectionTitle("My Bio"),
          _infoCard(bio.toString()),

          const SizedBox(height: 15),

          /// Strengths Section
          if (strengths is List && strengths.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle("Strengths"),
                const SizedBox(height: 8),
                _buildSkillsChips(
                  List<String>.from(strengths),
                  isImprovement: false,
                ),
                const SizedBox(height: 15),
              ],
            ),

          /// Weaknesses Section
          if (weaknesses is List && weaknesses.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle("Areas for Improvement"),
                const SizedBox(height: 8),
                _buildSkillsChips(
                  List<String>.from(weaknesses),
                  isImprovement: true,
                ),
                const SizedBox(height: 15),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoSectionLoading() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[50],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [_buildQuickInfoItemLoading(), _buildQuickInfoItemLoading()],
      ),
    );
  }

  Widget _buildQuickInfoItemLoading() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.help_outline, size: 20, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Container(width: 60, height: 16, color: Colors.grey[300]),
        const SizedBox(height: 4),
        Container(width: 40, height: 12, color: Colors.grey[300]),
      ],
    );
  }

  Widget _buildQuickInfoSectionWithData(String gender, String place) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[50],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickInfoItem("Gender", gender, Icons.person),
          _buildQuickInfoItem("Building", place, Icons.apartment),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _infoCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(text, style: GoogleFonts.montserrat(fontSize: 14)),
    );
  }

  Widget _buildQuickInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[50],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickInfoItem("Gender", "Not set", Icons.person),
          _buildQuickInfoItem("Building", "PS Building", Icons.apartment),
        ],
      ),
    );
  }

  Widget _buildQuickInfoItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFB41214).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: const Color(0xFFB41214)),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        Text(
          title,
          style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildSkillsChips(List<String> skills, {bool isImprovement = false}) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: skills.map((skill) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: isImprovement
                ? const LinearGradient(colors: [Colors.grey, Color(0xFF9E9E9E)])
                : const LinearGradient(
                    colors: [Color(0xFFB41214), Color(0xFFD32F2F)],
                  ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isImprovement)
                const Icon(Icons.arrow_upward, size: 12, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                skill,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFollowButton() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('following')
          .doc(widget.peerUid)
          .snapshots(),
      builder: (context, followingSnap) {
        final isFollowing = followingSnap.hasData && followingSnap.data!.exists;
        
        return StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('followRequests')
              .where('fromUid', isEqualTo: _auth.currentUser!.uid)
              .where('toUid', isEqualTo: widget.peerUid)
              .where('status', isEqualTo: 'pending')
              .snapshots(),
          builder: (context, requestSnap) {
            final isPendingSent = requestSnap.hasData && requestSnap.data!.docs.isNotEmpty;
            
            return StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('followRequests')
                  .where('fromUid', isEqualTo: widget.peerUid)
                  .where('toUid', isEqualTo: _auth.currentUser!.uid)
                  .where('status', isEqualTo: 'pending')
                  .snapshots(),
              builder: (context, receivedSnap) {
                final isPendingReceived = receivedSnap.hasData && receivedSnap.data!.docs.isNotEmpty;
                
                String buttonText;
                Color buttonColor;
                Color textColor;
                VoidCallback? onPressed;
                
                if (isFollowing) {
                  buttonText = "Following";
                  buttonColor = Colors.white;
                  textColor = Colors.black;
                  onPressed = () => _unfollowUser();
                } else if (isPendingSent) {
                  buttonText = "Pending";
                  buttonColor = Colors.white24;
                  textColor = Colors.white70;
                  onPressed = null;
                } else if (isPendingReceived) {
                  buttonText = "Accept";
                  buttonColor = Colors.white;
                  textColor = Colors.black;
                  onPressed = () => _acceptFollowRequest();
                } else {
                  buttonText = "Follow";
                  buttonColor = Colors.white;
                  textColor = Colors.black;
                  onPressed = () => _followUser();
                }
                
                return OutlinedButton(
                  onPressed: onPressed,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white70),
                    backgroundColor: buttonColor,
                    foregroundColor: textColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _followUser() async {
    try {
      final followRequestsRef = _firestore.collection('followRequests');
      
      // Check if request already exists
      final existingRequest = await followRequestsRef
          .where('fromUid', isEqualTo: _auth.currentUser!.uid)
          .where('toUid', isEqualTo: widget.peerUid)
          .where('status', isEqualTo: 'pending')
          .get();
          
      if (existingRequest.docs.isEmpty) {
        await followRequestsRef.add({
          'fromUid': _auth.currentUser!.uid,
          'toUid': widget.peerUid,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        if (mounted) {
          SnackBarHelper.showPendingRequest(context, "Follow request sent!");
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, "Error sending follow request: ${e.toString()}");
      }
    }
  }

  Future<void> _unfollowUser() async {
    try {
      final batch = _firestore.batch();
      
      // Remove following relationship
      final myFollowingDoc = _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('following')
          .doc(widget.peerUid);
      final theirFollowerDoc = _firestore
          .collection('users')
          .doc(widget.peerUid)
          .collection('followers')
          .doc(_auth.currentUser!.uid);
      
      batch.delete(myFollowingDoc);
      batch.delete(theirFollowerDoc);
      
      // Check if they're also following you (mutual follow)
      final theirFollowingDoc = await _firestore
          .collection('users')
          .doc(widget.peerUid)
          .collection('following')
          .doc(_auth.currentUser!.uid)
          .get();
          
      if (theirFollowingDoc.exists) {
        // Remove their following relationship too (mutual unfollow)
        final theirFollowingRef = _firestore
            .collection('users')
            .doc(widget.peerUid)
            .collection('following')
            .doc(_auth.currentUser!.uid);
        final myFollowerRef = _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('followers')
            .doc(widget.peerUid);
            
        batch.delete(theirFollowingRef);
        batch.delete(myFollowerRef);
      }
      
      // Clean up any pending requests
      final pendingRequests = await _firestore
          .collection('followRequests')
          .where('fromUid', whereIn: [_auth.currentUser!.uid, widget.peerUid])
          .where('toUid', whereIn: [_auth.currentUser!.uid, widget.peerUid])
          .where('status', isEqualTo: 'pending')
          .get();
          
      for (var doc in pendingRequests.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      
      if (mounted) {
        SnackBarHelper.showUnfollowSuccess(context, "Unfollowed successfully");
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, "Error unfollowing: ${e.toString()}");
      }
    }
  }

  Future<void> _acceptFollowRequest() async {
    try {
      final batch = _firestore.batch();
      
      // Delete all pending requests between users
      final pendingRequests = await _firestore
          .collection('followRequests')
          .where('fromUid', whereIn: [_auth.currentUser!.uid, widget.peerUid])
          .where('toUid', whereIn: [_auth.currentUser!.uid, widget.peerUid])
          .where('status', isEqualTo: 'pending')
          .get();
          
      for (var doc in pendingRequests.docs) {
        batch.delete(doc.reference);
      }
      
      // Establish mutual follow relationship
      final currentUserRef = _firestore.collection('users').doc(_auth.currentUser!.uid);
      final targetUserRef = _firestore.collection('users').doc(widget.peerUid);
      
      // You're following them
      batch.set(currentUserRef.collection('following').doc(widget.peerUid), {
        'timestamp': FieldValue.serverTimestamp()
      });
      // They're in your followers
      batch.set(currentUserRef.collection('followers').doc(widget.peerUid), {
        'timestamp': FieldValue.serverTimestamp()
      });
      
      // They're following you
      batch.set(targetUserRef.collection('following').doc(_auth.currentUser!.uid), {
        'timestamp': FieldValue.serverTimestamp()
      });
      // You're in their followers
      batch.set(targetUserRef.collection('followers').doc(_auth.currentUser!.uid), {
        'timestamp': FieldValue.serverTimestamp()
      });
      
      await batch.commit();
      
      if (mounted) {
        SnackBarHelper.showFollowSuccess(context, "You are now following each other!");
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, "Error accepting request: ${e.toString()}");
      }
    }
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 30,
      size.width,
      size.height - 50,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}