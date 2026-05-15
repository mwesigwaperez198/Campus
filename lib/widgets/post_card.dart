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
  bool _isSaved = false;
  bool _showHeartBurst = false;
  int _localLikeCount = 0;

  static const _campusBlue = Color(0xFF0D47A1);
  static const _campusGold = Color(0xFFFFB300);

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

  void _toggleLike({bool fromDoubleTap = false}) {
    setState(() {
      if (!_isLiked) {
        _isLiked = true;
        _localLikeCount += 1;
      } else if (!fromDoubleTap) {
        _isLiked = false;
        _localLikeCount = _localLikeCount > 0 ? _localLikeCount - 1 : 0;
      }

      if (fromDoubleTap) {
        _showHeartBurst = true;
      }
    });

    if (fromDoubleTap) {
      Future.delayed(const Duration(milliseconds: 650), () {
        if (mounted) setState(() => _showHeartBurst = false);
      });
    }
  }

  void _showComingSoon(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label is coming soon.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final caption = widget.post.caption?.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PostHeader(
            authorName: widget.post.authorName ?? 'Campus Member',
            authorAvatar: widget.post.authorAvatar,
            createdAt: widget.post.createdAt,
            onProfileTap: _navigateToProfile,
          ),
          if (widget.post.imageUrl != null)
            _PostMedia(
              imageUrl: widget.post.imageUrl!,
              showHeartBurst: _showHeartBurst,
              onDoubleTap: () => _toggleLike(fromDoubleTap: true),
            )
          else
            _TextOnlyPostSurface(caption: caption),
          _PostActions(
            isLiked: _isLiked,
            isSaved: _isSaved,
            onLike: () => _toggleLike(),
            onComment: () => _showComingSoon('Comments'),
            onShare: () => _showComingSoon('Sharing'),
            onSave: () => setState(() => _isSaved = !_isSaved),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _localLikeCount == 0 ? 'Be the first to like this' : '$_localLikeCount like${_localLikeCount == 1 ? '' : 's'}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                if (caption != null && caption.isNotEmpty) ...[
                  const SizedBox(height: 7),
                  RichText(
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 14.5, height: 1.35),
                      children: [
                        TextSpan(
                          text: "${widget.post.authorName ?? 'campus_member'} ",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: caption),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _showComingSoon('Campus discussions'),
                  child: Text(
                    'View campus discussion',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  _relativeTime(widget.post.createdAt).toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _relativeTime(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt.toLocal());

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()}w ago';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}

class _PostHeader extends StatelessWidget {
  final String authorName;
  final String? authorAvatar;
  final DateTime createdAt;
  final VoidCallback onProfileTap;

  const _PostHeader({
    required this.authorName,
    required this.authorAvatar,
    required this.createdAt,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onProfileTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 4, 8),
        child: Row(
          children: [
            _GradientAvatar(imageUrl: authorAvatar, name: authorName),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.school_outlined, size: 13, color: _PostCardState._campusBlue),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Makerere University',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              _PostCardState._relativeTime(createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w600),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.more_horiz),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;

  const _GradientAvatar({required this.imageUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [_PostCardState._campusGold, Color(0xFFE91E63), _PostCardState._campusBlue],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: CircleAvatar(
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 18,
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
          backgroundColor: const Color(0xFFEAF1FB),
          child: imageUrl == null
              ? Text(
                  _initials(name),
                  style: const TextStyle(color: _PostCardState._campusBlue, fontWeight: FontWeight.w800),
                )
              : null,
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return 'CC';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
  }
}

class _PostMedia extends StatelessWidget {
  final String imageUrl;
  final bool showHeartBurst;
  final VoidCallback onDoubleTap;

  const _PostMedia({
    required this.imageUrl,
    required this.showHeartBurst,
    required this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: onDoubleTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded || frame != null) return child;
                return Container(
                  color: const Color(0xFFF4F7FB),
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFF4F7FB),
                  child: const Center(
                    child: Icon(Icons.broken_image_outlined, color: _PostCardState._campusBlue, size: 40),
                  ),
                );
              },
            ),
          ),
          AnimatedScale(
            scale: showHeartBurst ? 1 : 0,
            duration: const Duration(milliseconds: 170),
            curve: Curves.easeOutBack,
            child: AnimatedOpacity(
              opacity: showHeartBurst ? 1 : 0,
              duration: const Duration(milliseconds: 170),
              child: const Icon(Icons.favorite, color: Colors.white, size: 96, shadows: [
                Shadow(color: Colors.black38, blurRadius: 18),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextOnlyPostSurface extends StatelessWidget {
  final String? caption;

  const _TextOnlyPostSurface({required this.caption});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 190),
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEAF1FB), Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          caption == null || caption!.isEmpty ? 'Campus update' : caption!,
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _PostCardState._campusBlue,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.18,
          ),
        ),
      ),
    );
  }
}

class _PostActions extends StatelessWidget {
  final bool isLiked;
  final bool isSaved;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onSave;

  const _PostActions({
    required this.isLiked,
    required this.isSaved,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 3, 4, 0),
      child: Row(
        children: [
          AnimatedScale(
            scale: isLiked ? 1.1 : 1,
            duration: const Duration(milliseconds: 160),
            child: IconButton(
              visualDensity: VisualDensity.compact,
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? const Color(0xFFE53935) : Colors.black,
                size: 28,
              ),
              onPressed: onLike,
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.mode_comment_outlined, size: 27),
            onPressed: onComment,
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.send_outlined, size: 26),
            onPressed: onShare,
          ),
          const Spacer(),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border, size: 28),
            color: isSaved ? _PostCardState._campusBlue : Colors.black,
            onPressed: onSave,
          ),
        ],
      ),
    );
  }
}
