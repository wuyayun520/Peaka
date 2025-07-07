import 'package:shared_preferences/shared_preferences.dart';

class FollowService {
  static const String _followKeyPrefix = 'follow_user_';
  late SharedPreferences _prefs;
  
  // 单例模式
  static final FollowService _instance = FollowService._internal();
  factory FollowService() => _instance;
  FollowService._internal();

  // 初始化
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 检查是否关注
  Future<bool> isFollowing(String userId) async {
    return _prefs.getBool('${_followKeyPrefix}$userId') ?? false;
  }

  // 关注用户
  Future<void> followUser(String userId) async {
    await _prefs.setBool('${_followKeyPrefix}$userId', true);
  }

  // 取消关注
  Future<void> unfollowUser(String userId) async {
    await _prefs.setBool('${_followKeyPrefix}$userId', false);
  }

  // 切换关注状态
  Future<bool> toggleFollow(String userId) async {
    final isFollowing = await this.isFollowing(userId);
    if (isFollowing) {
      await unfollowUser(userId);
    } else {
      await followUser(userId);
    }
    return !isFollowing;
  }
} 