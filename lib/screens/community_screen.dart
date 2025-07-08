import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../models/user.dart';
import '../services/comment_service.dart';
import '../utils/theme.dart';
import 'post_detail_screen.dart';
import 'video_player_screen.dart';
import 'subscriptions_page.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with WidgetsBindingObserver {
  List<PostWithUser> _allPosts = [];
  bool _isLoading = true;
  final Map<String, VideoPlayerController> _videoControllers = {};
  Map<String, int> _commentCounts = {};
  bool _isVip = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPosts();
    _loadVipStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Dispose all video controllers
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 当应用恢复时刷新VIP状态
      _refreshVipStatus();
    }
  }

  Future<void> _loadVipStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isVip = prefs.getBool('isVip') ?? false;
    });
  }

  // 刷新VIP状态（从订阅页面返回时调用）
  Future<void> _refreshVipStatus() async {
    await _loadVipStatus();
  }

  void _loadPosts() async {
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.dataService.loadAllData();
    
    List<PostWithUser> posts = [];
    for (var user in appState.dataService.users) {
      for (var post in user.posts) {
        posts.add(PostWithUser(post: post, user: user));
        
        // Initialize video controller for video posts
        if (post.isPic == '0' && post.hasVideo) {
          _initializeVideoController(post.postId, post.playVideo!);
        }
      }
    }
    
    // Load comment counts
    final commentCounts = await CommentService.getAllCommentCounts();
    
    setState(() {
      _allPosts = posts;
      _commentCounts = commentCounts;
      _isLoading = false;
    });
  }

  void _initializeVideoController(String postId, String videoPath) {
    final controller = VideoPlayerController.asset(videoPath);
    _videoControllers[postId] = controller;
    
    controller.initialize().then((_) {
      // Seek to first frame and pause
      controller.seekTo(Duration.zero);
      controller.pause();
      if (mounted) {
        setState(() {});
      }
    }).catchError((error) {
      print('Error initializing video: $error');
    });
  }

  // 刷新评论数量
  void _refreshCommentCounts() async {
    final commentCounts = await CommentService.getAllCommentCounts();
    setState(() {
      _commentCounts = commentCounts;
    });
  }

  // VIP检查并处理帖子点击
  void _handlePostTap(PostWithUser postWithUser) async {
    if (!_isVip) {
      _showVipRequiredDialog();
    } else {
      await _navigateToPostDetail(postWithUser);
    }
  }

  // 显示VIP要求对话框
  void _showVipRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.terrain,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Premium Required',
              style: TextStyle(
                color: Color(0xFF1976D2),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'To view post details and interact with the community, you need Extreme Premium.',
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF1976D2).withValues(alpha: 0.3),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Premium Plans:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.schedule, color: Color(0xFF1976D2), size: 16),
                      SizedBox(width: 8),
                      Text('Weekly: \$12.99'),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_month, color: Color(0xFF1976D2), size: 16),
                      SizedBox(width: 8),
                      Text('Monthly: \$49.99'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionsPage(),
                ),
              );
              // 返回时刷新VIP状态
              _refreshVipStatus();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Get Premium',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 导航到帖子详情页面
  Future<void> _navigateToPostDetail(PostWithUser postWithUser) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(
          post: postWithUser.post,
          user: postWithUser.user,
        ),
      ),
    );
    // 返回时刷新评论数量
    _refreshCommentCounts();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/peaka_nor_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Community', style: TextStyle(color: Colors.black)),
          iconTheme: const IconThemeData(color: Colors.white),
       
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : _allPosts.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.groups_outlined,
                          size: 64,
                          color: Colors.white,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No posts yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Be the first to share your adventure!',
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 116),
                    child: MasonryGridView.builder(
                      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      itemCount: _allPosts.length,
                      itemBuilder: (context, index) {
                        return _buildPostCard(_allPosts[index]);
                      },
                    ),
                  ),
      ),
    );
  }

  Widget _buildPostCard(PostWithUser postWithUser) {
    final post = postWithUser.post;
    final user = postWithUser.user;
    final commentCount = _commentCounts[post.postId] ?? 0;
    
    return GestureDetector(
      onTap: () => _handlePostTap(postWithUser),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post Media (Images or Video) - moved to top
              if (post.isPic == '1' && post.hasImages)
                _buildSinglePostImage(post)
              else if (post.isPic == '0' && post.hasVideo)
                _buildPostVideo(post),
              
              // User Info Header
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                      backgroundImage: user.userIcon.isNotEmpty
                          ? AssetImage(user.userIcon)
                          : null,
                      child: user.userIcon.isEmpty
                          ? Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          if (user.signa.isNotEmpty)
                            Text(
                              user.signa,
                              style: TextStyle(
                                color: AppTheme.textSecondaryColor,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Post Content - limited to 2 lines
              if (post.postMsg.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Text(
                    post.postMsg,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              
              // Comment count display
              if (commentCount > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$commentCount ${commentCount == 1 ? 'comment' : 'comments'}',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSinglePostImage(Post post) {
    final images = post.allImages;
    
    if (images.isEmpty) return const SizedBox.shrink();
    
    // Only show the first image
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: Image.asset(
        images.first,
        width: double.infinity,
        height: 150,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 150,
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            child: const Center(
              child: Icon(
                Icons.image_not_supported,
                size: 40,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostImages(Post post) {
    final images = post.allImages;
    
    if (images.isEmpty) return const SizedBox.shrink();
    
    if (images.length == 1) {
      return ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: Image.asset(
          images.first,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: double.infinity,
              height: 150,
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              child: const Center(
                child: Icon(
                  Icons.image_not_supported,
                  size: 40,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            );
          },
        ),
      );
    }
    
    // Multiple images - show in a grid
    return SizedBox(
      height: 200,
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: images.length > 2 ? 2 : images.length,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              images[index],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 30,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostVideo(Post post) {
    final controller = _videoControllers[post.postId];
    
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video first frame as cover
            if (controller != null && controller.value.isInitialized)
              SizedBox(
                width: double.infinity,
                height: 150,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller.value.size.width,
                    height: controller.value.size.height,
                    child: VideoPlayer(controller),
                  ),
                ),
              )
            else
              // Fallback black background while loading
              Container(
                width: double.infinity,
                height: 150,
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            
            // Play button overlay
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                size: 30,
                color: Colors.white,
              ),
            ),
            
            // Video label
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Video',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, int count, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: AppTheme.textSecondaryColor,
          ),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Text(
              '$count',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class PostWithUser {
  final Post post;
  final User user;

  PostWithUser({required this.post, required this.user});
} 