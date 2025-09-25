import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unimind/nav/custom_navbar.dart';

import 'package:unimind/views/follow_page.dart';
import 'package:unimind/views/chats.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // Define all pages
    _pages = const [
      _HomeContent(),
      FollowPage(),   
      Center(child: Text("Discover Page")),
      ChatPage(),
      Center(child: Text("Profile Page")),
    ];
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
              "assets/UniMind Logo.png",
              width: 32,
              height: 32,
            ),
            const SizedBox(width: 8),
            Text(
              "UniMind",
              style: GoogleFonts.montserrat(
                color: const Color(0xFFB41214),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),

      // show correct page
      body: _pages[_currentIndex],

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
}

/// Home content
class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
        ),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
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
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFB41214)),
                );
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: otherDocs.length,
                itemBuilder: (context, i) {
                  final data = otherDocs[i].data() as Map<String, dynamic>? ?? {};
                  final docUid = data['uid'] as String? ?? otherDocs[i].id;
                  final displayName = data['displayName'] as String? ?? "Unknown";
                  final yearLevel = data['yearLevel'] as String? ?? "";
                  final program = data['program'] as String? ?? "";
                  final nameAndCourse =
                      "$yearLevel${program.isNotEmpty ? ', $program' : ''}";
                  final avatarPath = (data['avatarPath'] ?? data['avatar'] ?? '') as String;
                  final strengths = (data['strengths'] is List)
                      ? List<String>.from((data['strengths'] as List).map((e) => e.toString()))
                      : <String>[];
                  final weaknesses = (data['weaknesses'] is List)
                      ? List<String>.from((data['weaknesses'] as List).map((e) => e.toString()))
                      : <String>[];
                  final bio = data['bio'] as String? ?? "";
                  final location = data['location'] as String? ?? "Campus";

                  return SuggestedCard(
                    uid: docUid,
                    name: displayName,
                    yearCourse: nameAndCourse,
                    imagePath: avatarPath,
                    goodIn: strengths,
                    needImprovements: weaknesses,
                    bio: bio,
                    location: location,
                  );
                },
              );
            },
          ),
        ),
      ],
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

  final currentUserRef = FirebaseFirestore.instance.collection('users').doc(currentUid);
  final targetUserRef = FirebaseFirestore.instance.collection('users').doc(widget.uid);
  final followRequestsRef = FirebaseFirestore.instance.collection('followRequests');

  try {
    //  UNFOLLOW
    if (isFollowing) {
      final batch = FirebaseFirestore.instance.batch();
      final myFollowingDoc = currentUserRef.collection('following').doc(widget.uid);
      final theirFollowerDoc = targetUserRef.collection('followers').doc(currentUid);

      batch.delete(myFollowingDoc);
      batch.delete(theirFollowerDoc);

      await batch.commit();

      // If the other still follows, create a pending request
      final otherFollowsMe = await targetUserRef.collection('following').doc(currentUid).get();
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
      final myFollowerDoc = currentUserRef.collection('followers').doc(widget.uid);
      final myFollowingDoc = currentUserRef.collection('following').doc(widget.uid);
      final theirFollowerDoc = targetUserRef.collection('followers').doc(currentUid);
      final theirFollowingDoc = targetUserRef.collection('following').doc(currentUid);

      batch.set(myFollowerDoc, <String, dynamic>{});
      batch.set(myFollowingDoc, <String, dynamic>{});
      batch.set(theirFollowerDoc, <String, dynamic>{});
      batch.set(theirFollowingDoc, <String, dynamic>{});
      await batch.commit();
      return;
    }

    // Fresh follow - check if mutual follow should happen
    final otherFollowsMeSnap = await targetUserRef.collection('following').doc(currentUid).get();
    if (otherFollowsMeSnap.exists || isFollowingMe) {
      final batch = FirebaseFirestore.instance.batch(); 
      final myFollowingDoc = currentUserRef.collection('following').doc(widget.uid);
      final theirFollowerDoc = targetUserRef.collection('followers').doc(currentUid);

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  Widget _buildChip(String label, bool isGood, double textScale) {
    return Chip(
      label: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 9 * textScale,
          color: isGood ? Colors.white : Colors.black,
        ),
      ),
      backgroundColor: isGood ? const Color(0xFFB41214) : Colors.grey[200],
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildImage(String path, double screenWidth) {
    if (path.isEmpty) {
      return Container(color: Colors.grey[300], width: double.infinity, height: double.infinity);
    }
    if (path.startsWith('http')) {
      return Image.network(
        path,
        height: screenWidth * 0.65,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Container(color: Colors.grey[300]),
      );
    }
    return Image.asset(
      path,
      height: screenWidth * 0.65,
      width: double.infinity,
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

  Widget _buildInfoColumn(
    double textScale,
    double screenWidth,
    bool isFollowing,
    bool isPendingSent,
    bool isPendingReceived,
    bool isFollowingMe,
    String buttonLabel,
  ) {
    return Padding(
      padding: EdgeInsets.only(right: screenWidth * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 0.0, bottom: 4.0),
            child: Text(
              "Good In",
              style: GoogleFonts.montserrat(
                fontSize: 14 * textScale,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: widget.goodIn.map((skill) => _buildChip(skill, true, textScale)).toList(),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(top: 0.0, bottom: 4.0),
            child: Text(
              "Need Improvements in",
              style: GoogleFonts.montserrat(
                fontSize: 14 * textScale,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Wrap(
            spacing: 5,
            runSpacing: 4,
            children: widget.needImprovements.map((skill) => _buildChip(skill, false, textScale)).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            "My Bio",
            style: GoogleFonts.montserrat(
              fontSize: 13 * textScale,
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            height: screenWidth * 0.15,
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(widget.bio, style: GoogleFonts.montserrat(fontSize: 11 * textScale)),
          ),
          const SizedBox(height: 10),
          Text(
            "Meet me at ${widget.location} 🏫",
            style: GoogleFonts.montserrat(fontSize: 10 * textScale, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isFollowing || isPendingSent || isPendingReceived ? Colors.grey.shade300 : const Color(0xFFB41214),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: _isLoading
                ? null
                : () => _toggleFollow(
                      isFollowing: isFollowing,
                      isPendingSent: isPendingSent,
                      isPendingReceived: isPendingReceived,
                      isFollowingMe: isFollowingMe,
                    ),
            child: Text(
              buttonLabel,
              style: GoogleFonts.montserrat(
                fontSize: 12 * textScale,
                fontWeight: FontWeight.w600,
                color: isFollowing || isPendingSent || isPendingReceived ? Colors.black : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final textScale = MediaQuery.of(context).textScaleFactor;

  return StreamBuilder<DocumentSnapshot>(
    stream: followingStream(),
    builder: (context, followingSnap) {
      final isFollowing = followingSnap.hasData && 
                         followingSnap.data != null && 
                         followingSnap.data!.exists;

      return StreamBuilder<DocumentSnapshot>(
        stream: followerStream(),
        builder: (context, followerSnap) {
          final isFollowingMe = followerSnap.hasData && 
                               followerSnap.data != null && 
                               followerSnap.data!.exists;

          return StreamBuilder<QuerySnapshot>(
            stream: sentRequestStream(),
            builder: (context, sentSnap) {
              final isPendingSent = sentSnap.hasData && 
                                   sentSnap.data != null && 
                                   sentSnap.data!.docs.isNotEmpty;

              return StreamBuilder<QuerySnapshot>(
                stream: receivedRequestStream(),
                builder: (context, receivedSnap) {
                  final isPendingReceived = receivedSnap.hasData && 
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
    margin: const EdgeInsets.symmetric(vertical: 10),
    child: Stack(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: screenWidth * 0.50),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Profile Image
                Container(
                  width: screenWidth * 0.38,
                  height: screenWidth * 0.65,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildImage(widget.imagePath, screenWidth),
                      ),
                      Container(
                        height: screenWidth * 0.65,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "${widget.name}\n${widget.yearCourse}",
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 12 * textScale,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Right: Info + Follow button
                Expanded(
                  child: _buildInfoColumn(
                    textScale,
                    screenWidth,
                    isFollowing,
                    isPendingSent,
                    isPendingReceived,
                    isFollowingMe,
                    buttonLabel,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Badge
        Positioned(
          top: 0,
          right: 0,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.all(6),
              color: Colors.yellow,
              child: Icon(
                Icons.emoji_events,
                size: screenWidth * 0.06,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}