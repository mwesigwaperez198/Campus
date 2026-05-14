import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/database_service.dart';
import '../../models/user_model.dart';
import '../directory/profile_view_screen.dart';

class ChatScreen extends StatefulWidget {
  final UserModel otherUser;

  const ChatScreen({super.key, required this.otherUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _dbService = DatabaseService();
  final _myId = Supabase.instance.client.auth.currentUser!.id;

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 0,
        title: GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileViewScreen(user: widget.otherUser))),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: widget.otherUser.avatarUrl != null ? NetworkImage(widget.otherUser.avatarUrl!) : null,
                child: widget.otherUser.avatarUrl == null ? const Icon(Icons.person) : null,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.otherUser.fullName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Text("online", style: TextStyle(fontSize: 12, color: Colors.green)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.videocam_outlined, color: Color(0xFF0D47A1)), onPressed: () {}),
          IconButton(icon: const Icon(Icons.call_outlined, color: Color(0xFF0D47A1)), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const NetworkImage("https://user-images.githubusercontent.com/15075759/28719144-86dc0f70-73b1-11e7-911d-60d70fcded21.png"),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.white.withAlpha(235), BlendMode.lighten),
                ),
              ),
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: supabase
                    .from('messages')
                    .stream(primaryKey: ['id'])
                    .order('created_at', ascending: true),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  
                  final messages = snapshot.data!.where((m) => 
                    (m['sender_id'] == _myId && m['receiver_id'] == widget.otherUser.id) ||
                    (m['sender_id'] == widget.otherUser.id && m['receiver_id'] == _myId)
                  ).toList();

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg['sender_id'] == _myId;
                      return _buildMessageBubble(msg['content'], isMe);
                    },
                  );
                },
              ),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String content, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF0D47A1) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          content,
          style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Color(0xFF0D47A1), size: 28),
              onPressed: _showAttachmentMenu,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: "Message...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _messageController.text.trim().isEmpty 
              ? Row(
                  children: [
                    IconButton(icon: const Icon(Icons.camera_alt_outlined, color: Colors.grey), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.mic_none, color: Colors.grey), onPressed: () {}),
                  ],
                )
              : IconButton(
                  icon: const Icon(Icons.send_rounded, color: Color(0xFF0D47A1)),
                  onPressed: () async {
                    if (_messageController.text.trim().isEmpty) return;
                    final text = _messageController.text.trim();
                    _messageController.clear();
                    await _dbService.sendMessage(widget.otherUser.id, text);
                    if (mounted) setState(() {});
                  },
                ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 380,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          children: [
            _attachmentItem(Icons.image, "Gallery", Colors.purple),
            _attachmentItem(Icons.camera_alt, "Camera", Colors.pink),
            _attachmentItem(Icons.description, "Document", Colors.blue),
            _attachmentItem(Icons.location_on, "Location", Colors.green),
            _attachmentItem(Icons.person, "Contact", Colors.orange),
            _attachmentItem(Icons.poll, "Poll", Colors.teal),
            _attachmentItem(Icons.auto_awesome, "AI Image", Colors.indigo),
            _attachmentItem(Icons.event, "Event", Colors.red),
            _attachmentItem(Icons.gif, "GIF", Colors.amber),
          ],
        ),
      ),
    );
  }

  Widget _attachmentItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: color.withAlpha(26),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
