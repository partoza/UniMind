import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unimind/helper/map.dart';
import 'package:unimind/widgets/loading_widget.dart';

class FollowPage extends StatelessWidget {
  const FollowPage({super.key});



  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("followRequests")
                .where("toUid", isEqualTo: currentUid)
                .where("status", isEqualTo: "pending")
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
              
              int requestCount = snapshot.data?.docs.length ?? 0;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Simple Header
                  Text(
                    "Follow Requests",
                    style: GoogleFonts.montserrat(
                      fontSize: 18 * textScale,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "$requestCount pending request${requestCount > 1 ? 's' : ''}",
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Content
                  Expanded(
                    child: !snapshot.hasData 
                      ? Container(
                          color: Colors.white,
                          width: double.infinity,
                          height: double.infinity,
                        )
                      : requestCount == 0
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: requestCount,
                            itemBuilder: (context, index) {
                              final request = snapshot.data!.docs[index];
                              final requestData = request.data() as Map<String, dynamic>? ?? {};
                              final fromUid = requestData['fromUid'] as String? ?? '';
                              if (fromUid.isEmpty) return const SizedBox.shrink();
                              return StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance.collection("users").doc(fromUid).snapshots(),
                                builder: (context, userSnap) {
                                  if (!userSnap.hasData || !userSnap.data!.exists) return const SizedBox.shrink();
                                  final userData = userSnap.data!.data() as Map<String, dynamic>? ?? {};

                                  return FollowRequestCard(
                                    uid: userData['uid'] ?? '',
                                    name: userData['displayName'] ?? '',
                                    yearCourse: "${userData['yearLevel'] ?? ''}, ${userData['program'] ?? ''}",
                                    imagePath: userData['avatarPath'] ?? '',
                                    requestDocId: request.id,
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: const Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 16),
          Text(
            "No follow requests yet",
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "When someone wants to follow you,\nit will appear here",
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
  bool _isProcessing = false;

  Widget _buildAvatar(String path, double size) {
    if (path.isEmpty) return Container(width: size, height: size, color: Colors.grey[200]);
    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Container(color: Colors.grey[200]),
      );
    }
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (c, e, s) => Container(color: Colors.grey[200]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Modern Avatar with Status Indicator
            Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFB41214).withOpacity(0.2),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB41214).withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _buildAvatar(widget.imagePath, 60),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // User Info Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name with better typography
                  Text(
                    widget.name,
                    style: GoogleFonts.montserrat(
                      fontSize: 16 * textScale,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                      letterSpacing: -0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Year/Course with improved styling
                  Text(
                    widget.yearCourse,
                    style: GoogleFonts.montserrat(
                      fontSize: 13 * textScale,
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  // Modern Action Buttons
                  Row(
                    children: [
                      // Accept Button with gradient
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFB41214), Color(0xFF8B0000)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFB41214).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isProcessing
                              ? null
                              : () async {
                                  setState(() => _isProcessing = true);
                                  try {
                                    final currentUid = FirebaseAuth.instance.currentUser!.uid;
                                    final fromUid = widget.uid;

                                    final currentUserRef = FirebaseFirestore.instance.collection('users').doc(currentUid);
                                    final fromUserRef = FirebaseFirestore.instance.collection('users').doc(fromUid);
                                    final followRequestsRef = FirebaseFirestore.instance.collection('followRequests');

                                    final batch = FirebaseFirestore.instance.batch();

                                    // Delete pending requests between the two users
                                    final pendingA = await followRequestsRef
                                        .where('fromUid', isEqualTo: currentUid)
                                        .where('toUid', isEqualTo: fromUid)
                                        .where('status', isEqualTo: 'pending')
                                        .get();
                                    for (var d in pendingA.docs) batch.delete(d.reference);

                                    final pendingB = await followRequestsRef
                                        .where('fromUid', isEqualTo: fromUid)
                                        .where('toUid', isEqualTo: currentUid)
                                        .where('status', isEqualTo: 'pending')
                                        .get();
                                    for (var d in pendingB.docs) batch.delete(d.reference);

                                    // Update BOTH followers and following for both users
                                    final myFollowingDoc = currentUserRef.collection('following').doc(fromUid);
                                    final myFollowerDoc = currentUserRef.collection('followers').doc(fromUid);
                                    final theirFollowingDoc = fromUserRef.collection('following').doc(currentUid);
                                    final theirFollowerDoc = fromUserRef.collection('followers').doc(currentUid);

                                    batch.set(myFollowingDoc, <String, dynamic>{});
                                    batch.set(myFollowerDoc, <String, dynamic>{});
                                    batch.set(theirFollowingDoc, <String, dynamic>{});
                                    batch.set(theirFollowerDoc, <String, dynamic>{});

                                    await batch.commit();

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("You accepted ${widget.name}'s request")),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Error: $e")),
                                    );
                                  } finally {
                                    if (mounted) setState(() => _isProcessing = false);
                                  }
                                },
                            child: _isProcessing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  "Accept",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14 * textScale,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Decline Button with modern styling
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: _isProcessing
                              ? null
                              : () async {
                                  setState(() => _isProcessing = true);
                                  try {
                                    // delete the specific request document
                                    await FirebaseFirestore.instance.collection('followRequests').doc(widget.requestDocId).delete();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Removed follow request from ${widget.name}")),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Error: $e")),
                                    );
                                  } finally {
                                    if (mounted) setState(() => _isProcessing = false);
                                  }
                                },
                          icon: Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: const Color(0xFF6B7280),
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
      ),
    );
  }
}