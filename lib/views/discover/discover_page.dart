import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unimind/views/match/matched.dart';
import 'dart:convert';
import 'dart:async';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _showingProfile = false;
  Map<String, dynamic>? _scannedUserData;
  bool _isFollowing = false;
  bool _isPending = false;
  bool _isLoading = false;
  StreamSubscription<DocumentSnapshot>? _unfollowListener;
  StreamSubscription<QuerySnapshot>? _followRequestListener;

  void _onQRDetected(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    
    for (final barcode in barcodes) {
      if (barcode.rawValue != null && !_showingProfile && !_isLoading) {
        _processScannedQR(barcode.rawValue!);
        break;
      }
    }
  }

  Future<void> _processScannedQR(String qrData) async {
  setState(() {
    _isLoading = true;
  });

  try {
    print("=== QR SCAN DEBUG ===");
    print("Raw QR Data: '$qrData'");
    print("QR Data Length: ${qrData.length}");
    print("QR Data Type: ${qrData.runtimeType}");
    
    // Add a delay to see if multiple scans are happening
    await Future.delayed(Duration(milliseconds: 500));
    
    String? scannedUserId = _extractUserIdFromQR(qrData);
    
    print("Extracted User ID: $scannedUserId");
    
    if (scannedUserId == null) {
      print("No user ID extracted - invalid format");
      _showErrorSnackBar("Invalid QR code format");
      setState(() { _isLoading = false; });
      return;
    }

    print("Current User ID: ${_auth.currentUser?.uid}");
    if (scannedUserId == _auth.currentUser?.uid) {
      _showErrorSnackBar("This is your own QR code");
      setState(() { _isLoading = false; });
      return;
    }

    print("Fetching user data for ID: $scannedUserId");
    final userDoc = await _firestore.collection('users').doc(scannedUserId).get();
    
    if (!userDoc.exists) {
      print("User document does not exist");
      _showErrorSnackBar("User not found");
      setState(() { _isLoading = false; });
      return;
    }

    final currentUserId = _auth.currentUser!.uid;
    
    // Check if we're following them
    final followDoc = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('following')
        .doc(scannedUserId)
        .get();
    
    // Check if there's a pending follow request
    final pendingRequest = await _firestore
        .collection('followRequests')
        .where('fromUid', isEqualTo: currentUserId)
        .where('toUid', isEqualTo: scannedUserId)
        .where('status', isEqualTo: 'pending')
        .get();

    setState(() {
      _scannedUserData = userDoc.data()!;
      _scannedUserData!['id'] = scannedUserId;
      _isFollowing = followDoc.exists;
      _isPending = pendingRequest.docs.isNotEmpty;
      _showingProfile = true;
      _isLoading = false;
    });

    // Start listening for unfollow detection
    _startUnfollowDetection(scannedUserId);
    
    // Start listening for follow request acceptance
    _startFollowRequestListener(scannedUserId);

    print("Successfully loaded user profile");

  } catch (e) {
    print("Error processing QR: $e");
    _showErrorSnackBar("Error scanning QR code");
    setState(() {
      _isLoading = false;
    });
  }
}

  String? _extractUserIdFromQR(String qrData) {
  try {
    print("=== EXTRACTING USER ID ===");
    print("Raw QR Data: '$qrData'");
    
    // Clean the data
    final cleanedData = qrData.trim();
    print("Cleaned Data: '$cleanedData'");

    // Handle unimind://user/ format
    if (cleanedData.startsWith('unimind://user/')) {
      // Extract everything after 'unimind://user/'
      final userId = cleanedData.substring('unimind://user/'.length);
      print("Extracted User ID from URL: '$userId'");
      
      // If it's "profile", this is invalid - we need the actual user ID
      if (userId == 'profile') {
        print("ERROR: QR contains 'profile' instead of actual user ID");
        return null;
      }
      
      return userId;
    }

    // Direct user ID (Firebase IDs are typically 20-30 alphanumeric chars)
    if (RegExp(r'^[a-zA-Z0-9]{20,30}$').hasMatch(cleanedData)) {
      print("Using direct User ID: $cleanedData");
      return cleanedData;
    }

    print("No valid format detected");
    return null;
  } catch (e) {
    print("Error extracting user ID: $e");
    return null;
  }
}

  Future<void> _toggleFollow() async {
    if (_scannedUserData == null) return;

    setState(() {
      _isLoading = true;
    });

    final currentUserId = _auth.currentUser!.uid;
    final scannedUserId = _scannedUserData!['id'];
    
    try {
      if (_isFollowing) {
        // Unfollow: Implement mutual unfollow system like home page
        print('Unfollowing user $scannedUserId from discover page');
        
        // Check if they're also following you (mutual follow)
        final theirFollowingDoc = await _firestore
            .collection('users')
            .doc(scannedUserId)
            .collection('following')
            .doc(currentUserId)
            .get();
            
        final batch = _firestore.batch();
        
        // Remove your following relationship
        final myFollowingDoc = _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('following')
            .doc(scannedUserId);
        final theirFollowerDoc = _firestore
            .collection('users')
            .doc(scannedUserId)
            .collection('followers')
            .doc(currentUserId);
            
        batch.delete(myFollowingDoc);
        batch.delete(theirFollowerDoc);
        
        // If they're also following you, remove that too (mutual unfollow)
        if (theirFollowingDoc.exists) {
          final theirFollowingRef = _firestore
              .collection('users')
              .doc(scannedUserId)
              .collection('following')
              .doc(currentUserId);
          final myFollowerRef = _firestore
              .collection('users')
              .doc(currentUserId)
              .collection('followers')
              .doc(scannedUserId);
              
          batch.delete(theirFollowingRef);
          batch.delete(myFollowerRef);
          print('Mutual unfollow: removed their following relationship too');
        }
        
        // Also clean up any pending follow requests in both directions
        final followRequestsRef = _firestore.collection('followRequests');
        final pendingA = await followRequestsRef
            .where('fromUid', isEqualTo: currentUserId)
            .where('toUid', isEqualTo: scannedUserId)
            .where('status', isEqualTo: 'pending')
            .get();
            
        final pendingB = await followRequestsRef
            .where('fromUid', isEqualTo: scannedUserId)
            .where('toUid', isEqualTo: currentUserId)
            .where('status', isEqualTo: 'pending')
            .get();
            
        for (var doc in pendingA.docs) {
          batch.delete(doc.reference);
        }
        for (var doc in pendingB.docs) {
          batch.delete(doc.reference);
        }
        
        await batch.commit();
        
        print('Successfully unfollowed user $scannedUserId (mutual unfollow)');
        setState(() {
          _isFollowing = false;
          _isPending = false;
          _isLoading = false;
        });
      } else if (_isPending) {
        // Cancel pending request
        final followRequestsRef = _firestore.collection('followRequests');
        final pendingRequests = await followRequestsRef
            .where('fromUid', isEqualTo: currentUserId)
            .where('toUid', isEqualTo: scannedUserId)
            .where('status', isEqualTo: 'pending')
            .get();
            
        for (var doc in pendingRequests.docs) {
          await doc.reference.delete();
        }
        
        setState(() {
          _isPending = false;
          _isLoading = false;
        });
      } else {
        // Follow: Create a follow request
        final followRequestsRef = _firestore.collection('followRequests');
        
        // Check if request already exists
        final existingRequest = await followRequestsRef
            .where('fromUid', isEqualTo: currentUserId)
            .where('toUid', isEqualTo: scannedUserId)
            .where('status', isEqualTo: 'pending')
            .get();
            
        if (existingRequest.docs.isEmpty) {
          await followRequestsRef.add({
            'fromUid': currentUserId,
            'toUid': scannedUserId,
            'status': 'pending',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        
        setState(() {
          _isPending = true;
          _isLoading = false;
        });
      }

    } catch (e) {
      print("Error toggling follow: $e");
      _showErrorSnackBar("Error updating follow status");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startUnfollowDetection(String scannedUserId) {
    // Listen for changes in the scanned user's following collection to detect when they unfollow you
    final currentUserId = _auth.currentUser!.uid;
    
    _unfollowListener = _firestore
        .collection('users')
        .doc(scannedUserId)
        .collection('following')
        .doc(currentUserId)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        // If they're no longer following you, update the UI
        if (!snapshot.exists && _isFollowing) {
          setState(() {
            _isFollowing = false;
            _isPending = false;
          });
        }
        // If they're now following you (request was accepted), update to following
        else if (snapshot.exists && _isPending) {
          setState(() {
            _isFollowing = true;
            _isPending = false;
          });
        }
      }
    });
  }

  void _startFollowRequestListener(String scannedUserId) {
    // Listen for changes in follow requests to detect when request is accepted
    final currentUserId = _auth.currentUser!.uid;
    
    _followRequestListener = _firestore
        .collection('followRequests')
        .where('fromUid', isEqualTo: currentUserId)
        .where('toUid', isEqualTo: scannedUserId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        // If no pending requests exist and we were pending, it means request was accepted
        if (snapshot.docs.isEmpty && _isPending) {
          setState(() {
            _isFollowing = true;
            _isPending = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _unfollowListener?.cancel();
    _followRequestListener?.cancel();
    super.dispose();
  }

  void _closeProfile() {
    // Cancel both listeners
    _unfollowListener?.cancel();
    _followRequestListener?.cancel();
    _unfollowListener = null;
    _followRequestListener = null;
    
    setState(() {
      _showingProfile = false;
      _scannedUserData = null;
      _isFollowing = false;
      _isPending = false;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB41214), Color(0xFF8B0000), Color(0xFF5D0000)],
            stops: [0.0, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(child: ModernScanningAnimation()),
            ),

            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'DISCOVER',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontSize: 28 * textScale,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  Text(
                                    'Connect with students instantly',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.qr_code_scanner,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Point your camera at a QR code to view profiles and connect with other students',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.75,
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.75,
                              maxHeight: MediaQuery.of(context).size.width * 0.75,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 30,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 10),
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.1),
                                  blurRadius: 0,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: ModernQRScanner(
                                onQRDetected: _onQRDetected,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'or upload a QR code image',
                          style: GoogleFonts.montserrat(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.white.withOpacity(0.95),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: Implement image upload
                              _showErrorSnackBar("Image upload coming soon!");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFB41214),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.photo_library,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Upload from Gallery',
                                  style: GoogleFonts.montserrat(
                                    color: const Color(0xFFB41214),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),

            if (_showingProfile && _scannedUserData != null)
              _buildProfileOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOverlay() {
  final displayName = _scannedUserData!['displayName'] ?? 'Unknown User';
  final yearLevel = _scannedUserData!['yearLevel'] ?? '';
  final department = _scannedUserData!['department'] ?? 'Not specified';
  final program = _scannedUserData!['program'] ?? 'Not specified';
  final bio = _scannedUserData!['bio'] ?? 'No bio available';
  final avatarPath = _scannedUserData!['avatarPath'] ?? 'assets/cce_male.jpg';
  final gender = _scannedUserData!['gender'] ?? 'Not set';
  final strengths = _scannedUserData!['strengths'] ?? <String>[];
  final weaknesses = _scannedUserData!['weaknesses'] ?? <String>[];

  return Scaffold(
    backgroundColor: Colors.white,
    body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Red Header with Smooth Curved Bottom (matches profile page)
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
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
                        onPressed: _closeProfile,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Scanned Profile',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundImage: AssetImage(avatarPath),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
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
                  ),
                ],
              ),
            ),
          ),

          /// Body Content (matches profile page structure)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Quick Info Section
                _buildQuickInfoSection(gender.toString()),
                const SizedBox(height: 2),

                /// College Department Section
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
                              department,
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              program,
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

                /// Bio Section
                _sectionTitle("My Bio"),
                _infoCard(bio),

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
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// Add these helper methods to match the profile page styling:

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
    child: Text(
      text, 
      style: GoogleFonts.montserrat(
        fontSize: 14,
        height: 1.5,
      )
    ),
  );
}

Widget _buildQuickInfoSection(String gender) {
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
        style: GoogleFonts.montserrat(
          fontSize: 12, 
          color: Colors.grey[500]
        ),
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

  // Follow button used in the scanned profile header — uses DiscoverPage state
  Widget _buildFollowButton() {
    // Use the page's current following/pending/loading state and toggle logic
    return OutlinedButton(
      onPressed: _isLoading ? null : _toggleFollow,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.white70),
        backgroundColor: _isFollowing
            ? Colors.white
            : _isPending
                ? Colors.white24
                : Colors.white,
        foregroundColor: _isFollowing ? Colors.black : Colors.black,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              _isFollowing
                  ? "Following"
                  : _isPending
                      ? "Pending"
                      : "Follow",
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}

class ModernScanningAnimation extends StatefulWidget {
  const ModernScanningAnimation({super.key});

  @override
  State<ModernScanningAnimation> createState() => _ModernScanningAnimationState();
}

class _ModernScanningAnimationState extends State<ModernScanningAnimation>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 6000),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _opacityAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final scannerSize = screenWidth * 0.75;
    final scannerCenterX = screenWidth * 0.5;
    final scannerCenterY = screenHeight * 0.45;

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _rotationController]),
      builder: (context, child) {
        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              ...List.generate(2, (ringIndex) {
                final ringSize = scannerSize * (1.0 + ringIndex * 0.5);
                final opacity = _opacityAnimation.value * (0.5 - ringIndex * 0.15);

                return Positioned(
                  left: scannerCenterX - ringSize / 2,
                  top: scannerCenterY - ringSize / 2,
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: _pulseAnimation.value * (1.0 + ringIndex * 0.1),
                      child: Container(
                        width: ringSize,
                        height: ringSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0 + ringIndex,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),

              Positioned(
                left: scannerCenterX - scannerSize * 0.75,
                top: scannerCenterY - scannerSize * 0.75,
                child: Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: CustomPaint(
                    size: Size(scannerSize * 1.5, scannerSize * 1.5),
                    painter: ScanningBeamPainter(
                      progress: _rotationController.value,
                      opacity: _opacityAnimation.value * 0.6,
                    ),
                  ),
                ),
              ),

              ...List.generate(6, (index) {
                final angle = (index * 60.0) * (math.pi / 180);
                final radius = scannerSize * 0.55;
                final x = scannerCenterX + radius * math.cos(angle + _rotationAnimation.value * 0.3);
                final y = scannerCenterY + radius * math.sin(angle + _rotationAnimation.value * 0.3);

                return Positioned(
                  left: x - 5,
                  top: y - 5,
                  child: Opacity(
                    opacity: _opacityAnimation.value * 0.7,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.4),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              ...List.generate(8, (index) {
                final random = math.Random(index);
                final baseX = scannerCenterX + (random.nextDouble() - 0.5) * scannerSize * 1.2;
                final baseY = scannerCenterY + (random.nextDouble() - 0.5) * scannerSize * 1.2;
                final animationOffset = _rotationAnimation.value * (random.nextDouble() - 0.5) * 1.5;

                return Positioned(
                  left: baseX + animationOffset * 30 - 2,
                  top: baseY + math.sin(_pulseController.value * 2 * math.pi + index) * 15 - 2,
                  child: Opacity(
                    opacity: _opacityAnimation.value * 0.4,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }),

              Positioned(
                left: scannerCenterX - scannerSize * 0.7,
                top: scannerCenterY - scannerSize * 0.7,
                child: Opacity(
                  opacity: _opacityAnimation.value * 0.3,
                  child: Transform.scale(
                    scale: _pulseAnimation.value * 1.3,
                    child: Container(
                      width: scannerSize * 1.4,
                      height: scannerSize * 1.4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ScanningBeamPainter extends CustomPainter {
  final double progress;
  final double opacity;

  ScanningBeamPainter({required this.progress, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i < 4; i++) {
      final angle = (i * 90 + progress * 360) * (3.14159 / 180);
      final startAngle = angle - 0.3;
      final sweepAngle = 0.6;

      paint.shader = ui.Gradient.sweep(
        center,
        [
          Colors.transparent,
          Colors.white.withOpacity(opacity * 0.2),
          Colors.white.withOpacity(opacity * 0.5),
          Colors.white.withOpacity(opacity * 0.7),
          Colors.white.withOpacity(opacity * 0.5),
          Colors.white.withOpacity(opacity * 0.2),
          Colors.transparent,
        ],
        [0.0, 0.1, 0.3, 0.5, 0.7, 0.9, 1.0],
        TileMode.clamp,
        startAngle,
        startAngle + sweepAngle,
      );

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.4),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }

    for (int ring = 1; ring <= 2; ring++) {
      final ringRadius = radius * (0.2 + ring * 0.2);
      final ringAngle = (progress * 120 + ring * 45) * (3.14159 / 180);

      paint.shader = ui.Gradient.sweep(
        center,
        [
          Colors.transparent,
          Colors.white.withOpacity(opacity * 0.3),
          Colors.transparent,
        ],
        [0.0, 0.5, 1.0],
        TileMode.clamp,
        ringAngle - 0.4,
        ringAngle + 0.4,
      );

      canvas.drawCircle(center, ringRadius, paint..strokeWidth = 1.5);
    }
  }

  @override
  bool shouldRepaint(ScanningBeamPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.opacity != opacity;
  }
}

class ModernQRScanner extends StatefulWidget {
  final Function(BarcodeCapture) onQRDetected;

  const ModernQRScanner({super.key, required this.onQRDetected});

  @override
  State<ModernQRScanner> createState() => _ModernQRScannerState();
}

class _ModernQRScannerState extends State<ModernQRScanner> {
  MobileScannerController cameraController = MobileScannerController();

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Widget _buildModernCorner(bool isTop, bool isLeft) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: isLeft ? Colors.white : Colors.transparent,
            width: 4,
          ),
          top: BorderSide(
            color: isTop ? Colors.white : Colors.transparent,
            width: 4,
          ),
          right: BorderSide(
            color: !isLeft ? Colors.white : Colors.transparent,
            width: 4,
          ),
          bottom: BorderSide(
            color: !isTop ? Colors.white : Colors.transparent,
            width: 4,
          ),
        ),
        borderRadius: BorderRadius.only(
          topLeft: isTop && isLeft ? const Radius.circular(8) : Radius.zero,
          topRight: isTop && !isLeft ? const Radius.circular(8) : Radius.zero,
          bottomLeft: !isTop && isLeft ? const Radius.circular(8) : Radius.zero,
          bottomRight: !isTop && !isLeft ? const Radius.circular(8) : Radius.zero,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: cameraController,
          onDetect: widget.onQRDetected,
        ),

        Positioned(top: 24, left: 24, child: _buildModernCorner(true, true)),
        Positioned(top: 24, right: 24, child: _buildModernCorner(true, false)),
        Positioned(bottom: 24, left: 24, child: _buildModernCorner(false, true)),
        Positioned(bottom: 24, right: 24, child: _buildModernCorner(false, false)),

        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.8),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Add the HeaderClipper class (copy from profile page)
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