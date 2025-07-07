import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/comment.dart';

class CommentService {
  static const String _commentsKey = 'post_comments';
  static const String _commentCountKey = 'comment_counts';
  
  // 运动相关的评论模板
  static const List<String> _sportComments = [
    'Amazing workout! Keep it up! 💪',
    'This looks like an incredible adventure!',
    'Great form! You\'re inspiring me to get active too.',
    'What a beautiful location for exercise!',
    'Your dedication is truly motivating!',
    'Love seeing people stay active and healthy!',
    'This trail looks challenging but rewarding!',
    'Perfect weather for outdoor activities!',
    'You make it look so easy! Goals! 🏃‍♂️',
    'Nature is the best gym! Beautiful scenery.',
    'Keep pushing your limits! You\'re doing great!',
    'This is why I love outdoor sports!',
    'Your energy is contagious! 🔥',
    'What equipment do you recommend for beginners?',
    'How long did this workout take you?',
    'The view is breathtaking! Where is this?',
    'You\'re living your best life! Respect! 👏',
    'This makes me want to start my fitness journey!',
    'Such a peaceful place to exercise.',
    'Your progress is incredible! Keep going!',
    'I need to find spots like this near me!',
    'The sunset/sunrise makes this even more special!',
    'You\'re proof that consistency pays off!',
    'This is the motivation I needed today!',
    'Adventure and fitness combined - perfect! 🌟'
  ];

  static const List<String> _userNames = [
    'FitnessFan',
    'AdventureSeeker',
    'NatureLover',
    'SportyLife',
    'ActiveExplorer',
    'HealthyVibes',
    'OutdoorEnthusiast',
    'FitnessMotivator',
    'TrailRunner',
    'YogaWarrior',
    'CyclingPro',
    'HikingBuddy',
    'SwimmerLife',
    'ClimbingAddict',
    'RunnerHigh',
    'FitnessJourney',
    'HealthyMindset',
    'ActiveLifestyle',
    'SportsMinded',
    'WellnessSeeker'
  ];

  static const List<String> _userAvatars = [
    'assets/images/picket/1/user_1.jpg',
    'assets/images/picket/2/user_1.jpg',
    'assets/images/picket/3/user_1.jpg',
    'assets/images/picket/4/user_1.jpg',
    'assets/images/picket/5/user_1.jpg',
  ];

  // 获取帖子的评论列表
  static Future<List<Comment>> getCommentsForPost(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    final commentsJson = prefs.getString('${_commentsKey}_$postId');
    
    if (commentsJson != null) {
      final List<dynamic> commentsList = json.decode(commentsJson);
      return commentsList.map((json) => Comment.fromJson(json)).toList();
    }
    
    // 如果没有评论，生成随机评论
    return await _generateRandomComments(postId);
  }

  // 生成随机评论
  static Future<List<Comment>> _generateRandomComments(String postId) async {
    final random = Random();
    final commentCount = random.nextInt(5) + 1; // 1-5条评论
    final List<Comment> comments = [];
    
    for (int i = 0; i < commentCount; i++) {
      final comment = Comment(
        id: '${postId}_generated_$i',
        postId: postId,
        userId: 'user_${random.nextInt(1000)}',
        userName: _userNames[random.nextInt(_userNames.length)],
        userAvatar: _userAvatars[random.nextInt(_userAvatars.length)],
        content: _sportComments[random.nextInt(_sportComments.length)],
        timestamp: DateTime.now().subtract(Duration(
          hours: random.nextInt(24),
          minutes: random.nextInt(60),
        )),
      );
      comments.add(comment);
    }
    
    // 按时间排序（最新的在前）
    comments.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    // 保存到本地
    await _saveCommentsForPost(postId, comments);
    await _updateCommentCount(postId, comments.length);
    
    return comments;
  }

  // 添加新评论
  static Future<void> addComment(String postId, String content) async {
    final comments = await getCommentsForPost(postId);
    
    final newComment = Comment(
      id: '${postId}_user_${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      userId: 'current_user',
      userName: 'You',
      userAvatar: '',
      content: content,
      timestamp: DateTime.now(),
    );
    
    comments.insert(0, newComment); // 插入到最前面
    
    await _saveCommentsForPost(postId, comments);
    await _updateCommentCount(postId, comments.length);
  }

  // 保存评论到本地
  static Future<void> _saveCommentsForPost(String postId, List<Comment> comments) async {
    final prefs = await SharedPreferences.getInstance();
    final commentsJson = json.encode(comments.map((c) => c.toJson()).toList());
    await prefs.setString('${_commentsKey}_$postId', commentsJson);
  }

  // 更新评论数量
  static Future<void> _updateCommentCount(String postId, int count) async {
    final prefs = await SharedPreferences.getInstance();
    final counts = await _getCommentCounts();
    counts[postId] = count;
    await prefs.setString(_commentCountKey, json.encode(counts));
  }

  // 获取评论数量
  static Future<int> getCommentCount(String postId) async {
    final counts = await _getCommentCounts();
    return counts[postId] ?? 0;
  }

  // 获取所有评论数量
  static Future<Map<String, int>> _getCommentCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final countsJson = prefs.getString(_commentCountKey);
    
    if (countsJson != null) {
      final Map<String, dynamic> counts = json.decode(countsJson);
      return counts.map((key, value) => MapEntry(key, value as int));
    }
    
    return {};
  }

  // 获取所有评论数量（用于社区页面显示）
  static Future<Map<String, int>> getAllCommentCounts() async {
    return await _getCommentCounts();
  }

  // 清除所有评论数据（用于测试）
  static Future<void> clearAllComments() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_commentsKey) || key == _commentCountKey);
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
} 