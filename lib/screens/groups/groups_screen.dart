import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../models/group_model.dart';
import 'create_group_screen.dart';
import 'group_chat_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("COMMUNITIES", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateGroupScreen())),
        backgroundColor: const Color(0xFF0D47A1),
        child: const Icon(Icons.group_add, color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _dbService.getGroups(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No communities found."));
          }

          final groups = snapshot.data!.map((e) => GroupModel.fromJson(e)).toList();

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: groups.length,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 80),
            itemBuilder: (context, index) {
              final group = groups[index];
              return ListTile(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GroupChatScreen(group: group)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[100],
                  backgroundImage: group.imageUrl != null ? NetworkImage(group.imageUrl!) : null,
                  child: group.imageUrl == null ? const Icon(Icons.groups, color: Color(0xFF0D47A1), size: 30) : null,
                ),
                title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Text(group.description ?? "Active campus community", maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
              );
            },
          );
        },
      ),
    );
  }
}
