import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unimind/views/profile/edit_profile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      backgroundColor: Colors.white,
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
                  top: 30,
                  left: 20,
                  right: 20,
                  bottom: 60,
                ),
                color: const Color(0xFFB41214),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "My Profile",
                      style: GoogleFonts.montserrat(
                        fontSize: 28 * textScale,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// Row: Profile Picture + Info
                    Row(
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
                                "John Rex Partoza",
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "3rd Year Student",
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditProfilePage(),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white70),
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 6,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  "Edit Profile",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickInfoSection(),

                  const SizedBox(height: 2),

                  /// College Department with Modern Card
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
                          Color.fromARGB(255, 227, 224, 41),
                          Color(0xfff7f9e8),
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
                          child: Image.asset("assets/ccelogo.png", height: 36),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "College of Computing Education",
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "BS Information Technology",
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

                  /// Bio
                  _sectionTitle("My Bio"),
                  _infoCard("LF Batak mo study og math"),

                  const SizedBox(height: 15),

                  /// Top Skills
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle("Top Skills"),
                            const SizedBox(height: 8),
                            _buildSkillsChips([
                              "Coding",
                              "UI/UX Design",
                              "Graphic Design",
                              "Flutter",
                              "Problem Solving",
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  /// Things I'd like to get better
                  _sectionTitle("Areas for Improvement"),
                  const SizedBox(height: 8),
                  _buildSkillsChips([
                    "Advanced Algorithms",
                    "Machine Learning",
                    "Backend Development",
                    "Team Leadership",
                  ], isImprovement: true),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section Title
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

  /// Card with plain text
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
          _buildQuickInfoItem("Gender", "Male", Icons.male),
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
}

/// Custom clipper for smooth curved bottom
class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 30, // control point for curve depth
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
