import 'package:flutter/material.dart';

class StoryCircle extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final bool isMe;
  final VoidCallback onTap;

  const StoryCircle({
    super.key,
    this.imageUrl,
    required this.name,
    this.isMe = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isMe
                        ? null
                        : const LinearGradient(
                            colors: [Colors.orange, Colors.red, Colors.purple],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                    color: isMe ? Colors.grey[300] : null,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
                      child: imageUrl == null ? const Icon(Icons.person) : null,
                    ),
                  ),
                ),
                if (isMe)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 18),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              isMe ? "Your Story" : name,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
