import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/rendering.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key, required this.source});

  final String source;

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userDoc = await _firestore.collection('users').doc(widget.source).get();
      if (userDoc.exists) {
        setState(() {
          userData = userDoc.data()!;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading user data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Generate QR data that includes user ID and basic info
  // Generate QR data that includes user ID and basic info
String get _generateQrData {
  // Make sure we're using the actual user ID, not "profile"
  final userId = _getCurrentUserId();
  print("Generating QR for user ID: $userId");
  
  // Use simple URL format
  return "unimind://user/$userId";
}

String _getCurrentUserId() {
  // Get the actual Firebase user ID
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    return currentUser.uid;
  }
  
  // Fallback to widget.source if it's a valid Firebase ID
  if (widget.source.length >= 20 && widget.source.length <= 30) {
    return widget.source;
  }
  
  // If widget.source is "profile", we need to get the actual user ID from Firebase
  print("Warning: Using widget.source as user ID: ${widget.source}");
  return widget.source;
}

  Future<void> _shareQrCode() async {
    try {
      // Create a boundary to capture the QR widget
      final boundary = _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage();
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final imageBytes = byteData!.buffer.asUint8List();

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/qr_code_${widget.source}.png');
      await file.writeAsBytes(imageBytes);

      // Share the QR code
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Scan my Unimind QR code to connect with me!',
        subject: 'My Unimind QR Code',
      );
      
    } catch (e) {
      print("Error sharing QR code: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share QR code', style: GoogleFonts.montserrat()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveQrCode() async {
    try {
      // Create a boundary to capture the QR widget
      final boundary = _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage();
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final imageBytes = byteData!.buffer.asUint8List();

      // Get downloads directory (or documents if downloads isn't available)
      final directory = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/Unimind_QR_${widget.source}.png');
      await file.writeAsBytes(imageBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('QR Code saved successfully!', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
              Text('Location: ${file.path}', style: GoogleFonts.montserrat(fontSize: 12)),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      print("Error saving QR code: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save QR code: $e', style: GoogleFonts.montserrat()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSaveOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Save or Share QR Code",
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB71C1C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.save_alt, color: Color(0xFFB71C1C)),
                ),
                title: Text(
                  "Save to Device",
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  "Save QR code to your downloads folder",
                  style: GoogleFonts.montserrat(fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _saveQrCode();
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB71C1C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.share, color: Color(0xFFB71C1C)),
                ),
                title: Text(
                  "Share QR Code",
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  "Share via messaging apps or social media",
                  style: GoogleFonts.montserrat(fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _shareQrCode();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  final GlobalKey _qrKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "My QR Code",
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFFB71C1C),
        elevation: 0.5,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header section with clipped curved bottom
              ClipPath(
                clipper: _HeaderClipper(),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    top: 12,
                    left: 20,
                    right: 20,
                    bottom: 30,
                  ),
                  color: const Color(0xFFB71C1C),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // QR Code Container with subtle shadow
                      RepaintBoundary(
                        key: _qrKey,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: isLoading 
                              ? Container(
                                  width: isSmallScreen ? 130 : 180,
                                  height: isSmallScreen ? 130 : 180,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB71C1C)),
                                    ),
                                  ),
                                )
                              : QrImageView(
                                  data: _generateQrData,
                                  version: QrVersions.auto,
                                  size: isSmallScreen ? 130.0 : 180.0,
                                  backgroundColor: Colors.white,
                                  eyeStyle: const QrEyeStyle(
                                    eyeShape: QrEyeShape.square,
                                    color: Color(0xFFB71C1C),
                                  ),
                                  dataModuleStyle: const QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.square,
                                    color: Color(0xFF1a1a1a),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // User info with verified badge
                      if (!isLoading && userData != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              userData!['displayName'] ?? 'User',
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 18 : 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.verified,
                                color: Color(0xFFB71C1C),
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          userData!['yearLevel'] != null 
                              ? _getYearLevelString(userData!['yearLevel'])
                              : 'Student',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ] else if (!isLoading) ...[
                        Text(
                          "User Profile",
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 18 : 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Save/Share Button with icon
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _showSaveOptions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB71C1C),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    shadowColor: Colors.black.withOpacity(0.2),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2, 
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save_alt_rounded, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Save QR Code",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Informational section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[200]!, width: 1),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 40,
                      color: Color(0xFFB71C1C),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Share Your Profile",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Ask others to scan your QR code with their phone camera to instantly connect and match on the app",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Additional tip
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  "Tip: Make sure your QR code is clearly visible when sharing",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _getYearLevelString(dynamic yearLevel) {
    try {
      int level;
      if (yearLevel is int) {
        level = yearLevel;
      } else if (yearLevel is String) {
        final match = RegExp(r'\d+').firstMatch(yearLevel);
        level = match != null ? int.parse(match.group(0)!) : 1;
      } else {
        level = 1;
      }

      switch (level) {
        case 1: return '1st Year Student';
        case 2: return '2nd Year Student';
        case 3: return '3rd Year Student';
        case 4: return '4th Year Student';
        case 5: return '5th Year Student';
        default: return 'Student';
      }
    } catch (e) {
      return 'Student';
    }
  }
}

/// Custom clipper for smooth curved bottom used in header
class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
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