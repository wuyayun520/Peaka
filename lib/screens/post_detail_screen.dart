import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/user.dart';
import '../models/comment.dart';
import '../services/comment_service.dart';
import '../services/like_service.dart';
import '../services/report_service.dart';
import '../widgets/report_dialog.dart';
import '../utils/theme.dart';
import 'video_player_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;
  final User user;

  const PostDetailScreen({
    super.key,
    required this.post,
    required this.user,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  VideoPlayerController? _videoController;
  final TextEditingController _commentController = TextEditingController();
  List<Comment> _comments = [];
  bool _isLiked = false;
  int _likeCount = 0;
  bool _isLoadingComments = true;
  bool _isLoadingLikes = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _loadComments();
    _loadLikeData();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _initializeVideo() {
    if (widget.post.isPic == '0' && widget.post.hasVideo) {
      _videoController = VideoPlayerController.asset(widget.post.playVideo!);
      _videoController!.initialize().then((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  void _loadComments() async {
    try {
      final comments = await CommentService.getCommentsForPost(widget.post.postId);
      setState(() {
        _comments = comments;
        _isLoadingComments = false;
      });
    } catch (e) {
      print('Error loading comments: $e');
      setState(() {
        _isLoadingComments = false;
      });
    }
  }

  void _loadLikeData() async {
    try {
      final likeCount = await LikeService.getLikeCount(widget.post.postId);
      final isLiked = await LikeService.getLikeStatus(widget.post.postId, 'current_user');
      
      setState(() {
        _likeCount = likeCount;
        _isLiked = isLiked;
        _isLoadingLikes = false;
      });
    } catch (e) {
      print('Error loading like data: $e');
      setState(() {
        _isLoadingLikes = false;
      });
    }
  }

  void _toggleLike() async {
    try {
      final newCount = await LikeService.toggleLike(widget.post.postId, 'current_user');
      setState(() {
        _isLiked = !_isLiked;
        _likeCount = newCount;
      });
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  void _addComment() async {
    if (_commentController.text.trim().isNotEmpty) {
      try {
        await CommentService.addComment(widget.post.postId, _commentController.text.trim());
        _commentController.clear();
        // 重新加载评论
        _loadComments();
      } catch (e) {
        print('Error adding comment: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add comment')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: const Text(
          'Post Detail',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showReportDialog(
                context,
                targetId: widget.post.postId,
                reportType: ReportType.post,
                targetTitle: widget.post.postMsg.isNotEmpty 
                    ? widget.post.postMsg 
                    : '${widget.user.name}\'s post',
              );
            },
            icon: const Icon(Icons.report_outlined, color: Colors.red),
            tooltip: 'Report Post',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info
                  _buildUserInfo(),
                  
                  // Post Content
                  if (widget.post.postMsg.isNotEmpty)
                    _buildPostContent(),
                  
                  // Media (Images or Video)
                  if (widget.post.isPic == '1' && widget.post.hasImages)
                    _buildAllImages()
                  else if (widget.post.isPic == '0' && widget.post.hasVideo)
                    _buildVideo(),
                  
                  // Action Buttons
                  _buildActionButtons(),
                  
                  // Comments Section
                  _buildCommentsSection(),
                ],
              ),
            ),
          ),
          
          // Comment Input
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            backgroundImage: widget.user.userIcon.isNotEmpty
                ? AssetImage(widget.user.userIcon)
                : null,
            child: widget.user.userIcon.isEmpty
                ? Text(
                    widget.user.name.isNotEmpty ? widget.user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (widget.user.signa.isNotEmpty)
                  Text(
                    widget.user.signa,
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 14,
                    ),
                  ),
                Text(
                  _formatTimestamp(widget.post.createdAt ?? DateTime.now()),
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
    );
  }

  Widget _buildPostContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Text(
        widget.post.postMsg,
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildAllImages() {
    final images = widget.post.allImages;
    
    return Column(
      children: images.map((image) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Image.asset(
            image,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: 200,
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
      }).toList(),
    );
  }

  Widget _buildVideo() {
    if (_videoController == null) {
      return Container(
        width: double.infinity,
        height: 300,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        // 点击视频跳转到视频播放页面
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(
              post: widget.post,
              user: widget.user,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 300,
        color: Colors.black,
        child: _videoController!.value.isInitialized
            ? Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  ),
                  Container(
                    width: 60,
                    height: 60,
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
                ],
              )
            : const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggleLike,
            child: Row(
              children: [
                Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? Colors.red : AppTheme.textSecondaryColor,
                  size: 24,
                ),
                const SizedBox(width: 4),
                Text(
                  _isLoadingLikes ? '...' : '$_likeCount',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                color: AppTheme.textSecondaryColor,
                size: 24,
              ),
              const SizedBox(width: 4),
              Text(
                '${_comments.length}',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Spacer(),
         
        ],
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            'Comments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (_isLoadingComments)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_comments.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'No comments yet. Be the first to comment!',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 14,
              ),
            ),
          )
        else
          ..._comments.map((comment) => _buildCommentItem(comment)),
      ],
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            backgroundImage: comment.userAvatar.isNotEmpty
                ? AssetImage(comment.userAvatar)
                : null,
            child: comment.userAvatar.isEmpty
                ? Text(
                    comment.userName.isNotEmpty ? comment.userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimestamp(comment.timestamp),
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (comment.userId != 'current_user') // 不能举报自己的评论
            GestureDetector(
              onTap: () {
                showReportDialog(
                  context,
                  targetId: comment.id,
                  reportType: ReportType.comment,
                  targetTitle: comment.content,
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.report_outlined,
                  size: 16,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppTheme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: AppTheme.dividerColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: AppTheme.dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: AppTheme.primaryColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _addComment(),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _addComment,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
} 