import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unimind/views/nav/custom_navbar.dart';
import 'package:unimind/views/follow_request/follow_page.dart';
import 'package:unimind/views/chats/chats_page.dart';
import 'package:unimind/views/profile/profile_page.dart';
import 'package:unimind/views/discover/discover_page.dart';
import 'package:unimind/views/profile/qr_scanner_page.dart';
import 'package:unimind/views/home/filter_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  
  // Add filter state here
  Map<String, dynamic> _currentFilters = {
    'gender': null,
    'department': null,
    'yearRange': const RangeValues(1, 4),
  };

  // Method to clear all filters
  void _clearFilters() {
    setState(() {
      _currentFilters = {
        'gender': null,
        'department': null,
        'yearRange': const RangeValues(1, 4),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              "assets/icon/logoIconMaroon.png",
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "U",
                    style: GoogleFonts.montserrat(
                      color: const Color(0xFFB41214),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: "ni",
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: "M",
                    style: GoogleFonts.montserrat(
                      color: const Color(0xFFB41214),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: "ind",
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          _actionForCurrentPage(context),
        ],
      ),

      // Build body dynamically based on current index
      body: _buildCurrentPage(),

      // use custom nav bar
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return _HomeContent(
          filters: _currentFilters,
          onClearFilters: _clearFilters, // Pass the clear function
        );
      case 1:
        return const FollowPage();
      case 2:
        return const DiscoverPage();
      case 3:
        return const ChatPage();
      case 4:
        return const ProfilePage();
      default:
        return const SizedBox();
    }
  }

  /// Returns the appropriate action widget for the current page index.
  Widget _actionForCurrentPage(BuildContext context) {
    switch (_currentIndex) {
      case 0: // Home - filter button
        return IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.filter_list, color: Colors.black, size: 30),
              // Show indicator dot when filters are active
              if (_hasActiveFilters())
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB41214),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () async {
            // Wait for filter result
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FilterPage(initialFilters: _currentFilters),
              ),
            );
            
            // If we got new filters, update the state
            if (result != null) {
              setState(() {
                _currentFilters = result;
              });
            }
          },
        );
      case 1: // Follow - no icon
      case 3: // Chat - no icon
        return const SizedBox.shrink();
      case 2: // Discover - QR icon (source: discover)
  return IconButton(
    icon: const Icon(Icons.qr_code, color: Colors.black, size: 30,),
    onPressed: () {
      // This should navigate to the DiscoverPage (scanner), not QrScannerPage (QR display)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const DiscoverPage(), // Change to DiscoverPage
        ),
      );
    },
  );
case 4: // Profile - QR icon (source: profile)
  return IconButton(
    icon: const Icon(Icons.qr_code, color: Colors.black, size: 30,),
    onPressed: () {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QrScannerPage(source: currentUser.uid), // Pass actual user ID
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please log in to view QR code'),
            backgroundColor: Colors.red,
          ),
        );
      }
    },
  );
      default:
        return const SizedBox.shrink();
    }
  }

  bool _hasActiveFilters() {
    return _currentFilters['gender'] != null || 
           _currentFilters['department'] != null || 
           (_currentFilters['yearRange'] as RangeValues).start > 1 || 
           (_currentFilters['yearRange'] as RangeValues).end < 4;
  }
}

/// Home content - Update to accept filters and clear callback
class _HomeContent extends StatefulWidget {
  final Map<String, dynamic> filters;
  final VoidCallback onClearFilters;

  const _HomeContent({
    required this.filters,
    required this.onClearFilters,
  });

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  /// Helper function to abbreviate program names
  String _abbreviateProgram(String program) {
    final programAbbreviations = {
      'Bachelor of Science in Information Technology': 'BSIT',
      'Bachelor of Science in Computer Science': 'BSCS',
      'Bachelor of Science in Multimedia Arts': 'BSMA',
      'Bachelor of Science in Computer Engineering': 'BSCpE',
      'Bachelor of Science in Electronics Engineering': 'BSEE',
      'Bachelor of Science in Civil Engineering': 'BSCE',
      'Bachelor of Science in Mechanical Engineering': 'BSME',
      'Bachelor of Arts in English': 'BA English',
      'Bachelor of Science in Mathematics': 'BS Math',
      'Bachelor of Science in Psychology': 'BS Psych',
      'Bachelor of Arts in Communication': 'BA Comm',
    };
    
    return programAbbreviations[program] ?? program;
  }

  /// Filter users based on current filter settings
  List<QueryDocumentSnapshot> _filterUsers(List<QueryDocumentSnapshot> docs, String currentUid) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final docUid = data['uid'] as String? ?? doc.id;
      
      // Exclude current user
      if (docUid == currentUid) return false;

      // Apply gender filter
      if (widget.filters['gender'] != null) {
        final userGender = data['gender'] as String? ?? '';
        if (userGender != widget.filters['gender']) {
          return false;
        }
      }

      // Apply department filter
      if (widget.filters['department'] != null) {
        final userDepartment = data['department'] as String? ?? '';
        final filterDepartment = widget.filters['department'] as String;
        
        // Map display names to abbreviations for comparison
        String userDepartmentDisplay;
        switch (userDepartment) {
          case 'CCE':
            userDepartmentDisplay = 'College of Computing Education';
            break;
          case 'CEE':
            userDepartmentDisplay = 'College of Engineering Education';
            break;
          case 'CASE':
            userDepartmentDisplay = 'College of Arts and Sciences Education';
            break;
          default:
            userDepartmentDisplay = userDepartment;
        }
        
        if (userDepartmentDisplay != filterDepartment) {
          return false;
        }
      }

      // Apply year level filter
      final yearRange = widget.filters['yearRange'] as RangeValues;
      final userYearLevel = data['yearLevel'];
      
      int yearLevel;
      if (userYearLevel is int) {
        yearLevel = userYearLevel;
      } else if (userYearLevel is String) {
        // Handle string year levels
        if (userYearLevel.contains('1') || userYearLevel.contains('1st')) yearLevel = 1;
        else if (userYearLevel.contains('2') || userYearLevel.contains('2nd')) yearLevel = 2;
        else if (userYearLevel.contains('3') || userYearLevel.contains('3rd')) yearLevel = 3;
        else if (userYearLevel.contains('4') || userYearLevel.contains('4th')) yearLevel = 4;
        else yearLevel = 1; // default
      } else {
        yearLevel = 1; // default
      }

      if (yearLevel < yearRange.start || yearLevel > yearRange.end) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFB41214)),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        final filteredDocs = _filterUsers(docs, currentUid!);

        // Show active filters
        final hasActiveFilters = widget.filters['gender'] != null || 
                                widget.filters['department'] != null || 
                                (widget.filters['yearRange'] as RangeValues).start > 1 || 
                                (widget.filters['yearRange'] as RangeValues).end < 4;

        if (filteredDocs.isEmpty) {
          return Column(
            children: [
              if (hasActiveFilters) 
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "No users match your current filters",
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        hasActiveFilters ? "No users match your filters" : "No users found",
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (hasActiveFilters)
                        ElevatedButton(
                          onPressed: widget.onClearFilters, // Use the callback here
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB41214),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: Text(
                            "Clear Filters",
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          itemCount: filteredDocs.length + 1,
          itemBuilder: (context, i) {
            // First item is the header
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Suggested for you",
                      style: GoogleFonts.montserrat(
                        fontSize: 18 * textScale,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (hasActiveFilters)
                      Text(
                        "${filteredDocs.length} results",
                        style: GoogleFonts.montserrat(
                          fontSize: 12 * textScale,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              );
            }

            // Subtract 1 from index since first item is header
            final docIndex = i - 1;
            final data = filteredDocs[docIndex].data() as Map<String, dynamic>? ?? {};
            final docUid = data['uid'] as String? ?? filteredDocs[docIndex].id;
            final displayName = data['displayName'] as String? ?? "Unknown";
            final yearLevel = data['yearLevel']?.toString() ?? "";
            final program = data['program'] as String? ?? "";
            final department = data['department'] as String? ?? "";
            final abbreviatedProgram = _abbreviateProgram(program);
            final nameAndCourse = "$yearLevel${abbreviatedProgram.isNotEmpty ? ', $abbreviatedProgram' : ''}";
            final avatarPath = (data['avatarPath'] ?? data['avatar'] ?? '') as String;
            final strengths = (data['strengths'] is List)
                ? List<String>.from(
                    (data['strengths'] as List).map((e) => e.toString()),
                  )
                : <String>[];
            final weaknesses = (data['weaknesses'] is List)
                ? List<String>.from(
                    (data['weaknesses'] as List).map((e) => e.toString()),
                  )
                : <String>[];
            final bio = data['bio'] as String? ?? "";
            final location = data['location'] as String? ?? "Campus";

            return SuggestedCard(
              uid: docUid,
              name: displayName,
              yearCourse: nameAndCourse,
              imagePath: avatarPath,
              department: department,
              goodIn: strengths,
              needImprovements: weaknesses,
              bio: bio,
              location: location,
            );
          },
        );
      },
    );
  }
}

/* --------------------------
   SuggestedCard (keeps your design)
   Converted to Stateful so Follow toggles locally
   Supports network images and local assets
   -------------------------- */
class SuggestedCard extends StatefulWidget {
  final String uid;
  final String name;
  final String yearCourse;
  final String imagePath;
  final String department;
  final List<String> goodIn;
  final List<String> needImprovements;
  final String bio;
  final String location;

  const SuggestedCard({
    super.key,
    required this.uid,
    required this.name,
    required this.yearCourse,
    required this.imagePath,
    required this.department,
    required this.goodIn,
    required this.needImprovements,
    required this.bio,
    required this.location,
  });

  @override
  State<SuggestedCard> createState() => _SuggestedCardState();
}

class _SuggestedCardState extends State<SuggestedCard> {
  bool _isLoading = false;
  late final String currentUid;

  @override
  void initState() {
    super.initState();
    currentUid = FirebaseAuth.instance.currentUser!.uid;
  }

  Stream<DocumentSnapshot> followingStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid)
        .collection('following')
        .doc(widget.uid)
        .snapshots();
  }

  Stream<DocumentSnapshot> followerStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid)
        .collection('followers')
        .doc(widget.uid)
        .snapshots();
  }

  Stream<QuerySnapshot> sentRequestStream() {
    return FirebaseFirestore.instance
        .collection('followRequests')
        .where('fromUid', isEqualTo: currentUid)
        .where('toUid', isEqualTo: widget.uid)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  Stream<QuerySnapshot> receivedRequestStream() {
    return FirebaseFirestore.instance
        .collection('followRequests')
        .where('fromUid', isEqualTo: widget.uid)
        .where('toUid', isEqualTo: currentUid)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  Future<void> _toggleFollow({
    required bool isFollowing,
    required bool isPendingSent,
    required bool isPendingReceived,
    required bool isFollowingMe,
  }) async {
    if (_isLoading) return; // Prevent multiple taps

    setState(() => _isLoading = true);

    final currentUserRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid);
    final targetUserRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid);
    final followRequestsRef = FirebaseFirestore.instance.collection(
      'followRequests',
    );

    try {
      //  UNFOLLOW
      if (isFollowing) {
        final batch = FirebaseFirestore.instance.batch();
        final myFollowingDoc = currentUserRef
            .collection('following')
            .doc(widget.uid);
        final theirFollowerDoc = targetUserRef
            .collection('followers')
            .doc(currentUid);

        batch.delete(myFollowingDoc);
        batch.delete(theirFollowerDoc);

        await batch.commit();

        // If the other still follows, create a pending request
        final otherFollowsMe = await targetUserRef
            .collection('following')
            .doc(currentUid)
            .get();
        if (otherFollowsMe.exists) {
          await followRequestsRef.add({
            'fromUid': widget.uid,
            'toUid': currentUid,
            'status': 'pending',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        return;
      }

      // 2) CANCEL SENT REQUEST
      if (isPendingSent) {
        final sentQuery = await followRequestsRef
            .where('fromUid', isEqualTo: currentUid)
            .where('toUid', isEqualTo: widget.uid)
            .where('status', isEqualTo: 'pending')
            .get();

        final batch = FirebaseFirestore.instance.batch();
        for (var d in sentQuery.docs) {
          batch.delete(d.reference);
        }
        await batch.commit();
        return;
      }

      // 3) FOLLOW OR ACCEPT INCOMING REQUEST
      final batch = FirebaseFirestore.instance.batch();

      // Delete pending requests in both directions
      final pendingA = await followRequestsRef
          .where('fromUid', isEqualTo: currentUid)
          .where('toUid', isEqualTo: widget.uid)
          .where('status', isEqualTo: 'pending')
          .get();

      final pendingB = await followRequestsRef
          .where('fromUid', isEqualTo: widget.uid)
          .where('toUid', isEqualTo: currentUid)
          .where('status', isEqualTo: 'pending')
          .get();

      for (var d in pendingA.docs) {
        batch.delete(d.reference);
      }
      for (var d in pendingB.docs) {
        batch.delete(d.reference);
      }

      // When accepting an incoming request
      if (isPendingReceived) {
        final batch = FirebaseFirestore.instance.batch();
        final myFollowerDoc = currentUserRef
            .collection('followers')
            .doc(widget.uid);
        final myFollowingDoc = currentUserRef
            .collection('following')
            .doc(widget.uid);
        final theirFollowerDoc = targetUserRef
            .collection('followers')
            .doc(currentUid);
        final theirFollowingDoc = targetUserRef
            .collection('following')
            .doc(currentUid);

        batch.set(myFollowerDoc, <String, dynamic>{});
        batch.set(myFollowingDoc, <String, dynamic>{});
        batch.set(theirFollowerDoc, <String, dynamic>{});
        batch.set(theirFollowingDoc, <String, dynamic>{});
        await batch.commit();
        return;
      }

      // Fresh follow - check if mutual follow should happen
      final otherFollowsMeSnap = await targetUserRef
          .collection('following')
          .doc(currentUid)
          .get();
      if (otherFollowsMeSnap.exists || isFollowingMe) {
        final batch = FirebaseFirestore.instance.batch();
        final myFollowingDoc = currentUserRef
            .collection('following')
            .doc(widget.uid);
        final theirFollowerDoc = targetUserRef
            .collection('followers')
            .doc(currentUid);

        batch.set(myFollowingDoc, <String, dynamic>{});
        batch.set(theirFollowerDoc, <String, dynamic>{});
        await batch.commit();
        return;
      }

      // Otherwise, create a follow request
      await followRequestsRef.add({
        'fromUid': currentUid,
        'toUid': widget.uid,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error in _toggleFollow: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildModernChip(String label, bool isGood, double textScale) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isGood ? const Color(0xFFB41214) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: isGood ? null : Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 11 * textScale,
          fontWeight: FontWeight.w500,
          color: isGood ? Colors.white : Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildModernFollowButton(
    String buttonLabel,
    bool isFollowing,
    bool isPendingSent,
    bool isPendingReceived,
    double textScale,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isFollowing || isPendingSent || isPendingReceived
            ? Colors.grey.shade200
            : const Color(0xFFB41214),
        elevation: isFollowing || isPendingSent || isPendingReceived ? 0 : 2,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: isFollowing || isPendingSent || isPendingReceived
              ? BorderSide(color: Colors.grey.shade300, width: 1)
              : BorderSide.none,
        ),
      ),
      onPressed: _isLoading
          ? null
          : () => _toggleFollow(
              isFollowing: isFollowing,
              isPendingSent: isPendingSent,
              isPendingReceived: isPendingReceived,
              isFollowingMe: false,
            ),
      child: Text(
        buttonLabel,
        style: GoogleFonts.montserrat(
          fontSize: 13 * textScale,
          fontWeight: FontWeight.w600,
          color: isFollowing || isPendingSent || isPendingReceived
              ? Colors.grey[700]
              : Colors.white,
        ),
      ),
    );
  }

  Widget _buildImage(String path, double screenWidth) {
    if (path.isEmpty) {
      return Container(
        color: Colors.grey[300],
        width: double.infinity,
        height: double.infinity,
      );
    }
    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Container(color: Colors.grey[300]),
      );
    }
    return Image.asset(
      path,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (c, e, s) => Container(color: Colors.grey[300]),
    );
  }

  String getButtonLabel({
    required bool isFollowing,
    required bool isPendingSent,
    required bool isPendingReceived,
  }) {
    if (isFollowing) return "Following";
    if (isPendingSent) return "Pending";
    if (isPendingReceived) return "Accept";
    return "Follow";
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScale = MediaQuery.of(context).textScaleFactor;

    return StreamBuilder<DocumentSnapshot>(
      stream: followingStream(),
      builder: (context, followingSnap) {
        final isFollowing =
            followingSnap.hasData &&
            followingSnap.data != null &&
            followingSnap.data!.exists;

        return StreamBuilder<DocumentSnapshot>(
          stream: followerStream(),
          builder: (context, followerSnap) {
            final isFollowingMe =
                followerSnap.hasData &&
                followerSnap.data != null &&
                followerSnap.data!.exists;

            return StreamBuilder<QuerySnapshot>(
              stream: sentRequestStream(),
              builder: (context, sentSnap) {
                final isPendingSent =
                    sentSnap.hasData &&
                    sentSnap.data != null &&
                    sentSnap.data!.docs.isNotEmpty;

                return StreamBuilder<QuerySnapshot>(
                  stream: receivedRequestStream(),
                  builder: (context, receivedSnap) {
                    final isPendingReceived =
                        receivedSnap.hasData &&
                        receivedSnap.data != null &&
                        receivedSnap.data!.docs.isNotEmpty;

                    final buttonLabel = getButtonLabel(
                      isFollowing: isFollowing,
                      isPendingSent: isPendingSent,
                      isPendingReceived: isPendingReceived,
                    );

                    return _buildCardContent(
                      context,
                      screenWidth,
                      textScale,
                      isFollowing,
                      isPendingSent,
                      isPendingReceived,
                      isFollowingMe,
                      buttonLabel,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCardContent(
    BuildContext context,
    double screenWidth,
    double textScale,
    bool isFollowing,
    bool isPendingSent,
    bool isPendingReceived,
    bool isFollowingMe,
    String buttonLabel,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top section with image and basic info
                Container(
                  height: screenWidth * 0.5,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Background image
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: _buildImage(widget.imagePath, screenWidth),
                        ),
                      ),
                      // Gradient overlay - stronger for better text visibility
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.8),
                              Colors.black.withOpacity(0.4),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.center,
                            stops: const [0.0, 0.3, 1.0],
                          ),
                        ),
                      ),
                      // Name and course info
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 60,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.name,
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 18 * textScale,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (widget.yearCourse.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                widget.yearCourse,
                                style: GoogleFonts.montserrat(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13 * textScale,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Bottom section with skills and actions
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Good In section
                      Text(
                        "Good In",
                        style: GoogleFonts.montserrat(
                          fontSize: 14 * textScale,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: widget.goodIn
                            .map((skill) => _buildModernChip(skill, true, textScale))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      // Need Improvements section
                      Text(
                        "Need Improvements in",
                        style: GoogleFonts.montserrat(
                          fontSize: 14 * textScale,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: widget.needImprovements
                            .map((skill) => _buildModernChip(skill, false, textScale))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      // Bio section
                      Text(
                        "My Bio",
                        style: GoogleFonts.montserrat(
                          fontSize: 14 * textScale,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F6F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.bio.isEmpty ? "No bio available" : widget.bio,
                          style: GoogleFonts.montserrat(
                            fontSize: 12 * textScale,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Location and Follow button row
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Meet me at ${widget.location}",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12 * textScale,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildModernFollowButton(
                            buttonLabel,
                            isFollowing,
                            isPendingSent,
                            isPendingReceived,
                            textScale,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Department Badge - bookmark style positioned on top right
          Positioned(
            top: 0,
            right: 12,
            child: BookmarkBadgeWidget(
              department: widget.department,
              size: Size(screenWidth * 0.12, screenWidth * 0.18),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom widget for bookmark badge with department logo
class BookmarkBadgeWidget extends StatelessWidget {
  final String department;
  final Size size;
  
  const BookmarkBadgeWidget({
    super.key,
    required this.department,
    required this.size,
  });

  // Department configurations
  static const Map<String, Map<String, dynamic>> departmentConfig = {
    'CCE': {
      'color': Color(0xFFEFDD0E), // Yellow for Computing Education
      'logoPath': 'assets/ccelogo.png',
      'name': 'Computing',
    },
    'CAS': {
      'color': Color(0xFF388E3C), // Green for Arts & Science
      'logoPath': 'assets/caselogo.png',
      'name': 'Arts & Science',
    },
    'CEE': {
      'color': Color(0xFFFF9800), // Orange for Engineering
      'logoPath': 'assets/ceelogo.png',
      'name': 'Engineering',
    },
  };

  @override
  Widget build(BuildContext context) {
    // Get department config, default to CCE if not found
    final config = departmentConfig[department] ?? departmentConfig['CCE']!;
    final departmentColor = config['color'] as Color;
    final logoPath = config['logoPath'] as String;

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          // Shadow
          Positioned(
            top: 2,
            left: 2,
            child: ClipPath(
              clipper: BookmarkClipper(),
              child: Container(
                width: size.width,
                height: size.height,
                color: Colors.black.withOpacity(0.2),
              ),
            ),
          ),
          // Main bookmark
          ClipPath(
            clipper: BookmarkClipper(),
            child: Container(
              width: size.width,
              height: size.height,
              color: departmentColor,
              child: Padding(
                padding: EdgeInsets.only(
                  top: size.height * 0.12,
                  left: size.width * 0.15,
                  right: size.width * 0.15,
                  bottom: size.height * 0.35,
                ),
                child: Image.asset(
                  logoPath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple widget for department identification badge
class DepartmentBadgeWidget extends StatelessWidget {
  final String department;
  
  const DepartmentBadgeWidget({
    super.key,
    required this.department,
  });

  // Department configurations
  static const Map<String, Map<String, dynamic>> departmentConfig = {
    'CCE': {
      'color': Color(0xFFEFDD0E), // Yellow for Computing Education
      'logoPath': 'assets/ccelogo.png',
      'name': 'Computing',
    },
    'CAS': {
      'color': Color(0xFF388E3C), // Green for Arts & Science
      'logoPath': 'assets/caselogo.png',
      'name': 'Arts & Science',
    },
    'CEE': {
      'color': Color(0xFFFF9800), // Orange for Engineering
      'logoPath': 'assets/ceelogo.png',
      'name': 'Engineering',
    },
  };

  @override
  Widget build(BuildContext context) {
    // Get department config, default to CCE if not found
    final config = departmentConfig[department] ?? departmentConfig['CCE']!;
    final departmentColor = config['color'] as Color;
    final logoPath = config['logoPath'] as String;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: departmentColor,
          borderRadius: BorderRadius.circular(17),
        ),
        padding: const EdgeInsets.all(8),
        child: Image.asset(
          logoPath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

/// Custom clipper for bookmark shape (kept for backwards compatibility)
class BookmarkClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    
    // Create bookmark shape
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - 6);
    path.lineTo(size.width * 0.5, size.height * 0.68);
    path.lineTo(0, size.height - 6);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
