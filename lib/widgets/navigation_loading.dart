import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unimind/widgets/loading_widget.dart';

class NavigationLoading {
  /// Builds a loading overlay that covers the entire screen
  static Widget buildLoadingState({
    required BuildContext context,
    required int targetIndex,
    required String loadingMessage,
  }) {
    return Positioned.fill(
      child: Container(
        color: Colors.white,
        child: Material(
          color: Colors.transparent,
          child: Column(
            children: [
              // Skeleton App Bar
              _buildSkeletonAppBar(context),
              // Skeleton Content
              Expanded(
                child: _getSkeletonForTab(targetIndex),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a skeleton app bar
  static Widget _buildSkeletonAppBar(BuildContext context) {
    return Container(
      height: kToolbarHeight + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Logo
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            // Title
            Container(
              height: 20,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const Spacer(),
            // Action buttons placeholder
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns appropriate skeleton content based on target tab
  static Widget _getSkeletonForTab(int targetIndex) {
    switch (targetIndex) {
      case 0: // Home
        return _buildHomeSkeleton();
      case 1: // Follow
        return _buildFollowSkeleton();
      case 2: // Discover
        return _buildDiscoverSkeleton();
      case 3: // Chat
        return _buildChatSkeleton();
      case 4: // Profile
        return _buildProfileSkeleton();
      default:
        return const SizedBox.shrink();
    }
  }

  /// Home page skeleton
  static Widget _buildHomeSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            height: 24,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          // Skeleton cards
          ...List.generate(3, (index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SkeletonHomeCard(),
          )),
        ],
      ),
    );
  }

  /// Follow page skeleton
  static Widget _buildFollowSkeleton() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDC2626)),
          ),
          SizedBox(height: 16),
          Text(
            "Loading follow requests...",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  /// Discover page skeleton
  static Widget _buildDiscoverSkeleton() {
    return const SizedBox.shrink(); // No loading for discover page
  }

  /// Chat page skeleton
  static Widget _buildChatSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Messages header
          Container(
            height: 24,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          // Chat with connections header
          Container(
            height: 20,
            width: 200,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          // Search bar skeleton
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          const SizedBox(height: 16),
          // Recent Message header
          Container(
            height: 20,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          // Connection list skeleton
          ...List.generate(5, (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SkeletonChatCard(),
          )),
        ],
      ),
    );
  }

  /// Profile page skeleton
  static Widget _buildProfileSkeleton() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header skeleton
          Container(
            height: 200,
            decoration: const BoxDecoration(
              color: Color(0xFFDC2626),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Avatar skeleton
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Name skeleton
                  Container(
                    height: 20,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Email skeleton
                  Container(
                    height: 16,
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content skeleton
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Quick info skeleton
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 16),
                // Department skeleton
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 16),
                // Bio skeleton
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
