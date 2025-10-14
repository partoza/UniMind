import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unimind/views/home/home_page.dart';
// import 'package:unimind/views/home/home_page.dart'; // Assume this file exists

class WelcomePage extends StatefulWidget {
  final String name;
  final String yearLevel;
  final String program;
  final String department;
  final String? avatarUrl;
  final VoidCallback? onError;

  const WelcomePage({
    super.key,
    required this.name,
    required this.yearLevel,
    required this.program,
    required this.department,
    this.avatarUrl,
    this.onError,
  });

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _avatarController;
  late Animation<double> _avatarScaleAnimation;
  bool _isLoading = false;

  // --- Theme Constants ---
  static const Color _maroonColor = Color(0xFFB41214); // Primary Maroon Color
  static const LinearGradient _maroonBlackGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      _maroonColor, // Maroon
      Color(0xFF000000), // Black
    ],
  );

  // Map of department acronyms to their primary hex color for the card background.
  static const Map<String, String> _cardColorHexMap = {
    'CAE': '#30E8FD', // Light Cyan
    'CAFAE': '#6D6D6D', // Medium Grey
    'CBAE': '#FFDD00', // Bright Yellow
    'CCE': '#FFDE00', // Bright Yellow
    'CHE': '#AA00FF', // Bright Violet
    'CCJE': '#FF3700', // Bright Red-Orange
    'CASE': '#299504', // Bright Green
    'CEE': '#FF9D00', // Bright Orange
    'CHSE': '#75B8FF', // Light Blue
    'CTE': '#1E05FF', // Bright Blue
  };

  // Department data structure that stores the full name and logo path.
  static const Map<String, dynamic> _departmentDetails = {
    'CAE': {
      'code': 'College of Accounting Education',
      'logo': 'assets/depLogo/caelogo.png',
    },
    'CAFAE': {
      'code': 'College of Architecture and Fine Arts Education',
      'logo': 'assets/depLogo/cafaelogo.png',
    },
    'CBAE': {
      'code': 'College of Business Administration Education',
      'logo': 'assets/depLogo/cbaelogo.png',
    },
    'CCE': {
      'code': 'College of Computing Education',
      'logo': 'assets/depLogo/ccelogo.png',
    },
    'CHE': {
      'code': 'College of Hospitality Education',
      'logo': 'assets/depLogo/chelogo.png',
    },
    'CCJE': {
      'code': 'College of Criminal Justice Education',
      'logo': 'assets/depLogo/ccjelogo.png',
    },
    'CASE': {
      'code': 'College of Arts and Sciences Education',
      'logo': 'assets/depLogo/caselogo.png',
    },
    'CEE': {
      'code': 'College of Engineering Education',
      'logo': 'assets/depLogo/ceelogo.png',
    },
    'CHSE': {
      'code': 'College of Health Sciences Education',
      'logo': 'assets/depLogo/chselogo.png',
    },
    'CTE': {
      'code': 'College of Teacher Education',
      'logo': 'assets/depLogo/ctelogo.png',
    },
    'Default': {'code': 'UNIMIND', 'logo': 'assets/icon/logoIconMaroon.png'},
  };

  // Helper function to convert hex string to Color and optionally darken it for a gradient
  Color _hexToColor(String hexCode, {double factor = 1.0}) {
    String formattedHex = hexCode.replaceAll('#', '');
    if (formattedHex.length == 6) {
      formattedHex = 'FF$formattedHex';
    }
    int colorValue = int.parse(formattedHex, radix: 16);
    Color original = Color(colorValue);

    // Apply factor for darker shade if needed
    int r = (original.red * factor).round().clamp(0, 255);
    int g = (original.green * factor).round().clamp(0, 255);
    int b = (original.blue * factor).round().clamp(0, 255);

    return Color.fromARGB(original.alpha, r, g, b);
  }

  // Combines details and calculates gradient colors
  Map<String, dynamic> _getDepartmentDetails() {
    final acronym = widget.department;
    final details =
        _departmentDetails[acronym] ?? _departmentDetails['Default']!;

    final hexCode = _cardColorHexMap[acronym] ?? '#B41214'; // Default to maroon

    // Define the gradient colors for the card
    final color1 = _hexToColor(hexCode, factor: 1.0); // Primary color
    final color2 = _hexToColor(
      hexCode,
      factor: 0.7,
    ); // Darker shade (70% brightness)

    return {
      'acronym': acronym,
      'code': details['code'],
      'logo': details['logo'],
      'cardColor1': color1,
      'cardColor2': color2,
      // Page background remains maroon/black
      'pageGradient': _maroonBlackGradient,
    };
  }

  // Helper to format year level (e.g., '1' -> '1st Year Level')
  String _getFormattedYearLevel(String yearLevel) {
    // BUG FIX/ENHANCEMENT: Refined the default case to correctly apply ordinal suffixes
    final yearStr = yearLevel.trim();

    // Explicitly handle 1, 2, 3, 4 which are common university year levels
    switch (yearStr) {
      case '1':
        return '1st Year Level';
      case '2':
        return '2nd Year Level';
      case '3':
        return '3rd Year Level';
      case '4':
        return '4th Year Level';
      default:
        final year = int.tryParse(yearStr);
        if (year != null) {
          // Robust ordinal generation for numbers 5 and up (5th, 11th, 21st, etc.)
          String suffix;

          // Special case for 11, 12, 13
          if (year % 100 >= 11 && year % 100 <= 13) {
            suffix = 'th';
          } else {
            // General case for 1, 2, 3 (st, nd, rd) and others (th)
            switch (year % 10) {
              case 1:
                suffix = 'st';
                break;
              case 2:
                suffix = 'nd';
                break;
              case 3:
                suffix = 'rd';
                break;
              default:
                suffix = 'th';
                break;
            }
          }
          return '$year$suffix Year Level';
        }
        // If it's not a known case or a valid number, return the raw string
        return yearStr;
    }
  }

  @override
  void initState() {
    super.initState();
    _avatarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _avatarScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _avatarController, curve: Curves.elasticOut),
    );

    _avatarController.forward();
  }

  @override
  void dispose() {
    _avatarController.dispose();
    super.dispose();
  }

  Future<void> _navigateToHome() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        // Use pushReplacement to prevent going back to welcome screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>  HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackbar("Failed to navigate. Please try again.");
      }
      if (widget.onError != null) {
        widget.onError!();
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _maroonColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- MODIFIED: Changed shape from circle to rounded rectangle (ClipRRect) ---
  Widget _buildAvatar(double size) {
    final isLocalAsset =
        widget.avatarUrl != null && widget.avatarUrl!.startsWith('assets/');
    final placeholderColor = Colors.grey[700];

    Widget imageWidget;
    if (widget.avatarUrl == null) {
      imageWidget = Container(
        width: size,
        height: size,
        color: placeholderColor,
        child: const Icon(Icons.person, size: 60, color: Colors.white),
      );
    } else if (isLocalAsset) {
      imageWidget = Image.asset(
        widget.avatarUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    } else {
      imageWidget = Image.network(
        widget.avatarUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: size,
            height: size,
            color: Colors.grey[800],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            color: _maroonColor.withOpacity(0.8),
            child: const Icon(Icons.error, size: 50, color: Colors.white),
          );
        },
      );
    }

    // Apply rounded corners and border/shadow
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        // Clip the image content to the rounded container shape
        borderRadius: BorderRadius.circular(26),
        child: imageWidget,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final depDetails = _getDepartmentDetails();
    final pageGradient = depDetails['pageGradient'] as LinearGradient;
    final size = MediaQuery.of(context).size;

    // MODIFIED: Bigger image size (80% of width) for full width square look
    final imageSize = size.width * 0.8;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: pageGradient, // Stays Maroon/Black
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar with all-white logo and no back button
              _buildCustomAppBar(context),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Text
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 800),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Padding(
                                // Adjusted top padding slightly as the image is much bigger
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Text(
                                  "WELCOME,",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Spacing between WELCOME and Image
                      // MODIFIED: Reduced spacing since image is bigger
                      const SizedBox(height: 20),

                      // Profile Image
                      Center(
                        child: ScaleTransition(
                          scale: _avatarScaleAnimation,
                          // Added padding to prevent image from touching screen edges
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: _buildAvatar(imageSize),
                          ),
                        ),
                      ),

                      // Profile Details (Below the image)
                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: _buildProfileDetailsCard(depDetails),
                      ),
                    ],
                  ),
                ),
              ),

              // NEW: Welcome/Instructional Message above the button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "Welcome to UniMind, find now a Study Partner",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
              // Get Started Button
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 40.0,
                  left: 24.0,
                  right: 24.0,
                  top: 10.0,
                ),
                child: _buildGetStartedButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- MODIFIED: Removed back button and made the logo all white ---
  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 20,
        bottom: 5,
      ), // Adjusted padding for center alignment
      child: Center(
        // Use a Row to place the image and text side-by-side
        child: Row(
          mainAxisSize:
              MainAxisSize.min, // Constrain the Row size to its children
          children: [
            // 1. Logo Image
            Image.asset(
              'assets/icon/logoIconWhite.png',
              height: 28, // Sized to fit the 22pt text
              // You might want to add error handling or a color property here
            ),
            const SizedBox(width: 8), // Spacing between logo and text
            // 2. Text
            Text(
              "UniMind",
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MODIFIED: Swapped position of Department Acronym and Program Name ---
  Widget _buildProfileDetailsCard(Map<String, dynamic> depDetails) {
    final departmentAcronym = depDetails['acronym'];
    final departmentLogo = depDetails['logo'];
    final cardColor1 = depDetails['cardColor1'] as Color;
    final cardColor2 = depDetails['cardColor2'] as Color;
    final formattedYearLevel = _getFormattedYearLevel(widget.yearLevel);
    final cardGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [cardColor1, cardColor2],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name and Year Level (Above the colored card)
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name,
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors
                      .white, // White text against maroon/black background
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formattedYearLevel,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.8),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),

        // Department and Program Card (Uses department gradient)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: cardGradient,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white, // White background for the logo
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Image.asset(departmentLogo, height: 36),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Department Acronym (e.g., CAE) - TOP
                    Text(
                      departmentAcronym,
                      style: GoogleFonts.montserrat(
                        fontSize: 18, // Emphasis on Department Acronym
                        fontWeight: FontWeight.w700,
                        color: Colors.white, // Bold white
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Program (e.g., BSIT) - BOTTOM
                    Text(
                      widget.program,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color:
                            Colors.white70, // Slightly faded white for program
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- MODIFIED: Added arrow icon to the button ---
  Widget _buildGetStartedButton() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + 0.2 * value,
          child: Opacity(
            opacity: value,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _navigateToHome,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _maroonColor.withOpacity(
                  0.8,
                ), // User feedback color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 10, // Increased elevation for better look
                shadowColor: Colors.black.withOpacity(0.4),
                minimumSize: const Size(double.infinity, 0),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(_maroonColor),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Get Started",
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: _maroonColor, // Button text in maroon
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.arrow_forward_ios_rounded, // Arrow icon
                          size: 18,
                          color: _maroonColor,
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}
