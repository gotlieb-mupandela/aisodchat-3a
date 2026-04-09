import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> initialize() async {
    final url = dotenv.env['SUPABASE_URL'] ?? dotenv.env['EXPO_PUBLIC_SUPABASE_URL'] ?? '';
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? dotenv.env['EXPO_PUBLIC_SUPABASE_ANON_KEY'] ?? '';
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
