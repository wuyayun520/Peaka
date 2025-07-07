import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class LikeService {
  static const String _likeCountsKey = 'like_counts';
  static const String _likeStatusKey = 'like_status';
  
  // 获取点赞数量
  static Future<int> getLikeCount(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    final likeCountsJson = prefs.getString(_likeCountsKey);
    
    if (likeCountsJson != null) {
      final Map<String, dynamic> likeCounts = json.decode(likeCountsJson);
      if (likeCounts.containsKey(postId)) {
        return likeCounts[postId] as int;
      }
    }
    
    // 如果没有记录，生成随机点赞数量（100-500）
    final random = Random();
    final randomCount = random.nextInt(401) + 100; // 100-500
    await _saveLikeCount(postId, randomCount);
    return randomCount;
  }
  
  // 保存点赞数量
  static Future<void> _saveLikeCount(String postId, int count) async {
    final prefs = await SharedPreferences.getInstance();
    final likeCountsJson = prefs.getString(_likeCountsKey);
    
    Map<String, dynamic> likeCounts = {};
    if (likeCountsJson != null) {
      likeCounts = json.decode(likeCountsJson);
    }
    
    likeCounts[postId] = count;
    await prefs.setString(_likeCountsKey, json.encode(likeCounts));
  }
  
  // 获取点赞状态
  static Future<bool> getLikeStatus(String postId, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final likeStatusJson = prefs.getString(_likeStatusKey);
    
    if (likeStatusJson != null) {
      final Map<String, dynamic> likeStatus = json.decode(likeStatusJson);
      final key = '${postId}_$userId';
      return likeStatus[key] ?? false;
    }
    
    return false;
  }
  
  // 切换点赞状态
  static Future<int> toggleLike(String postId, String userId) async {
    final currentStatus = await getLikeStatus(postId, userId);
    final currentCount = await getLikeCount(postId);
    
    final newStatus = !currentStatus;
    final newCount = newStatus ? currentCount + 1 : currentCount - 1;
    
    await _saveLikeStatus(postId, userId, newStatus);
    await _saveLikeCount(postId, newCount);
    
    return newCount;
  }
  
  // 保存点赞状态
  static Future<void> _saveLikeStatus(String postId, String userId, bool isLiked) async {
    final prefs = await SharedPreferences.getInstance();
    final likeStatusJson = prefs.getString(_likeStatusKey);
    
    Map<String, dynamic> likeStatus = {};
    if (likeStatusJson != null) {
      likeStatus = json.decode(likeStatusJson);
    }
    
    final key = '${postId}_$userId';
    likeStatus[key] = isLiked;
    await prefs.setString(_likeStatusKey, json.encode(likeStatus));
  }
  
  // 批量获取点赞数量（用于列表页面）
  static Future<Map<String, int>> getAllLikeCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final likeCountsJson = prefs.getString(_likeCountsKey);
    
    if (likeCountsJson != null) {
      final Map<String, dynamic> likeCounts = json.decode(likeCountsJson);
      return likeCounts.map((key, value) => MapEntry(key, value as int));
    }
    
    return {};
  }
  
  // 清除所有点赞数据（用于测试）
  static Future<void> clearAllLikes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_likeCountsKey);
    await prefs.remove(_likeStatusKey);
  }
} 