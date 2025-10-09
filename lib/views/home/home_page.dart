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
import 'package:unimind/widgets/loading_widget.dart';


class HomePage extends StatefulWidget {

  const HomePage({super.key});
  
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool _isNavigating = false;
  String _loadingMessage = "";
  int _targetIndex = 0;
  bool _isInitialLoading = true;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // Define all pages
    _pages = [
      const _HomeContent(),
      const FollowPage(),
      DiscoverPage(onQRDetected: () { print("object"); }, onUploadImage: () { print("object"); },),
      const ChatPage(),
      const ProfilePage(),
    ];

    // Add initial loading delay
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
        });
      }
    });
  }

  void _handleTabNavigation(int index) {
    if (_isNavigating) return;
    
    setState(() {
      _isNavigating = true;
      _targetIndex = index;
      _loadingMessage = _getLoadingMessage(index);
    });

    // Skip delay for discover and follow pages - show immediately
    if (index == 1 || index == 2) {
      setState(() {
        _currentIndex = index;
        _isNavigating = false;
      });
    } else {
      // Simulate loading time for other pages
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _currentIndex = index;
            _isNavigating = false;
          });
        }
      });
    }
  }

  String _getLoadingMessage(int index) {
    switch (index) {
      case 0:
        return "Loading home...";
      case 1:
        return "Loading follow requests...";
      case 2:
        return "Loading discover...";
      case 3:
        return "Loading messages...";
      case 4:
        return "Loading profile...";
      default:
        return "Loading...";
    }
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
        // Right-side action changes depending on the selected page
        actions: [
          _actionForCurrentPage(context),
        ],
      ),

      // show correct page with loading overlay
      body: Stack(
        children: [
          _pages[_currentIndex],
          if (_isNavigating) _buildLoadingState(),
          if (_isInitialLoading) _buildInitialLoadingState(),
        ],
      ),

      // use custom nav bar
      bottomNavigationBar: CustomNavBar(
        currentIndex: _isNavigating ? _targetIndex : _currentIndex,
        onTap: _handleTabNavigation,
      ),
    );
  }

  Widget _buildLoadingState() {
    return Positioned.fill(
      child: Container(
        color: Colors.white,
        child: _getSkeletonForTab(_targetIndex),
      ),
    );
  }

  Widget _buildInitialLoadingState() {
    return Positioned.fill(
      child: Container(
        color: Colors.white,
        child: _getSkeletonForTab(0), // Show home skeleton for initial load
      ),
    );
  }

  Widget _getSkeletonForTab(int tabIndex) {
    final textScale = MediaQuery.of(context).textScaleFactor;
    
    switch (tabIndex) {
      case 0: // Home - study partner cards with header
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: 4, // +1 for header
          itemBuilder: (context, i) {
            // First item is the header
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Suggested for you",
                    style: GoogleFonts.montserrat(
                      fontSize: 18 * textScale,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              );
            }
            // Skeleton cards
            return const SkeletonHomeCard();
          },
        );
      case 1: // Follow - no loading state, show immediately like discover
        return const SizedBox.shrink();
      case 2: // Discover - no loading state, show immediately
        return const SizedBox.shrink();
      case 3: // Chat - with visible headers and skeleton chat list only
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header - visible immediately
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Messages",
                        style: GoogleFonts.montserrat(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFB41214),
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Chat with your connections",
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Search Bar - matches actual chat page
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Icon(
                          Icons.search,
                          color: const Color(0xFF6B7280).withOpacity(0.7),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Search a GA...",
                              hintStyle: GoogleFonts.montserrat(
                                color: const Color(0xFF6B7280).withOpacity(0.7),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                            ),
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: const Color(0xFF2D2D2D),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Connections - skeleton loading
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 70,
                          margin: const EdgeInsets.only(right: 16),
                          child: Column(
                            children: [
                              ShimmerEffect(
                                isLoading: true,
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[300],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              ShimmerEffect(
                                isLoading: true,
                                child: Container(
                                  height: 12,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Recent Messages Header - visible immediately
                  Text(
                    "Recent Message",
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Chat List skeleton - only this part has skeleton loading
                  Expanded(
                    child: ListView.separated(
                      itemCount: 5,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) => const SkeletonChatCard(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      case 4: // Profile - skeleton loading that matches actual profile page
        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Red Header with Smooth Curved Bottom - skeleton
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
                        // "My Profile" title - skeleton
                        ShimmerEffect(
                          isLoading: true,
                          child: Container(
                            height: 28,
                            width: 150,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Row: Profile Picture + Info - skeleton
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Profile picture skeleton
                            ShimmerEffect(
                              isLoading: true,
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Name skeleton
                                  ShimmerEffect(
                                    isLoading: true,
                                    child: Container(
                                      height: 18,
                                      width: 180,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Year skeleton
                                  ShimmerEffect(
                                    isLoading: true,
                                    child: Container(
                                      height: 14,
                                      width: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Edit button skeleton
                                  ShimmerEffect(
                                    isLoading: true,
                                    child: Container(
                                      height: 32,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(8),
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

                // Content skeleton
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Info Section skeleton
                      Container(
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
                            // Gender skeleton
                            Column(
                              children: [
                                ShimmerEffect(
                                  isLoading: true,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ShimmerEffect(
                                  isLoading: true,
                                  child: Container(
                                    height: 16,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ShimmerEffect(
                                  isLoading: true,
                                  child: Container(
                                    height: 12,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Building skeleton
                            Column(
                              children: [
                                ShimmerEffect(
                                  isLoading: true,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ShimmerEffect(
                                  isLoading: true,
                                  child: Container(
                                    height: 16,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ShimmerEffect(
                                  isLoading: true,
                                  child: Container(
                                    height: 12,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      // College Department skeleton
                      ShimmerEffect(
                        isLoading: true,
                        child: Container(
                          height: 14,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.grey[100],
                        ),
                        child: Row(
                          children: [
                            ShimmerEffect(
                              isLoading: true,
                              child: Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ShimmerEffect(
                                    isLoading: true,
                                    child: Container(
                                      height: 16,
                                      width: 200,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  ShimmerEffect(
                                    isLoading: true,
                                    child: Container(
                                      height: 14,
                                      width: 150,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Bio skeleton
                      ShimmerEffect(
                        isLoading: true,
                        child: Container(
                          height: 14,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ShimmerEffect(
                        isLoading: true,
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Top Skills skeleton
                      ShimmerEffect(
                        isLoading: true,
                        child: Container(
                          height: 14,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(5, (index) {
                          return ShimmerEffect(
                            isLoading: true,
                            child: Container(
                              height: 32,
                              width: 80 + (index * 10),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 15),

                      // Areas for Improvement skeleton
                      ShimmerEffect(
                        isLoading: true,
                        child: Container(
                          height: 14,
                          width: 140,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(4, (index) {
                          return ShimmerEffect(
                            isLoading: true,
                            child: Container(
                              height: 32,
                              width: 90 + (index * 15),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 40),

                      // Logout button skeleton
                      ShimmerEffect(
                        isLoading: true,
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      default:
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB41214)),
          ),
        );
    }
  }

  /// Returns the appropriate action widget for the current page index.
  Widget _actionForCurrentPage(BuildContext context) {
    // 0: Home, 1: Follow, 2: Discover, 3: Chat, 4: Profile
    switch (_currentIndex) {
      case 0: // Home - filter button
        return IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.black, size: 30,),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FilterPage()),
            );
          },
        );
      case 1: // Follow - no icon
      case 3: // Chat - no icon
        return const SizedBox.shrink();
      case 2: // Discover - QR icon (source: discover)
        return IconButton(
          icon: const Icon(Icons.qr_code, color: Colors.black, size: 30,),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const QrScannerPage(source: 'discover'),
              ),
            );
          },
        );
      case 4: // Profile - QR icon (source: profile)
        return IconButton(
          icon: const Icon(Icons.qr_code, color: Colors.black, size: 30,),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const QrScannerPage(source: 'profile'),
              ),
            );
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

/// Home content
class _HomeContent extends StatelessWidget {
  const _HomeContent();

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
      // Add more abbreviations as needed
    };
    
    return programAbbreviations[program] ?? program;
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        debugPrint('Snapshot data type: ${snapshot.data?.runtimeType}');
        debugPrint('Snapshot has error: ${snapshot.hasError}');
        if (snapshot.hasError) {
          debugPrint('Stream error: ${snapshot.error}');
          debugPrint('Error stack: ${snapshot.error}');
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final docs = snapshot.data?.docs ?? [];
        final otherDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          final docUid = data['uid'] as String? ?? doc.id;
          return docUid != currentUid;
        }).toList();

        if (otherDocs.isEmpty) {
          return const Center(child: Text("No other users found"));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          itemCount: otherDocs.length + 1, // +1 for header
          itemBuilder: (context, i) {
            // First item is the header
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Suggested for you",
                    style: GoogleFonts.montserrat(
                      fontSize: 18 * textScale,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              );
            }

            // Subtract 1 from index since first item is header
            final docIndex = i - 1;
            final data =
                otherDocs[docIndex].data() as Map<String, dynamic>? ?? {};
            final docUid = data['uid'] as String? ?? otherDocs[docIndex].id;
            final displayName =
                data['displayName'] as String? ?? "Unknown";
            final yearLevel = data['yearLevel']?.toString() ?? "";
            final program = data['program'] as String? ?? "";
            final department = data['department'] as String? ?? "";
            final abbreviatedProgram = _abbreviateProgram(program);
            final nameAndCourse =
                "$yearLevel${abbreviatedProgram.isNotEmpty ? ', $abbreviatedProgram' : ''}";
            final avatarPath =
                (data['avatarPath'] ?? data['avatar'] ?? '') as String;
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
        for (var d in sentQuery.docs) batch.delete(d.reference);
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

      for (var d in pendingA.docs) batch.delete(d.reference);
      for (var d in pendingB.docs) batch.delete(d.reference);

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
                        child: Container(
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

/// Custom clipper for smooth curved bottom (for profile skeleton)
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