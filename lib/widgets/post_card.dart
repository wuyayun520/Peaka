import 'package:flutter/material.dart';
import '../models/user.dart';
import '../utils/theme.dart';

class PostCard extends StatefulWidget {
  final User user;
  final Post post;
  final VoidCallback? onTap;

  const PostCard({
    super.key,
    required this.user,
    required this.post,
    this.onTap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;
  int likeCount = 0;

  @override
  void initState() {
    super.initState();
    likeCount = widget.post.likes;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info header
              _buildUserHeader(),
              
              if (widget.post.postMsg.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                _buildPostContent(),
              ],
              
              if (widget.post.hasImages) ...[
                const SizedBox(height: AppSpacing.sm),
                _buildImageContent(),
              ],
              
              if (widget.post.hasVideo) ...[
                const SizedBox(height: AppSpacing.sm),
                _buildVideoContent(),
              ],
              
              const SizedBox(height: AppSpacing.sm),
              _buildInteractionRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Row(
      children: [
        // User avatar
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
          ),
          child: widget.user.userIcon.isNotEmpty
              ? ClipOval(
                  child: Image.asset(
                    widget.user.userIcon,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        color: AppTheme.primaryColor,
                        size: 20,
                      );
                    },
                  ),
                )
              : const Icon(
                  Icons.person,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
        ),
        const SizedBox(width: AppSpacing.sm),
        
        // User name and post time
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.post.createdAt != null)
                Text(
                  _formatTimeAgo(widget.post.createdAt!),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
            ],
          ),
        ),
        
        // More options button
        IconButton(
          onPressed: () {
            // TODO: Show more options
          },
          icon: const Icon(Icons.more_vert),
          iconSize: 18,
        ),
      ],
    );
  }

  Widget _buildPostContent() {
    return Text(
      widget.post.postMsg,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }

  Widget _buildImageContent() {
    final images = widget.post.allImages;
    
    if (images.isEmpty) return const SizedBox.shrink();
    
    if (images.length == 1) {
      return _buildSingleImage(images.first);
    } else {
      return _buildMultipleImages(images);
    }
  }

  Widget _buildSingleImage(String imagePath) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(
                Icons.image_not_supported,
                size: 40,
                color: AppTheme.textSecondaryColor,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMultipleImages(List<String> images) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Container(
            width: 150,
            margin: EdgeInsets.only(right: index < images.length - 1 ? AppSpacing.sm : 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Image.asset(
                images[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 30,
                      color: AppTheme.textSecondaryColor,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoContent() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Image.asset(
              widget.post.playVideo ?? '',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.video_library,
                    size: 40,
                    color: AppTheme.textSecondaryColor,
                  ),
                );
              },
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionRow() {
    return Row(
      children: [
        // Like button
        InkWell(
          onTap: () {
            setState(() {
              if (isLiked) {
                likeCount--;
              } else {
                likeCount++;
              }
              isLiked = !isLiked;
            });
          },
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : AppTheme.textSecondaryColor,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  likeCount.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(width: AppSpacing.md),
        
        // Comment button
        InkWell(
          onTap: () {
            // TODO: Show comments
          },
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.comment_outlined,
                  color: AppTheme.textSecondaryColor,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  widget.post.comments.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const Spacer(),
        
        // Share button
        InkWell(
          onTap: () {
            // TODO: Share post
          },
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Icon(
              Icons.share_outlined,
              color: AppTheme.textSecondaryColor,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
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