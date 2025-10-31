import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static late SharedPreferences _prefs;
  static const String _sessionKey = 'current_user_id';

  // Panggil ini sekali di awal (biasanya di main)
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> createSession(String userId) async {
    await _prefs.setString(_sessionKey, userId);
  }

  static Future<String?> getSessionToken() async {
    return _prefs.getString(_sessionKey);
  }

  static Future<void> clearSession() async {
    await _prefs.remove(_sessionKey);
  }

  // Opsional: untuk backward compatibility
  static String getUserId() {
    return _prefs.getString(_sessionKey) ?? '';
  }
}
