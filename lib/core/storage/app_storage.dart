import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/chat_models.dart';

class AppStorage {
  static Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  static Future<void> setHasLaunched() async {
    final prefs = await _prefs();
    await prefs.setBool('hasLaunched', true);
  }

  static Future<bool> getHasLaunched() async {
    final prefs = await _prefs();
    return prefs.getBool('hasLaunched') ?? false;
  }

  static Future<void> setDefaultMode(ChatMode mode) async {
    final prefs = await _prefs();
    await prefs.setString('defaultMode', mode.name);
  }

  static Future<ChatMode> getDefaultMode() async {
    final prefs = await _prefs();
    return prefs.getString('defaultMode') == 'offline' ? ChatMode.offline : ChatMode.online;
  }

  static Future<void> setModelDownloaded(bool value) async {
    final prefs = await _prefs();
    await prefs.setBool('modelDownloaded', value);
  }

  static Future<bool> getModelDownloaded() async {
    final prefs = await _prefs();
    return prefs.getBool('modelDownloaded') ?? false;
  }
}
