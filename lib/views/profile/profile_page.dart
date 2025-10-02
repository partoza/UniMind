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
                          backgroundImage: AssetImage("assets/profile.jpg"),
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
                                "3rd Year, BSIT",
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
                                      builder: (context) =>
                                         EditProfilePage(),
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

            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Gender & Building
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _labeledInfo("Gender", Icons.male, "Male"),
                      _labeledInfo("Building", Icons.apartment, "PS Building"),
                    ],
                  ),

                  const SizedBox(height: 15),

                  /// College Department
                  _sectionTitle("College Department"),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color.fromARGB(255, 227, 224, 41),
                          Color(0xfff7f9e8),
                        ],
                      ), // light yellow background
                    ),
                    child: Row(
                      children: [
                        Image.asset("assets/ccelogo.png", height: 40),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "College of Computing Education",
                            style: GoogleFonts.montserrat(fontSize: 15),
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
                  _sectionTitle("Top Skills"),
                  _chipCard([
                    _skillChip("Coding"),
                    _skillChip("UI/UX Design"),
                    _skillChip("Graphic Design"),
                  ]),

                  const SizedBox(height: 15),

                  /// Things I'd like to get better
                  _sectionTitle("Things I’d like to get better"),
                  _chipCard([
                    _skillChip("Coding"),
                    _skillChip("UI/UX Design"),
                    _skillChip("Graphic Design"),
                  ]),

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

  /// Info Item with Label (Gender, Building)
  Widget _labeledInfo(String label, IconData icon, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, color: Colors.black, size: 18),
            const SizedBox(width: 6),
            Text(
              text,
              style: GoogleFonts.montserrat(fontSize: 14, color: Colors.black),
            ),
          ],
        ),
      ],
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

  /// Card with chips
  Widget _chipCard(List<Widget> chips) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Wrap(spacing: 8, runSpacing: 8, children: chips),
    );
  }

  /// Skill Chip (red style)
  Widget _skillChip(String text) {
    return Chip(
      label: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color(0xFFB41214), // dark red
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
