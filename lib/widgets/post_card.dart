import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../screens/directory/profile_view_screen.dart';
import '../models/user_model.dart';

class PostCard extends StatefulWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isLiked = false;

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileViewScreen(
          user: UserModel(
            id: widget.post.userId,
            fullName: widget.post.authorName ?? 'User',
            email: '',
            role: UserRole.student,
            avatarUrl: widget.post.authorAvatar,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      elevation: 0,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            onTap: _navigateToProfile,
            leading: CircleAvatar(
              backgroundImage: widget.post.authorAvatar != null 
                ? NetworkImage(widget.post.authorAvatar!) 
                : null,
              child: widget.post.authorAvatar == null ? const Icon(Icons.person) : null,
            ),
            title: Text(
              widget.post.authorName ?? 'Unknown User',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "${widget.post.createdAt.day}/${widget.post.createdAt.month}/${widget.post.createdAt.year}",
              style: const TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.more_horiz),
          ),
          if (widget.post.imageUrl != null)
            Image.network(
              widget.post.imageUrl!,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? Colors.red : Colors.black,
                      ),
                      onPressed: () {
                        setState(() => _isLiked = !_isLiked);
                        // In a real app, you'd call _dbService.toggleLike(widget.post.id)
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.mode_comment_outlined),
                      onPressed: () {
                        // Open comments
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.send_outlined),
                      onPressed: () {
                        // Share post
                      },
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.bookmark_border),
                      onPressed: () {
                        // Save post
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (widget.post.caption != null)
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: "${widget.post.authorName ?? 'user'} ",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: widget.post.caption),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
