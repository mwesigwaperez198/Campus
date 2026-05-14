import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/storage_service.dart';
import '../../models/post_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../reels/create_reel_screen.dart';
import '../home/create_post_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();
  final _dbService = DatabaseService();
  final _storageService = StorageService();
  final _picker = ImagePicker();
  bool _isUploading = false;
  Map<String, dynamic>? _userProfile;
  List<PostModel> _userPosts = [];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final profile = await _authService.getUserProfile(user.id);
      final posts = await _dbService.getUserPosts(user.id);
      if (mounted) {
        setState(() {
          _userProfile = profile?.toJson();
          _userPosts = posts;
        });
      }
    }
  }

  Future<void> _updateProfilePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _isUploading = true);
      try {
        final userId = Supabase.instance.client.auth.currentUser!.id;
        final url = await _storageService.uploadMedia('avatars', File(image.path));
        await _dbService.updateProfilePicture(userId, url);
        await _loadUserProfile();
      } catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _userProfile?['full_name']);
    final bioController = TextEditingController(text: _userProfile?['bio']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Full Name")),
            TextField(controller: bioController, decoration: const InputDecoration(labelText: "Bio"), maxLines: 3),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await _dbService.updateProfile(Supabase.instance.client.auth.currentUser!.id, {
                'full_name': nameController.text.trim(),
                'bio': bioController.text.trim(),
              });
              await _loadUserProfile();
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _userProfile?['full_name']?.toLowerCase().replaceAll(" ", "_") ?? "profile",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.add_box_outlined), onPressed: _showCreateMenu),
          IconButton(icon: const Icon(Icons.menu), onPressed: _showAdvancedSettings),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Stats Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _updateProfilePicture,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: _userProfile?['avatar_url'] != null ? NetworkImage(_userProfile!['avatar_url']) : null,
                          child: _userProfile?['avatar_url'] == null ? const Icon(Icons.person, size: 40) : null,
                        ),
                        if (_isUploading) const Positioned.fill(child: CircularProgressIndicator()),
                        Positioned(bottom: 0, right: 0, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Color(0xFF0D47A1), shape: BoxShape.circle), child: const Icon(Icons.add, color: Colors.white, size: 14))),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStat(_userPosts.length.toString(), "Posts"),
                        _buildStat("1.5k", "Followers"),
                        _buildStat("850", "Following"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Bio
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_userProfile?['full_name'] ?? "User", style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Text("Makerere University", style: TextStyle(color: Colors.grey)),
                  Text(_userProfile?['bio'] ?? "Connecting the future of Makerere."),
                ],
              ),
            ),
            // Buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: _showEditProfileDialog, style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text("Edit Profile", style: TextStyle(color: Colors.black)))),
                  const SizedBox(width: 8),
                  Expanded(child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text("Share Profile", style: TextStyle(color: Colors.black)))),
                ],
              ),
            ),
            // Grid
            const Divider(),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _userPosts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
              itemBuilder: (context, index) {
                final post = _userPosts[index];
                return Container(
                  color: Colors.grey[100],
                  child: post.imageUrl != null ? Image.network(post.imageUrl!, fit: BoxFit.cover) : const Icon(Icons.image_outlined),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String val, String label) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  void _showCreateMenu() {
    showModalBottomSheet(context: context, builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.video_library), 
          title: const Text("Reel"), 
          onTap: () async {
            Navigator.pop(context);
            final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
            if (video != null && mounted) {
              await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateReelScreen(videoFile: video)));
              _loadUserProfile();
            }
          }
        ),
        ListTile(
          leading: const Icon(Icons.grid_on), 
          title: const Text("Post"), 
          onTap: () async {
            Navigator.pop(context);
            await Navigator.push(context, MaterialPageRoute(builder: (context) => const CreatePostScreen()));
            _loadUserProfile();
          }
        ),
        ListTile(
          leading: const Icon(Icons.add_circle_outline), 
          title: const Text("Story"), 
          onTap: () {
            Navigator.pop(context);
            _pickAndUploadStory();
          }
        ),
      ],
    ));
  }

  Future<void> _pickAndUploadStory() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _isUploading = true);
      try {
        final userId = Supabase.instance.client.auth.currentUser!.id;
        final url = await _storageService.uploadMedia('stories', File(image.path));
        await _dbService.createStory(userId, url);
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Story uploaded!")));
      } catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  void _showAdvancedSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          bool isPrivate = _userProfile?['is_private'] ?? false;
          
          return Container(
            height: MediaQuery.of(context).size.height * 0.6,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Settings and Privacy", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                SwitchListTile(
                  secondary: const Icon(Icons.lock_outline, color: Color(0xFF0D47A1)),
                  title: const Text("Account Privacy", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Set your profile to private"),
                  value: isPrivate,
                  onChanged: (bool value) async {
                    try {
                      final userId = Supabase.instance.client.auth.currentUser!.id;
                      await _dbService.updateProfile(userId, {'is_private': value});
                      await _loadUserProfile();
                      if (mounted) setModalState(() {});
                    } catch (e) {
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                    }
                  },
                ),
                _buildAdvancedTile(Icons.notifications_none, "Notifications", "Manage alerts and sounds"),
                _buildAdvancedTile(Icons.security, "Security", "Passwords and verification"),
                _buildAdvancedTile(Icons.help_center_outlined, "Help Center", "novaratechafrica@gmail.com"),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _authService.signOut();
                      if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/authChoice', (route) => false);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white),
                    child: const Text("Log Out"),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildAdvancedTile(IconData icon, String title, String sub) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF0D47A1)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(sub),
      trailing: const Icon(Icons.chevron_right, size: 18),
    );
  }
}
