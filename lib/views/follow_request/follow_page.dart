import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unimind/views/profile/profile_page.dart';


String getYearLevelString(dynamic yearLevel) {
  if (yearLevel == null) return '';

  // Handle both String and int types that might come from Firestore
  final int level = (yearLevel is String) ? int.tryParse(yearLevel) ?? 0 : (yearLevel is int ? yearLevel : 0);

  switch (level) {
    case 1:
      return '1st Year';
    case 2:
      return '2nd Year';
    case 3:
      return '3rd Year';
    case 4:
      return '4th Year';
    default:
      return 'Year Level Unknown';
  }
}


class FollowPage extends StatelessWidget {
  const FollowPage({super.key});

  // Direct Hex Colors
  static const Color primaryRed = Color(0xFFB41214);
  static const Color textColorPrimary = Color(0xFF1F2937);
  static const Color textColorSecondary = Color(0xFF6B7280);
  static const Color cardBackground = Color(0xFFF9FAFC);

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) {
      return const Center(child: Text("User not logged in"));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("followRequests")
                  .where("toUid", isEqualTo: currentUid)
                  .where("status", isEqualTo: "pending")
                  .snapshots(),
              builder: (context, snapshot) {
                int requestCount = snapshot.data?.docs.length ?? 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Main Title
                      Text(
                        "Follow Requests ",
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: textColorPrimary,
                        ),
                      ),
                      // Circular Badge Count
                      if (requestCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 4.0),
                          padding: const EdgeInsets.all(
                            6,
                          ), // Equal padding on all sides for circular shape
                          decoration: const BoxDecoration(
                            color: primaryRed,
                            shape: BoxShape
                                .circle, // Explicitly set shape to circle
                          ),
                          alignment: Alignment
                              .center, // Center the text inside the circle
                          child: Text(
                            "$requestCount",
                            style: GoogleFonts.montserrat(
                              fontSize:
                                  16, // Adjusted for better fit in a circle
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("followRequests")
                    .where("toUid", isEqualTo: currentUid)
                    .where("status", isEqualTo: "pending")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: primaryRed));
                  }

                  final requests = snapshot.data!.docs;
                  if (requests.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Illustrative Image for no requests
                          Image.asset(
                            'assets/images/no_requests.png', // Replace with your image path
                            width: 200, 
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 20),
                          // Engaging Message with Line Break
                          Text.rich(
                            TextSpan(
                              text: "All caught up!\n", // Line Break added here
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: textColorPrimary,
                              ),
                              children: [
                                TextSpan(
                                  text: "No new follow requests.",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: textColorSecondary,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      final requestData = request.data() as Map<String, dynamic>? ?? {};
                      final fromUid = requestData['fromUid'] as String? ?? '';
                      if (fromUid.isEmpty) return const SizedBox.shrink();

                      // Fetch sender details
                      return StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance.collection("users").doc(fromUid).snapshots(),
                        builder: (context, userSnap) {
                          if (!userSnap.hasData || !userSnap.data!.exists) return const SizedBox.shrink();
                          final userData = userSnap.data!.data() as Map<String, dynamic>? ?? {};

                          // *** APPLY THE YEAR LEVEL CONVERSION HERE ***
                          final String displayYearLevel = getYearLevelString(userData['yearLevel']);
                          final String programAcronym = userData['programAcronym'] ?? '';
                          
                          final String displayYearCourse = displayYearLevel.isNotEmpty && programAcronym.isNotEmpty
                            ? "$displayYearLevel, $programAcronym"
                            : displayYearLevel.isNotEmpty
                                ? displayYearLevel
                                : programAcronym;


                          return FollowRequestCard(
                            uid: userData['uid'] ?? '',
                            name: userData['displayName'] ?? 'Unknown User',
                            yearCourse: displayYearCourse, // Use the converted string
                            imagePath: userData['avatarPath'] ?? '',
                            requestDocId: request.id,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class FollowRequestCard extends StatefulWidget {
  final String uid;
  final String name;
  final String yearCourse;
  final String imagePath;
  final String requestDocId;

  const FollowRequestCard({
    super.key,
    required this.uid,
    required this.name,
    required this.yearCourse,
    required this.imagePath,
    required this.requestDocId,
  });

  @override
  State<FollowRequestCard> createState() => _FollowRequestCardState();
}

class _FollowRequestCardState extends State<FollowRequestCard> {
  // State for button loading
  bool _isProcessing = false;

  // Direct Hex Colors
  static const Color primaryRed = Color(0xFFB41214);
  static const Color cardBackground = Color(0xFFF9FAFC);
  static const Color textColorPrimary = Color(0xFF1F2937);
  static const Color textColorSecondary = Color(0xFF6B7280);

  Widget _buildAvatar(String path, double size) {
    final defaultAvatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: textColorSecondary.withOpacity(0.2), shape: BoxShape.circle),
      child: Icon(Icons.person, color: textColorSecondary, size: size * 0.6),
    );

    if (path.isEmpty) return defaultAvatar;
    
    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => defaultAvatar,
      );
    }
    
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (c, e, s) => defaultAvatar,
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(userId: widget.uid),
      ),
    );
  }

  // Accept Follow Request: completes the follow, deletes pending requests
  Future<void> _acceptRequest() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final currentUid = FirebaseAuth.instance.currentUser!.uid;
      final fromUid = widget.uid;
      final batch = FirebaseFirestore.instance.batch();

      // 1. Delete all pending requests between users
      final pendingRequests = await FirebaseFirestore.instance.collection('followRequests')
          .where('fromUid', whereIn: [currentUid, fromUid])
          .where('toUid', whereIn: [currentUid, fromUid])
          .where('status', isEqualTo: 'pending')
          .get();
      for (var d in pendingRequests.docs) {
        batch.delete(d.reference);
      }

      // 2. Establish mutual follow relationship
      final currentUserRef = FirebaseFirestore.instance.collection('users').doc(currentUid);
      final fromUserRef = FirebaseFirestore.instance.collection('users').doc(fromUid);

      batch.set(currentUserRef.collection('following').doc(fromUid), <String, dynamic>{'timestamp': FieldValue.serverTimestamp()});
      batch.set(currentUserRef.collection('followers').doc(fromUid), <String, dynamic>{'timestamp': FieldValue.serverTimestamp()});
      batch.set(fromUserRef.collection('following').doc(currentUid), <String, dynamic>{'timestamp': FieldValue.serverTimestamp()});
      batch.set(fromUserRef.collection('followers').doc(currentUid), <String, dynamic>{'timestamp': FieldValue.serverTimestamp()});

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You are now following ${widget.name}!"), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error accepting request: ${e.toString()}"), backgroundColor: primaryRed));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // Reject Follow Request: deletes the request document
  Future<void> _rejectRequest() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      await FirebaseFirestore.instance.collection('followRequests').doc(widget.requestDocId).delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Rejected follow request from ${widget.name}."), backgroundColor: textColorSecondary));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error rejecting request: ${e.toString()}"), backgroundColor: primaryRed));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;
    final double avatarSize = 60.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBackground, 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Avatar
          GestureDetector(
            onTap: _navigateToProfile,
            child: Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryRed.withOpacity(0.5), width: 1.5),
              ),
              child: ClipOval(
                child: _buildAvatar(widget.imagePath, avatarSize),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Right: Info (Name/Course) and Buttons (Vertical Layout)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Section
                GestureDetector(
                  onTap: _navigateToProfile,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: GoogleFonts.montserrat(
                          fontSize: 16 * textScale,
                          fontWeight: FontWeight.w700,
                          color: textColorPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.yearCourse.trim().isNotEmpty ? widget.yearCourse : 'Details unavailable',
                        style: GoogleFonts.montserrat(
                          fontSize: 12 * textScale,
                          color: textColorSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Buttons Section
                Row(
                  children: [
                    // Accept Button
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryRed,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: _isProcessing ? null : _acceptRequest,
                          child: _isProcessing
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  "Accept",
                                  style: GoogleFonts.montserrat(fontSize: 12 * textScale, fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Remove Button
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: primaryRed, width: 1.5),
                            foregroundColor: primaryRed,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: _isProcessing ? null : _rejectRequest,
                          child: Text(
                            "Remove",
                            style: GoogleFonts.montserrat(fontSize: 12 * textScale, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}