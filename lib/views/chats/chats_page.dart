import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unimind/views/chats/message_screen.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final currentUid = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounceTimer != null) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  ImageProvider _getAvatarImage(String? avatarPath) {
    if (avatarPath == null || avatarPath.isEmpty) {
      return const AssetImage('assets/default_avatar.png');
    }
    
    if (avatarPath.startsWith('http')) {
      return NetworkImage(avatarPath);
    } else {
      return AssetImage(avatarPath);
    }
  }

  void _navigateToChat(String peerUid, String peerName, String peerAvatar) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessageScreen(
          peerUid: peerUid,
          peerName: peerName,
          peerAvatar: peerAvatar,
        ),
      ),
    );
  }

  // New method to get chat data with last message timestamps for sorting
  Stream<List<Map<String, dynamic>>> _getSortedChatsStream() {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(currentUid)
        .collection("following")
        .snapshots()
        .asyncMap((followingSnapshot) async {
      final followingDocs = followingSnapshot.docs;
      final List<Map<String, dynamic>> chatDataList = [];

      for (final doc in followingDocs) {
        final peerUid = doc.id;
        
        // Get user data
        final userDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(peerUid)
            .get();
        
        if (!userDoc.exists) continue;

        final userData = userDoc.data() as Map<String, dynamic>? ?? {};
        final displayName = userData['displayName'] ?? 'Unknown User';
        
        // Filter by search query
        if (_searchQuery.isNotEmpty && 
            !displayName.toLowerCase().contains(_searchQuery)) {
          continue;
        }

        // Check mutual follow
        final mutualDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(peerUid)
            .collection("following")
            .doc(currentUid)
            .get();

        if (!mutualDoc.exists) continue;

        // Get last message timestamp
        final lastMessageQuery = await FirebaseFirestore.instance
            .collection("chats")
            .doc(_getChatId(currentUid, peerUid))
            .collection("messages")
            .orderBy("timestamp", descending: true)
            .limit(1)
            .get();

        Timestamp? lastMessageTimestamp;
        if (lastMessageQuery.docs.isNotEmpty) {
          final lastMessage = lastMessageQuery.docs.first.data();
          lastMessageTimestamp = lastMessage['timestamp'] as Timestamp?;
        }

        chatDataList.add({
          'peerUid': peerUid,
          'userData': userData,
          'lastMessageTimestamp': lastMessageTimestamp,
        });
      }

      // Sort by last message timestamp (most recent first)
      // If no messages, they go to the bottom
      chatDataList.sort((a, b) {
        final timestampA = a['lastMessageTimestamp'] as Timestamp?;
        final timestampB = b['lastMessageTimestamp'] as Timestamp?;
        
        if (timestampA == null && timestampB == null) return 0;
        if (timestampA == null) return 1; // A goes after B
        if (timestampB == null) return -1; // A goes before B
        
        return timestampB.compareTo(timestampA); // Most recent first
      });

      return chatDataList;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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

              // Search Bar
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
                        controller: _searchController,
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
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: const Color(0xFF6B7280).withOpacity(0.7),
                          size: 20,
                        ),
                        onPressed: () {
                          _searchController.clear();
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Connections Horizontal List
              SizedBox(
                height: 80,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(currentUid)
                      .collection("following")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink(); // Remove Firebase loading
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return _buildEmptyConnections();
                    }

                    final followingDocs = snapshot.data!.docs;

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: followingDocs.length,
                      itemBuilder: (context, index) {
                        final doc = followingDocs[index];
                        final uid = doc.id;
                        return _buildConnectionCircle(uid);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Recent Messages Header
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

              // Chat List - Now sorted by most recent message
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _getSortedChatsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink(); // Remove Firebase loading
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmptyState();
                    }

                    final chatDataList = snapshot.data!;

                    return ListView.separated(
                      itemCount: chatDataList.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final chatData = chatDataList[index];
                        final peerUid = chatData['peerUid'] as String;
                        final userData = chatData['userData'] as Map<String, dynamic>;

                        return _buildChatTile(peerUid, userData);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionCircle(String peerUid) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection("users").doc(peerUid).get(),
      builder: (context, userSnap) {
        if (!userSnap.hasData || !userSnap.data!.exists) {
          return const SizedBox.shrink();
        }

        final userData = userSnap.data!.data() as Map<String, dynamic>? ?? {};
        final displayName = userData['displayName'] ?? 'Unknown User';
        final firstName = displayName.split(' ').first;
        final avatarPath = userData['avatarPath'] ?? '';

        // Filter by search query
        if (_searchQuery.isNotEmpty && 
            !displayName.toLowerCase().contains(_searchQuery) &&
            !firstName.toLowerCase().contains(_searchQuery)) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            _navigateToChat(peerUid, displayName, avatarPath);
          },
          child: Container(
            width: 70,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                // Avatar with subtle tap feedback
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _navigateToChat(peerUid, displayName, avatarPath);
                    },
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFB41214).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundImage: _getAvatarImage(avatarPath),
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  firstName,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2D2D2D),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
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

          if (msg['timestamp'] != null) {
            final timestamp = msg['timestamp'] as Timestamp;
            timeAgo = _formatTimeAgo(timestamp.toDate());
          }

          hasUnread = msg['read'] == false && msg['senderUid'] != currentUid;
        }

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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _navigateToChat(
                  peerUid, 
                  userData['displayName'] ?? 'Unknown User', 
                  userData['avatarPath'] ?? ''
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFB41214).withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 23,
                        backgroundImage: _getAvatarImage(userData['avatarPath']),
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Message Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 150,
                                child: Text(
                                  userData['displayName'] ?? 'Unknown User',
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: const Color(0xFF2D2D2D),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                ),
                              ),
                              Text(
                                timeAgo.isEmpty ? 'Now' : timeAgo,
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lastMessage,
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: const Color(0xFF6B7280),
                              fontWeight: hasUnread
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),

                    // Unread indicator
                    if (hasUnread)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFB41214),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildConnectionsLoading() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          width: 70,
          margin: const EdgeInsets.only(right: 16),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 6),
              Container(width: 40, height: 12, color: Colors.grey[300]),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyConnections() {
    return Center(
      child: Text(
        "No connections yet",
        style: GoogleFonts.montserrat(
          color: const Color(0xFF6B7280),
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
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
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(radius: 25, backgroundColor: Colors.grey),
                SizedBox(width: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
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
            "Start a conversation with your connections",
            style: GoogleFonts.montserrat(color: const Color(0xFF6B7280)),
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
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return DateFormat('MMM dd').format(date);
  }

  String _getChatId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }
}