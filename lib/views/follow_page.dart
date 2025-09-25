import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unimind/helper/map.dart';

class FollowPage extends StatelessWidget {
  const FollowPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Padding(
      padding: const EdgeInsets.all(16.0),
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
              return RichText(
                text: TextSpan(
                  style: GoogleFonts.montserrat(fontSize: 18 * textScale, fontWeight: FontWeight.w600, color: Colors.black),
                  children: [
                    const TextSpan(text: "Follow Request "),
                    TextSpan(text: "$requestCount", style: const TextStyle(color: Color(0xFFB41214))),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("followRequests")
                  .where("toUid", isEqualTo: currentUid)
                  .where("status", isEqualTo: "pending")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFFB41214)));

                final requests = snapshot.data!.docs;
                if (requests.isEmpty) return const Center(child: Text("No follow requests"));

                return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
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
                );
              },
            ),
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Avatar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: screenWidth * 0.18,
              height: screenWidth * 0.18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.grey[200],
              ),
              child: ClipOval(
                child: _buildAvatar(widget.imagePath, screenWidth * 0.18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Right: Info + Buttons
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: GoogleFonts.montserrat(
                    fontSize: 14 * textScale,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.yearCourse,
                  style: GoogleFonts.montserrat(
                    fontSize: 12 * textScale,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB41214),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
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
                        child: Text(
                          "Follow Back",
                          style: GoogleFonts.montserrat(
                            fontSize: 13 * textScale,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFB41214)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: _isProcessing
                            ? null
                            : () async {
                                setState(() => _isProcessing = true);
                                try {
                                  // delete the specific request doc (you already have requestDocId)
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
                        child: Text(
                          "Remove",
                          style: GoogleFonts.montserrat(
                            fontSize: 13 * textScale,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFB41214),
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