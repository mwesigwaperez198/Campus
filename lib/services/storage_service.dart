import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> uploadMedia(String bucket, File file) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}${p.extension(file.path)}';
    final path = 'uploads/$fileName';

    await _supabase.storage.from(bucket).upload(path, file);
    return _supabase.storage.from(bucket).getPublicUrl(path);
  }
}
