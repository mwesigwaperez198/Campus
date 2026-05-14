import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/database_service.dart';
import '../../models/post_model.dart';
import '../directory/profile_view_screen.dart';
import '../../models/user_model.dart';
import 'reel_video_player.dart';
import 'create_reel_screen.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final _dbService = DatabaseService();
  String _searchQuery = "";
  Key _feedKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          FutureBuilder<List<PostModel>>(
            key: _feedKey,
            future: _dbService.getFeed(type: 'reel'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }
              final reels = snapshot.data?.where((r) => 
                (r.caption?.toLowerCase().contains(_searchQuery) ?? false) ||
                (r.authorName?.toLowerCase().contains(_searchQuery) ?? false)
              ).toList() ?? [];

              if (reels.isEmpty) {
                return const Center(child: Text("No reels found", style: TextStyle(color: Colors.white)));
              }

              return PageView.builder(
                scrollDirection: Axis.vertical,
                itemCount: reels.length,
                itemBuilder: (context, index) {
                  final reel = reels[index];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // Video Player
                      if (reel.imageUrl != null)
                        ReelVideoPlayer(videoUrl: reel.imageUrl!)
                      else
                        Container(
                          color: Colors.black,
                          child: const Center(child: Icon(Icons.error, color: Colors.white)),
                        ),
                      
                      // UI Overlay
                      Positioned(
                        bottom: 40,
                        left: 20,
                        right: 80,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileViewScreen(user: UserModel(
                                  id: reel.userId,
                                  fullName: reel.authorName ?? 'User',
                                  email: '',
                                  role: UserRole.student,
                                  avatarUrl: reel.authorAvatar,
                                ))));
                              },
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundImage: reel.authorAvatar != null ? NetworkImage(reel.authorAvatar!) : null,
                                    child: reel.authorAvatar == null ? const Icon(Icons.person) : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(reel.authorName ?? "@user", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(reel.caption ?? "", style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 60,
                        right: 20,
                        child: Column(
                          children: [
                            _buildReelAction(Icons.favorite_border, "Like"),
                            _buildReelAction(Icons.comment, "Comm"),
                            _buildReelAction(Icons.share, "Share"),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          // Search Bar
          Positioned(
            top: 50,
            left: 20,
            right: 80,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Search reels...",
                  hintStyle: TextStyle(color: Colors.white70),
                  icon: Icon(Icons.search, color: Colors.white),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          // Create Reel Button
          Positioned(
            top: 50,
            right: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white.withAlpha(51),
              child: IconButton(
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                onPressed: _createNewReel,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createNewReel() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.camera);
    
    if (video != null && mounted) {
      final bool? published = await Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => CreateReelScreen(videoFile: video))
      );
      
      if (published == true) {
        setState(() {
          _feedKey = UniqueKey();
        });
      }
    }
  }

  Widget _buildReelAction(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}
