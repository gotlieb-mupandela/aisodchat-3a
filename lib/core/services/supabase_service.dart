import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const _url = 'https://ukduanwmgoamukskndyh.supabase.co';
  static const _anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVrZHVhbndtZ29hbXVrc2tuZHloIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU3MzU3MTMsImV4cCI6MjA5MTMxMTcxM30.1xCSjMIrU61DiZnFBfn8jF92MJsMRlAObTK7TOfyndM';

  static Future<void> initialize() async {
    await Supabase.initialize(url: _url, anonKey: _anonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
