import 'package:flutter/material.dart';
import 'package:unimind/widgets/loading_widget.dart';

class SkeletonTestPage extends StatelessWidget {
  const SkeletonTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Content-Aware Loading'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Home page skeletons
            _buildSection(context, 'Home Page - Study Partners', const SkeletonHomeCard()),
            
            // Follow page skeletons
            _buildSection(context, 'Follow Page - Requests', const SkeletonFollowCard()),
            
            // Chat page skeletons
            _buildSection(context, 'Chat Page - Conversations', const SkeletonChatCard()),
            
            // Profile page skeletons
            _buildSection(context, 'Profile Page - User Info', const SkeletonProfileCard()),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, Widget skeleton) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: skeleton,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
