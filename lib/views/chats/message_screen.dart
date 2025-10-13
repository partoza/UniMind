import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:unimind/views/chats/message_profile_view.dart';

class MessageScreen extends StatefulWidget {
  final String peerUid;
  final String peerName;
  final String peerAvatar;

  const MessageScreen({
    super.key,
    required this.peerUid,
    required this.peerName,
    required this.peerAvatar,
  });

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final currentUid = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  String? _currentUserAvatar;

  String get chatId {
    final ids = [currentUid, widget.peerUid]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  ImageProvider _getAvatarImage(String? avatarPath) {
    if (avatarPath == null || avatarPath.isEmpty) {
      return const AssetImage('assets/default_avatar.png');
    }
    
    // Check if it's a URL (starts with http/https) or a local asset
    if (avatarPath.startsWith('http')) {
      return NetworkImage(avatarPath);
    } else {
      return AssetImage(avatarPath);
    }
  }

  // Add this method for navigation
  void _navigateToPeerProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessageProfileView(
          peerUid: widget.peerUid,
          peerName: widget.peerName,
          peerAvatar: widget.peerAvatar,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
    _initializeChatDocument();
    _fetchCurrentUserAvatar();
    
    // Add listener to handle text changes for Messenger-like behavior
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    // This will be called when text changes
    // The TextField will automatically handle scrolling when maxLines is reached
  }

  void _fetchCurrentUserAvatar() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUid)
          .get();
      
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _currentUserAvatar = userData['avatarPath'];
        });
      }
    } catch (e) {
      print('Error fetching current user avatar: $e');
    }
  }

  void _initializeChatDocument() async {
    // check chat document 
    await FirebaseFirestore.instance
        .collection("chats")
        .doc(chatId)
        .set({
      'participants': [currentUid, widget.peerUid],
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  void _markMessagesAsRead() async {
    try {
      final unreadMessages = await FirebaseFirestore.instance
          .collection("chats")
          .doc(chatId)
          .collection("messages")
          .where('senderUid', isEqualTo: widget.peerUid)
          .where('read', isEqualTo: false)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
          onPressed: () => Navigator.pop(context),
        ),
        // Wrap the title with GestureDetector to make it clickable
        title: GestureDetector(
          onTap: _navigateToPeerProfile,
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: _getAvatarImage(widget.peerAvatar),
                backgroundColor: Colors.grey[200],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.peerName,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: const Color(0xFF2D2D2D),
                      ),
                    ),
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .doc(widget.peerUid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text(
                            '...',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: const Color(0xFF6B7280),
                            ),
                          );
                        }
                        final status = snapshot.hasData && snapshot.data!.exists ? 'Online' : 'Offline';
                        return Text(
                          status,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: const Color(0xFF6B7280),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF6B7280)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
              .collection("chats")
              .doc(chatId)
              .collection("messages")
              .orderBy("timestamp", descending: false) // ascending
              .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print('Stream error: ${snapshot.error}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red[300], size: 60),
                        const SizedBox(height: 16),
                        Text(
                          "Error loading messages",
                          style: GoogleFonts.montserrat(
                            color: const Color(0xFF6B7280),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          snapshot.error.toString(),
                          style: GoogleFonts.montserrat(
                            color: const Color(0xFF6B7280),
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB41214)),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return _buildEmptyState();
                }

                final messages = snapshot.data!.docs;
                print('Number of messages: ${messages.length}');

                // Scroll to bottom after build
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });
                if (messages.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: false, // No reversing
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index].data() as Map<String, dynamic>;
                    final isMe = msg['senderUid'] == currentUid;
                    return _buildMessageBubble(msg, isMe);
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMe) {
    final timestamp = msg['timestamp'] != null 
        ? (msg['timestamp'] as Timestamp).toDate() 
        : DateTime.now();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 12,
              backgroundImage: _getAvatarImage(widget.peerAvatar),
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFFB41214) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg['text'] ?? '',
                    style: GoogleFonts.montserrat(
                      color: isMe ? Colors.white : const Color(0xFF2D2D2D),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(timestamp),
                    style: GoogleFonts.montserrat(
                      color: isMe ? Colors.white70 : const Color(0xFF6B7280),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 12,
              backgroundImage: _getAvatarImage(_currentUserAvatar),
              backgroundColor: Colors.grey[300],
            ),
          ],
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
            size: 60,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            "Start a conversation",
            style: GoogleFonts.montserrat(
              color: const Color(0xFF6B7280),
              fontSize: 16,
            ),
          ),
          Text(
            "Send your first message to ${widget.peerName}",
            style: GoogleFonts.montserrat(
              color: const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(
                maxHeight: 120, // Maximum height for 5 lines
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      style: GoogleFonts.montserrat(),
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: GoogleFonts.montserrat(color: const Color(0xFF9CA3AF)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      maxLines: 5, // Maximum 5 lines like Messenger
                      minLines: 1, // Start with 1 line
                      textInputAction: TextInputAction.newline,
                      onSubmitted: (value) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: Color(0xFF6B7280)),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.photo_camera, color: Color(0xFF6B7280)),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFB41214),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB41214).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    _focusNode.requestFocus();

    try {
      await FirebaseFirestore.instance
          .collection("chats")
          .doc(chatId)
          .collection("messages")
          .add({
        'senderUid': currentUid,
        'receiverUid': widget.peerUid,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

      // Update last message timestamp for chat list ordering
      await FirebaseFirestore.instance
          .collection("chats")
          .doc(chatId)
          .set({
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'participants': [currentUid, widget.peerUid],
        'lastMessageSenderUid': currentUid,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error sending message: $e');
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}