import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/group_model.dart';
import '../../services/ai_service.dart';

class GroupChatScreen extends StatefulWidget {
  final GroupModel group;
  const GroupChatScreen({super.key, required this.group});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final _myId = Supabase.instance.client.auth.currentUser!.id;
  final _aiService = AIService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.group.imageUrl != null ? NetworkImage(widget.group.imageUrl!) : null,
              child: widget.group.imageUrl == null ? const Icon(Icons.groups) : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.group.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Text("online", style: TextStyle(fontSize: 12, color: Colors.green)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
          IconButton(icon: const Icon(Icons.call), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: _showGroupSettings),
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
                  colorFilter: ColorFilter.mode(Colors.white.withAlpha(230), BlendMode.lighten),
                ),
              ),
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: Supabase.instance.client
                    .from('messages')
                    .stream(primaryKey: ['id'])
                    .order('created_at', ascending: true),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final messages = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg['sender_id'] == _myId;
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? const Color(0xFF0D47A1) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
                          ),
                          child: Text(
                            msg['content'],
                            style: TextStyle(color: isMe ? Colors.white : Colors.black),
                          ),
                        ),
                      );
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

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.add, color: Color(0xFF0D47A1)), onPressed: _showAttachmentMenu),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(hintText: "Message", border: InputBorder.none),
                    ),
                  ),
                  const IconButton(icon: Icon(Icons.emoji_emotions_outlined, color: Colors.grey), onPressed: null),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onLongPress: () => debugPrint("Voice recording..."),
            child: const CircleAvatar(
              backgroundColor: Color(0xFF0D47A1),
              child: Icon(Icons.mic, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 350,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: GridView.count(
          crossAxisCount: 3,
          children: [
            _attachmentItem(Icons.image, "Gallery", Colors.purple, () {}),
            _attachmentItem(Icons.camera_alt, "Camera", Colors.pink, () {}),
            _attachmentItem(Icons.description, "Document", Colors.blue, () {}),
            _attachmentItem(Icons.location_on, "Location", Colors.green, () {}),
            _attachmentItem(Icons.person, "Contact", Colors.orange, () {}),
            _attachmentItem(Icons.poll, "Poll", Colors.teal, () {}),
            _attachmentItem(Icons.auto_awesome, "AI Image", Colors.indigo, _showAIImageGenerator),
            _attachmentItem(Icons.event, "Event", Colors.red, () {}),
            _attachmentItem(Icons.gif, "GIF", Colors.amber, () {}),
          ],
        ),
      ),
    );
  }

  Widget _attachmentItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return Column(
      children: [
        CircleAvatar(radius: 28, backgroundColor: color.withAlpha(26), child: Icon(icon, color: color, size: 30)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void _showAIImageGenerator() {
    Navigator.pop(context); // Close attachment menu
    bool isGenerating = false;
    String? generatedImageUrl;
    final promptController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "AI Image Generator",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "Describe the image you want to create for the community.",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: promptController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "e.g., A futuristic Makerere University library with holographic displays...",
                    fillColor: Colors.grey[100],
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (promptController.text.isEmpty) return;
                      setModalState(() => isGenerating = true);
                      
                      final url = await _aiService.generateImage(promptController.text.trim());
                      
                      if (mounted) {
                        setModalState(() {
                          isGenerating = false;
                          generatedImageUrl = url;
                        });
                      if (url == null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("AI Generation failed. Check API key."))
                        );
                      }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: isGenerating 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Generate Visual", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
                if (generatedImageUrl != null)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(generatedImageUrl!, height: 200, width: double.infinity, fit: BoxFit.cover),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => setModalState(() => generatedImageUrl = null),
                                  child: const Text("Discard"),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("AI Image shared to the group!"))
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1)),
                                  child: const Text("Send to Group", style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        }
      ),
    );
  }

  void _showGroupSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Group Settings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            ListTile(leading: const Icon(Icons.edit), title: const Text("Edit Description"), onTap: () {}),
            ListTile(leading: const Icon(Icons.photo_camera), title: const Text("Change Profile Picture"), onTap: () {}),
            ListTile(leading: const Icon(Icons.person_add), title: const Text("Add Members"), onTap: () {}),
            ListTile(leading: const Icon(Icons.lock), title: const Text("Privacy Settings"), onTap: () {}),
            ListTile(leading: const Icon(Icons.report, color: Colors.red), title: const Text("Report Scam"), onTap: () {}),
          ],
        ),
      ),
    );
  }
}
