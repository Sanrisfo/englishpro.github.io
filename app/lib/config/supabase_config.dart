import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase Configuration for EnglishPro
class SupabaseConfig {
  /// Initialize Supabase
  static Future<void> initialize() async {
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception(
        'Missing Supabase credentials in .env file. '
        'Please add SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: false,
    );
  }
}

/// Global helper to access Supabase client
final supabase = Supabase.instance.client;
