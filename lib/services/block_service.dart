import 'package:shared_preferences/shared_preferences.dart';

class BlockService {
  static const String _blockedUsersKey = 'blocked_users';
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> isBlocked(String userId) async {
    final blockedUsers = _prefs.getStringList(_blockedUsersKey) ?? [];
    return blockedUsers.contains(userId);
  }

  Future<bool> toggleBlock(String userId) async {
    List<String> blockedUsers = _prefs.getStringList(_blockedUsersKey) ?? [];
    
    if (blockedUsers.contains(userId)) {
      blockedUsers.remove(userId);
    } else {
      blockedUsers.add(userId);
    }
    
    await _prefs.setStringList(_blockedUsersKey, blockedUsers);
    return blockedUsers.contains(userId);
  }
} 