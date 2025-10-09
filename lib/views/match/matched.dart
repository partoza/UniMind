import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unimind/views/home/home_page.dart';

class MatchedPage extends StatelessWidget {
  const MatchedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 700;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Skip for now',
                        style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: isSmallScreen ? 10 : 20),
                
                // MATCHED title with gradient effect
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      const Color(0xFFB71C1C),
                      const Color(0xFFD32F2F),
                      const Color(0xFFB71C1C),
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ).createShader(bounds),
                  child: Text(
                    'MATCHED',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 32 : 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                
                SizedBox(height: isSmallScreen ? 20 : 40),
                
                // Study partner cards with circular background
                SizedBox(
                  height: isSmallScreen ? 300 : 360,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Circular background layers - smaller sizing
                      Positioned(
                        child: Container(
                          width: isSmallScreen ? 240 : 280,
                          height: isSmallScreen ? 240 : 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFB71C1C).withOpacity(0.15),
                          ),
                        ),
                      ),
                      Positioned(
                        child: Container(
                          width: isSmallScreen ? 200 : 240,
                          height: isSmallScreen ? 200 : 240,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFFB71C1C),
                                const Color(0xFFD32F2F),
                                const Color(0xFFB71C1C),
                              ],
                              stops: [0.0, 0.7, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFB71C1C).withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        child: Container(
                          width: isSmallScreen ? 160 : 200,
                          height: isSmallScreen ? 160 : 200,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFB71C1C),
                          ),
                        ),
                      ),
                      
                      // Cards - positioned directly in the main stack
                      // Left card (user's card) - positioned to the left
                      Positioned(
                        left: isSmallScreen ? 0.5 : 5,
                        top: isSmallScreen ? -5 : 0,
                        child: Transform.rotate(
                          angle: -0.15,
                          child: Container(
                            width: isSmallScreen ? 110 : 140,
                            height: isSmallScreen ? 180 : 220,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // Placeholder for user image
                                  Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  // Bookmark badge (matching home page style)
                                  Positioned(
                                    top: 0,
                                    right: 6,
                                    child: BookmarkBadgeWidget(
                                      department: 'CCE', // User's department
                                      size: Size(
                                        isSmallScreen ? 28 : 32,
                                        isSmallScreen ? 42 : 48,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      
                      // Right card (partner's card) - positioned to overlap left card
                      Positioned(
                        right: isSmallScreen ? 0.5 : 5,
                        top: isSmallScreen ? -5 : 0,
                        child: Transform.rotate(
                          angle: 0.15,
                          child: Container(
                            width: isSmallScreen ? 110 : 140,
                            height: isSmallScreen ? 180 : 220,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // Grayscale placeholder for partner image
                                  ColorFiltered(
                                    colorFilter: const ColorFilter.mode(
                                      Colors.grey,
                                      BlendMode.saturation,
                                    ),
                                    child: Container(
                                      color: Colors.grey[400],
                                      child: const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  // Bookmark badge (matching home page style)
                                  Positioned(
                                    top: 0,
                                    right: 6,
                                    child: BookmarkBadgeWidget(
                                      department: 'CAS', // Partner's department
                                      size: Size(
                                        isSmallScreen ? 28 : 32,
                                        isSmallScreen ? 42 : 48,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Center book icon - positioned to overlap both cards (on top)
                      Positioned(
                        top: isSmallScreen ? 70 : 75,
                        child: Container(
                          width: isSmallScreen ? 40 : 45,
                          height: isSmallScreen ? 40 : 45,
                          decoration: BoxDecoration(
                            color: const Color(0xFFB41214), // Maroon fill
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                              BoxShadow(
                                color: const Color(0xFFB41214).withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Transform.scale(
                              scale: isSmallScreen ? 0.8 : 0.9,
                              child: SvgPicture.asset(
                                'assets/icon/book_icon.svg',
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Text label - positioned at bottom of red circle
                      Positioned(
                        bottom: isSmallScreen ? 40 : 50,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 12 : 16,
                            vertical: isSmallScreen ? 12 : 14,
                          ),
                            child: Text(
                              'Meet Your Study\nPartner,\nGA !',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Bottom section - more compact
                Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  child: Column(
                    children: [
                      Text(
                        'This study partner will help you stay motivated and\nfocused, and you can chat with it now.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          color: const Color(0xFF333333),
                          fontSize: isSmallScreen ? 10 : 12,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      SizedBox(
                        width: double.infinity,
                        height: isSmallScreen ? 44 : 48,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFB71C1C),
                                const Color(0xFFD32F2F),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFB71C1C).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Go to chat',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 13 : 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}