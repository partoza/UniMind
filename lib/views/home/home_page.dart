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

  // Add filter state here
  Map<String, dynamic> _currentFilters = {
    'gender': null,
    'department': null,
    'yearRange': const RangeValues(1, 4),
  };

  @override
  void initState() {
    super.initState();

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
        actions: [_actionForCurrentPage(context)],
      ),

      // Build body dynamically based on current index with loading overlay
      body: Stack(
        children: [
          _buildCurrentPage(),
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

  Widget _buildLoadingState() {
    return Positioned.fill(
      child: Container(
        color: _getBackgroundColorForTab(
          _targetIndex,
        ), // Match actual page background
        child: _getSkeletonForTab(_targetIndex),
      ),
    );
  }

  Widget _buildInitialLoadingState() {
    return Positioned.fill(
      child: Container(
        color: const Color(0xFFF6F6F6), // Match actual home page background
        child: _getSkeletonForTab(0), // Show home skeleton for initial load
      ),
    );
  }

  Color _getBackgroundColorForTab(int tabIndex) {
    switch (tabIndex) {
      case 0: // Home
        return const Color(0xFFF6F6F6);
      case 1: // Follow
        return Colors.white;
      case 2: // Discover
        return Colors.white;
      case 3: // Chat
        return Colors.white;
      case 4: // Profile
        return Colors.white;
      default:
        return Colors.white;
    }
  }

  Widget _getSkeletonForTab(int tabIndex) {
    final textScale = MediaQuery.of(context).textScaleFactor;

    switch (tabIndex) {
      case 0: // Home - study partner cards with header
        return Column(
          children: [
            // Study partner cards with shimmer - matches SuggestedCard structure
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: 5, // +1 for header
                itemBuilder: (context, index) {
                  // First item is the header
                  if (index == 0) {
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
                          // No filter button in header - it's in the app bar
                        ],
                      ),
                    );
                  }

                  // Subtract 1 from index since first item is header
                  final cardIndex = index - 1;
                  final screenWidth = MediaQuery.of(context).size.width;
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 2,
                    ),
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
                        // Top section with image and basic info - matches SuggestedCard
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
                              // Background image skeleton
                              ShimmerEffect(
                                isLoading: true,
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  decoration: const BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                              // Name and course info skeleton
                              Positioned(
                                bottom: 20,
                                left: 20,
                                right: 60,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ShimmerEffect(
                                      isLoading: true,
                                      child: Container(
                                        height: 18,
                                        width: 150,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    ShimmerEffect(
                                      isLoading: true,
                                      child: Container(
                                        height: 13,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(
                                            4,
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
                        // Bottom section with skills and actions - matches SuggestedCard
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Good In section
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
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: List.generate(3, (i) {
                                  return ShimmerEffect(
                                    isLoading: true,
                                    child: Container(
                                      height: 28,
                                      width: 60 + (i * 10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 16),
                              // Need Improvements section
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
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: List.generate(2, (i) {
                                  return ShimmerEffect(
                                    isLoading: true,
                                    child: Container(
                                      height: 28,
                                      width: 70 + (i * 15),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 16),
                              // Bio section
                              ShimmerEffect(
                                isLoading: true,
                                child: Container(
                                  height: 14,
                                  width: 50,
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
                                  height: 40,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Follow button
                              Align(
                                alignment: Alignment.centerRight,
                                child: ShimmerEffect(
                                  isLoading: true,
                                  child: Container(
                                    height: 40,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      case 1: // Follow - skeleton loading
        return const SizedBox.shrink(); // No loading for follow page
      case 2: // Discover - skeleton loading
        return const SizedBox.shrink(); // No loading for discover page
      case 3: // Chat - skeleton loading
        return Padding(
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
                      fontSize: 28 * textScale,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFB41214),
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Chat with your connections",
                    style: GoogleFonts.montserrat(
                      fontSize: 14 * textScale,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Search Bar - actual functional search bar
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

              // Connections Horizontal List - skeleton loading with shimmer
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
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
                                color: Colors.grey[300],
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          ShimmerEffect(
                            isLoading: true,
                            child: Container(
                              width: 40,
                              height: 12,
                              color: Colors.grey[300],
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recent Message",
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D2D2D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Chat List - skeleton loading with shimmer
              Expanded(
                child: ListView.builder(
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            ShimmerEffect(
                              isLoading: true,
                              child: CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.grey[300],
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
                                      width: 120,
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
                                      height: 14,
                                      width: 200,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      case 4: // Profile - skeleton loading
        return SingleChildScrollView(
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
                      // "My Profile" title - skeleton with shimmer
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
                          // Profile picture skeleton with shimmer
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
                                // Name skeleton with shimmer
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
                                // Year skeleton with shimmer
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
                                // Edit button skeleton with shimmer
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
                          // Gender skeleton with shimmer
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
                          // Building skeleton with shimmer
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
                    // College Department skeleton with shimmer
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
                    // Bio skeleton with shimmer
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
                    // Top Skills skeleton with shimmer
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
                    // Areas for Improvement skeleton with shimmer
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
                    // Logout button skeleton with shimmer
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
        );
      default:
        return const SizedBox.shrink();
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
          icon: const Icon(Icons.qr_code, color: Colors.black, size: 30),
          onPressed: () {
            final currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QrScannerPage(
                    source: currentUser.uid,
                  ), // Pass actual user ID
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
      case 4: // Profile - QR icon (source: profile)
        return IconButton(
          icon: const Icon(Icons.qr_code, color: Colors.black, size: 30),
          onPressed: () {
            final currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QrScannerPage(
                    source: currentUser.uid,
                  ), // Pass actual user ID
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

  const _HomeContent({required this.filters, required this.onClearFilters});

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  /// Helper function to get ordinal suffix (1st, 2nd, 3rd, 4th)
  String _getOrdinalSuffix(int number) {
    if (number >= 11 && number <= 13) {
      return 'th';
    }
    switch (number % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  /// Filter users based on current filter settings
  List<QueryDocumentSnapshot> _filterUsers(
    List<QueryDocumentSnapshot> docs,
    String currentUid,
  ) {
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
          case 'CAE':
            userDepartmentDisplay = 'College of Accounting Education';
            break;
          case 'CAFAE':
            userDepartmentDisplay =
                'College of Architecture and Fine Arts Education';
            break;
          case 'CBAE':
            userDepartmentDisplay =
                'College of Business Administration Education';
            break;
          case 'CHE':
            userDepartmentDisplay = 'College of Hospitality Education';
            break;
          case 'CCJE':
            userDepartmentDisplay = 'College of Criminal Justice Education';
            break;
          case 'CAS':
            userDepartmentDisplay = 'College of Arts and Sciences';
            break;
          case 'CHSE':
            userDepartmentDisplay = 'College of Health and Sciences Education';
            break;
          case 'CTE':
            userDepartmentDisplay = 'College of Teachers Education';
            break;
          default:
            userDepartmentDisplay = userDepartment;
            break;
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
        if (userYearLevel.contains('1') || userYearLevel.contains('1st'))
          yearLevel = 1;
        else if (userYearLevel.contains('2') || userYearLevel.contains('2nd'))
          yearLevel = 2;
        else if (userYearLevel.contains('3') || userYearLevel.contains('3rd'))
          yearLevel = 3;
        else if (userYearLevel.contains('4') || userYearLevel.contains('4th'))
          yearLevel = 4;
        else
          yearLevel = 1; // default
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
          return const SizedBox.shrink(); // Remove Firebase loading indicator
        }

        final docs = snapshot.data?.docs ?? [];
        final filteredDocs = _filterUsers(docs, currentUid!);

        // Show active filters
        final hasActiveFilters =
            widget.filters['gender'] != null ||
            widget.filters['department'] != null ||
            (widget.filters['yearRange'] as RangeValues).start > 1 ||
            (widget.filters['yearRange'] as RangeValues).end < 4;

        if (filteredDocs.isEmpty) {
          return Column(
            children: [
              if (hasActiveFilters)
                Expanded(
                  child: Center(
                    child: Padding(
                      // Added padding for better spacing from edges
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Replaced Icon with an Image
                          Image.asset(
                            'assets/illustrations/crying_boy.png', // <-- Make sure you have this image in your assets
                            width: 200, // Adjust size as needed
                            height: 200,
                            fit: BoxFit.contain,
                          ), // Increased spacing for better visual separation
                          Text(
                            hasActiveFilters
                                ? "Oops!\nNo results found for your filters."
                                : "No users found yet.", // Slightly softer message
                            textAlign: TextAlign.center, // Center-align text
                            style: GoogleFonts.montserrat(
                              fontSize: 16, // Slightly larger font size
                              fontWeight: FontWeight.w600, // Slightly bolder
                              color: Colors
                                  .grey
                                  .shade700, // Darker grey for better readability
                            ),
                          ),
                          const SizedBox(
                            height: 2,
                          ), // Added a small space for a sub-message
                          Text(
                            hasActiveFilters
                                ? "Try adjusting your filters or clearing them to see more."
                                : "It looks like there are no users to display.", // Helper text
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(
                            height: 24,
                          ), // Increased spacing before the button

                          if (hasActiveFilters)
                            ElevatedButton.icon(
                              // Changed to ElevatedButton.icon for a modern look
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.white,
                                size: 20,
                              ), // Added a relevant icon
                              label: Text(
                                "Clear Filters",
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              onPressed: widget.onClearFilters,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFFB41214,
                                ), // Original background color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    12,
                                  ), // Slightly rounded corners for the button
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28, // Increased padding
                                  vertical: 14, // Increased padding
                                ),
                                elevation: 4, // Added a subtle shadow for depth
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            final data =
                filteredDocs[docIndex].data() as Map<String, dynamic>? ?? {};
            final docUid = data['uid'] as String? ?? filteredDocs[docIndex].id;
            final displayName = data['displayName'] as String? ?? "Unknown";
            final yearLevel = data['yearLevel'];
            final program = data['program'] as String? ?? "";
            final department = data['department'] as String? ?? "";
            final abbreviatedProgram = data['programAcronym'] as String? ?? "";
            // Format year level properly
            String formattedYearLevel = "";
            if (yearLevel != null) {
              if (yearLevel is int) {
                formattedYearLevel =
                    "${yearLevel}${_getOrdinalSuffix(yearLevel)} Year";
              } else if (yearLevel is String) {
                // If it's already a string, use it as is
                formattedYearLevel = yearLevel;
              }
            }

            final nameAndCourse =
                "$formattedYearLevel${abbreviatedProgram.isNotEmpty ? ', $abbreviatedProgram' : ''}";
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
            final location = data['place'] as String? ?? "Campus";

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
    // UNFOLLOW
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

      // Update counts
      batch.update(currentUserRef, {
        'followingCount': FieldValue.increment(-1),
      });
      batch.update(targetUserRef, {
        'followerCount': FieldValue.increment(-1),
      });

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

    // CANCEL SENT REQUEST
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

    // ACCEPT INCOMING REQUEST OR FOLLOW
    final batch = FirebaseFirestore.instance.batch();

    // Delete ALL pending requests between these users in both directions
    final pendingRequests = await followRequestsRef
        .where('fromUid', whereIn: [currentUid, widget.uid])
        .where('toUid', whereIn: [currentUid, widget.uid])
        .where('status', isEqualTo: 'pending')
        .get();

    for (var d in pendingRequests.docs) {
      batch.delete(d.reference);
    }

    // When accepting an incoming request
    if (isPendingReceived) {
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

      batch.set(myFollowerDoc, {'timestamp': FieldValue.serverTimestamp()});
      batch.set(myFollowingDoc, {'timestamp': FieldValue.serverTimestamp()});
      batch.set(theirFollowerDoc, {'timestamp': FieldValue.serverTimestamp()});
      batch.set(theirFollowingDoc, {'timestamp': FieldValue.serverTimestamp()});

      // Update counts
      batch.update(currentUserRef, {
        'followingCount': FieldValue.increment(1),
        'followerCount': FieldValue.increment(1),
      });
      batch.update(targetUserRef, {
        'followingCount': FieldValue.increment(1),
        'followerCount': FieldValue.increment(1),
      });

      await batch.commit();
      return;
    }

    // Fresh follow - check if mutual follow should happen
    final otherFollowsMeSnap = await targetUserRef
        .collection('following')
        .doc(currentUid)
        .get();
    
    if (otherFollowsMeSnap.exists || isFollowingMe) {
      // Mutual follow - create follow relationship directly
      final myFollowingDoc = currentUserRef
          .collection('following')
          .doc(widget.uid);
      final theirFollowerDoc = targetUserRef
          .collection('followers')
          .doc(currentUid);

      batch.set(myFollowingDoc, {'timestamp': FieldValue.serverTimestamp()});
      batch.set(theirFollowerDoc, {'timestamp': FieldValue.serverTimestamp()});

      // Update counts
      batch.update(currentUserRef, {
        'followingCount': FieldValue.increment(1),
      });
      batch.update(targetUserRef, {
        'followerCount': FieldValue.increment(1),
      });

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
                            .map(
                              (skill) =>
                                  _buildModernChip(skill, true, textScale),
                            )
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
                            .map(
                              (skill) =>
                                  _buildModernChip(skill, false, textScale),
                            )
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
                                  Icons.apartment,
                                  size: 25,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Meet me at\n${widget.location}", // \n forces a line break before the location
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12 * textScale,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                  softWrap: true, // allows text to wrap
                                  overflow: TextOverflow
                                      .visible, // ensures it's not cut off
                                  textAlign: TextAlign.start, // aligns neatly
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
      'color': Color(0xFFF6FF00),
      'logoPath': 'assets/depLogo/ccelogo.png',
      'name': 'Computing Education',
    },
    'CASE': {
      'color': Color(0xFF388E3C),
      'logoPath': 'assets/depLogo/caselogo.png',
      'name': 'Arts & Science',
    },
    'CEE': {
      'color': Color(0xFFFF9D00),
      'logoPath': 'assets/depLogo/ceelogo.png',
      'name': 'Engineering',
    },
    'CAE': {
      'color': Color(0xFF30E8FD),
      'logoPath': 'assets/depLogo/caelogo.png',
      'name': 'Architecture',
    },
    'CAFAE': {
      'color': Color(0xFF6D6D6D),
      'logoPath': 'assets/depLogo/cafaelogo.png',
      'name': 'Agriculture',
    },
    'CBAE': {
      'color': Color(0xFFFFDD00),
      'logoPath': 'assets/depLogo/cbaelogo.png',
      'name': 'Business',
    },
    'CHE': {
      'color': Color(0xFFAA00FF),
      'logoPath': 'assets/depLogo/chelogo.png',
      'name': 'Health',
    },
    'CCJE': {
      'color': Color(0xFFFF3700),
      'logoPath': 'assets/depLogo/ccjelogo.png',
      'name': 'Criminal Justice',
    },
    'CHSE': {
      'color': Color(0xFF75B8FF),
      'logoPath': 'assets/depLogo/chselogo.png',
      'name': 'Home Science',
    },
    'CTE': {
      'color': Color(0xFF1E05FF),
      'logoPath': 'assets/depLogo/ctelogo.png',
      'name': 'Teacher Education',
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
                child: Image.asset(logoPath, fit: BoxFit.contain),
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

  const DepartmentBadgeWidget({super.key, required this.department});

  // Department configurations
  static const Map<String, Map<String, dynamic>> departmentConfig = {
    'CCE': {
      'color': Color(0xFFF6FF00),
      'logoPath': 'assets/depLogo/ccelogo.png',
      'name': 'College of Computing Education',
    },
    'CAS': {
      'color': Color(0xFF388E3C),
      'logoPath': 'assets/depLogo/caslogo.png',
      'name': 'College of Arts and Sciences',
    },
    'CEE': {
      'color': Color(0xFFFF9D00),
      'logoPath': 'assets/depLogo/ceelogo.png',
      'name': 'College of Engineering Education',
    },
    'CAE': {
      'color': Color(0xFF30E8FD),
      'logoPath': 'assets/depLogo/caelogo.png',
      'name': 'College of Accounting Education',
    },
    'CAFAE': {
      'color': Color(0xFF6D6D6D),
      'logoPath': 'assets/depLogo/cafaelogo.png',
      'name': 'College of Architecture and Fine Arts Education',
    },
    'CBAE': {
      'color': Color(0xFFFFDD00),
      'logoPath': 'assets/depLogo/cbaelogo.png',
      'name': 'College of Business Administration Education',
    },
    'CHE': {
      'color': Color(0xFFAA00FF),
      'logoPath': 'assets/depLogo/chelogo.png',
      'name': 'College of Hospitality Education',
    },
    'CCJE': {
      'color': Color(0xFFFF3700),
      'logoPath': 'assets/depLogo/ccjelogo.png',
      'name': 'College of Criminal Justice Education',
    },
    'CASE': {
      'color': Color(0xFF299504),
      'logoPath': 'assets/depLogo/caselogo.png',
      'name': 'College of Arts and Sciences Education',
    },
    'CHSE': {
      'color': Color(0xFF75B8FF),
      'logoPath': 'assets/depLogo/chselogo.png',
      'name': 'College of Health and Sciences Education',
    },
    'CTE': {
      'color': Color(0xFF1E05FF),
      'logoPath': 'assets/depLogo/ctelogo.png',
      'name': 'College of Teacher Education',
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
        child: Image.asset(logoPath, fit: BoxFit.contain),
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
