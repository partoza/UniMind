import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unimind/views/message_screen.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final currentUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Messages",
                  style: GoogleFonts.montserrat(
                    fontSize: 28 * textScale,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search, size: 28),
                  color: const Color(0xFF6B7280),
                  onPressed: () {
                    // Implement search functionality
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Chat with your connections",
              style: GoogleFonts.montserrat(
                fontSize: 14 * textScale,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            
            // Chat List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(currentUid)
                    .collection("following")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState();
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState();
                  }

                  final followingDocs = snapshot.data!.docs;

                  return ListView.separated(
                    itemCount: followingDocs.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, indent: 70),
                    itemBuilder: (context, index) {
                      final doc = followingDocs[index];
                      final uid = doc.id;

                      return _buildChatListItem(uid);
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

  Widget _buildChatListItem(String peerUid) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(peerUid)
          .collection("following")
          .doc(currentUid)
          .snapshots(),
      builder: (context, mutualSnap) {
        if (!mutualSnap.hasData || !mutualSnap.data!.exists) {
          return const SizedBox.shrink();
        }

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection("users").doc(peerUid).get(),
          builder: (context, userSnap) {
            if (!userSnap.hasData || !userSnap.data!.exists) {
              return const SizedBox.shrink();
            }

            final userData = userSnap.data!.data() as Map<String, dynamic>? ?? {};
            return _buildChatTile(peerUid, userData);
          },
        );
      },
    );
  }

  Widget _buildChatTile(String peerUid, Map<String, dynamic> userData) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("chats")
          .doc(_getChatId(currentUid, peerUid))
          .collection("messages")
          .orderBy("timestamp", descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, msgSnap) {
        String lastMessage = "Say Hi!";
        String timeAgo = "";
        bool hasUnread = false;

        if (msgSnap.hasData && msgSnap.data!.docs.isNotEmpty) {
          final msg = msgSnap.data!.docs.first.data() as Map<String, dynamic>;
          lastMessage = msg['text'] ?? 'Say Hi!';
          
          // Format timestamp
          if (msg['timestamp'] != null) {
            final timestamp = msg['timestamp'] as Timestamp;
            timeAgo = _formatTimeAgo(timestamp.toDate());
          }
          
          // Check if message is unread (you can add this field to your messages)
          hasUnread = msg['read'] == false && msg['senderUid'] != currentUid;
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            leading: Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFB41214).withOpacity(0.2), width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 26,
                    backgroundImage: userData['avatarPath'] != null && userData['avatarPath']!.isNotEmpty
                        ? NetworkImage(userData['avatarPath']!)
                        : const AssetImage('assets/default_avatar.png') as ImageProvider,
                    backgroundColor: Colors.grey[200],
                  ),
                ),
                if (hasUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFFB41214),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    userData['displayName'] ?? 'Unknown User',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: const Color(0xFF2D2D2D),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (timeAgo.isNotEmpty)
                  Text(
                    timeAgo,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                lastMessage,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: const Color(0xFF6B7280),
                  fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MessageScreen(
                    peerUid: peerUid,
                    peerName: userData['displayName'] ?? 'Unknown User',
                    peerAvatar: userData['avatarPath'] ?? '',
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFFB41214)),
          ),
          const SizedBox(height: 16),
          Text(
            "Loading conversations...",
            style: GoogleFonts.montserrat(
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            "No conversations yet",
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Start following users to begin chatting",
            style: GoogleFonts.montserrat(
              color: const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    if (difference.inDays < 7) return '${difference.inDays}d';
    
    return DateFormat('MMM dd').format(date);
  }

  String _getChatId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }
}