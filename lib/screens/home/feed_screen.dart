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
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        titleSpacing: 12,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFFFB300), Color(0xFFE91E63), Color(0xFF0D47A1)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 9),
            const Text(
              "CampusConnect",
              style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0D47A1), fontSize: 23),
            ),
          ],
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
        surfaceTintColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black12,
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Stories Bar
              Container(
                height: 116,
                color: Colors.white,
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _dbService.getStories(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: 6,
                        itemBuilder: (context, index) {
                          return StoryCircle(
                            name: index == 0 ? "Add Story" : "Campus",
                            isMe: index == 0,
                            onTap: index == 0 ? _pickAndUploadStory : () {},
                          );
                        },
                      );
                    }

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
                        final profile = story['profiles'] as Map<String, dynamic>?;
                        final name = profile?['full_name'] as String? ?? 'Campus';
                        return StoryCircle(
                          imageUrl: story['content_url'] as String?,
                          name: name,
                          onTap: () {
                            _viewStory(story['content_url'] as String, name);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE8ECF2)),
              
              // Post Feed
              FutureBuilder<List<PostModel>>(
                future: _dbService.getFeed(type: 'standard'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return _buildFeedError(snapshot.error.toString());
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
            Container(
              width: 86,
              height: 86,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEAF1FB),
              ),
              child: Icon(Icons.feed_outlined, size: 44, color: Colors.grey[500]),
            ),
            const SizedBox(height: 16),
            const Text(
              "Welcome to Makerere Connect!",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              "Posts from your campus community will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedError(String error) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.wifi_off_outlined, size: 48, color: Color(0xFF0D47A1)),
          const SizedBox(height: 14),
          const Text(
            "Couldn't load the feed",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            error,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
            label: const Text("Try again"),
          ),
        ],
      ),
    );
  }
}
