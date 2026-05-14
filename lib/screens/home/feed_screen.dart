import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/database_service.dart';
import '../../services/storage_service.dart';
import '../../models/post_model.dart';
import '../../widgets/post_card.dart';
import '../../widgets/story_circle.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'create_post_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _dbService = DatabaseService();
  final _storageService = StorageService();
  final _picker = ImagePicker();

  Future<void> _pickAndUploadStory() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      try {
        final userId = Supabase.instance.client.auth.currentUser!.id;
        final url = await _storageService.uploadMedia('stories', File(image.path));
        await _dbService.createStory(userId, url);
        if (!mounted) return;
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Story uploaded!")));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "CampusConnect",
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D47A1), fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CreatePostScreen()));
            },
          ),
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
          IconButton(icon: const Icon(Icons.chat_bubble_outline), onPressed: () {}),
        ],
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Stories Bar
              SizedBox(
                height: 115,
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _dbService.getStories(),
                  builder: (context, snapshot) {
                    final stories = snapshot.data ?? [];
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: stories.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return StoryCircle(
                            name: "Add Story",
                            isMe: true,
                            onTap: _pickAndUploadStory,
                          );
                        }
                        final story = stories[index - 1];
                        return StoryCircle(
                          imageUrl: story['content_url'],
                          name: story['profiles']['full_name'],
                          onTap: () {
                            _viewStory(story['content_url'], story['profiles']['full_name']);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              
              // Post Feed
              FutureBuilder<List<PostModel>>(
                future: _dbService.getFeed(type: 'standard'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyFeed();
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) => PostCard(post: snapshot.data![index]),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewStory(String url, String name) {
    showDialog(
      context: context,
      builder: (context) => Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(child: Image.network(url, fit: BoxFit.contain)),
            Positioned(
              top: 40,
              left: 20,
              child: Row(
                children: [
                  const CircleAvatar(radius: 15, child: Icon(Icons.person, size: 20)),
                  const SizedBox(width: 10),
                  Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFeed() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(Icons.feed_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text("Welcome to Makerere Connect!", style: TextStyle(fontWeight: FontWeight.bold)),
            const Text("Posts from your community will appear here.", textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
