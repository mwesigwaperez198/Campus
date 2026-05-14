import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_model.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- POSTS / FEED ---
  Future<List<PostModel>> getFeed({int limit = 20, String? type}) async {
    var query = _supabase
        .from('posts')
        .select('*, profiles(full_name, avatar_url)');
    
    if (type != null) {
      query = query.eq('type', type);
    }
    
    final response = await query
        .order('created_at', ascending: false)
        .limit(limit);
    
    return (response as List).map((post) => PostModel.fromJson(post)).toList();
  }

  Future<void> createPost(String userId, String caption, {String? imageUrl, String type = 'standard'}) async {
    // Basic Nude/Sensitive Content Filter
    final sensitiveWords = ['nude', 'nsfw', 'porn']; 
    if (sensitiveWords.any((word) => caption.toLowerCase().contains(word))) {
      throw Exception("Post contains prohibited content.");
    }

    await _supabase.from('posts').insert({
      'author_id': userId,
      'caption': caption,
      'image_url': imageUrl,
      'type': type,
    });
  }

  // --- GROUPS ---
  Future<List<Map<String, dynamic>>> getGroups() async {
    return await _supabase.from('groups').select();
  }

  Future<void> createGroup(String name, String focus, {String? avatarUrl}) async {
    await _supabase.from('groups').insert({
      'name': name,
      'focus': focus,
      'avatar_url': avatarUrl,
    });
  }

  // --- POSTS ---
  Future<List<PostModel>> getUserPosts(String userId) async {
    final response = await _supabase
        .from('posts')
        .select('*, profiles(full_name, avatar_url)')
        .eq('author_id', userId)
        .order('created_at', ascending: false);
    return (response as List).map((post) => PostModel.fromJson(post)).toList();
  }

  // --- MESSAGES ---
  Future<void> sendMessage(String receiverId, String content) async {
    final senderId = _supabase.auth.currentUser!.id;
    await _supabase.from('messages').insert({
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
    });
  }

  Future<List<Map<String, dynamic>>> getMessagesWithUser(String otherUserId) async {
    final myId = _supabase.auth.currentUser!.id;
    final response = await _supabase
        .from('messages')
        .select()
        .or('and(sender_id.eq.$myId,receiver_id.eq.$otherUserId),and(sender_id.eq.$otherUserId,receiver_id.eq.$myId)')
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  // --- NOTIFICATIONS ---
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final userId = _supabase.auth.currentUser!.id;
    return await _supabase
        .from('notifications')
        .select('*, actor:profiles!actor_id(full_name, avatar_url)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }

  // --- EVENTS ---
  Future<List<Map<String, dynamic>>> getEvents() async {
    return await _supabase
        .from('events')
        .select('*, event_registrations(user_id)')
        .order('event_date', ascending: true);
  }

  Future<void> registerForEvent(String eventId) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase.from('event_registrations').insert({
      'event_id': eventId,
      'user_id': userId,
    });
  }

  Future<void> unregisterFromEvent(String eventId) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase
        .from('event_registrations')
        .delete()
        .eq('event_id', eventId)
        .eq('user_id', userId);
  }

  // --- DIRECTORY ---
  Future<List<Map<String, dynamic>>> getDirectory() async {
    return await _supabase.from('profiles').select().order('full_name', ascending: true);
  }

  // --- STORIES ---
  Future<void> createStory(String userId, String contentUrl) async {
    await _supabase.from('statuses').insert({
      'user_id': userId,
      'content_url': contentUrl,
      'expires_at': DateTime.now().toUtc().add(const Duration(hours: 24)).toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getStories() async {
    return await _supabase
        .from('statuses')
        .select('*, profiles(full_name, avatar_url)')
        .gt('expires_at', DateTime.now().toUtc().toIso8601String());
  }

  // --- REELS ---
  Future<void> createReel(String userId, String videoUrl, String caption) async {
    await createPost(userId, caption, imageUrl: videoUrl, type: 'reel');
  }

  // --- PROFILE ---
  Future<void> updateProfile(String userId, Map<String, dynamic> updates) async {
    await _supabase.from('profiles').update(updates).eq('id', userId);
  }

  Future<void> updateProfilePicture(String userId, String avatarUrl) async {
    await _supabase.from('profiles').update({'avatar_url': avatarUrl}).eq('id', userId);
  }

  // --- EVENTS ---
  Future<void> createEvent(Map<String, dynamic> eventData) async {
    await _supabase.from('events').insert(eventData);
  }
}
