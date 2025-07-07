import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/user.dart';
import 'package:video_player/video_player.dart';
import 'photo_preview_screen.dart';
import '../services/follow_service.dart';
import '../services/block_service.dart';
import 'chat_page.dart';
import 'post_detail_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final UserModel user;

  const UserProfileScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, VideoPlayerController> _videoControllers = {};
  final FollowService _followService = FollowService();
  final BlockService _blockService = BlockService();
  bool _isFollowing = false;
  bool _isBlocked = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeVideoControllers();
    _loadFollowStatus();
    _loadBlockStatus();
  }

  // Convert UserModel to User
  User _convertUserModelToUser(UserModel userModel) {
    return User(
      userId: userModel.userId,
      name: userModel.name,
      userIcon: userModel.userIcon,
      userIconBg: userModel.userIconBg,
      userCover: userModel.userCover,
      introduction: userModel.introduction,
      signa: userModel.signa,
      posts: userModel.posts.map((post) => Post(
        postId: post.postId,
        postMsg: post.postmsg,
        isPic: post.isPic,
        postPic: post.postpic,
        postPic2: post.postpic2,
        postPic3: post.postpic3,
        playVideo: post.playVideo,
      )).toList(),
    );
  }

  // Convert UserPost to Post
  Post _convertUserPostToPost(UserPost userPost) {
    return Post(
      postId: userPost.postId,
      postMsg: userPost.postmsg,
      isPic: userPost.isPic,
      postPic: userPost.postpic,
      postPic2: userPost.postpic2,
      postPic3: userPost.postpic3,
      playVideo: userPost.playVideo,
    );
  }

  Future<void> _initializeVideoControllers() async {
    for (var post in widget.user.posts) {
      if (post.isPic == "0" && post.playVideo != null) {
        final controller = VideoPlayerController.asset(post.playVideo!);
        _videoControllers[post.postId] = controller;
        await controller.initialize();
        // 确保在视频准备好后更新UI
        if (mounted) setState(() {});
      }
    }
  }

  Future<void> _loadFollowStatus() async {
    await _followService.init();
    final isFollowing = await _followService.isFollowing(widget.user.userId);
    if (mounted) {
      setState(() {
        _isFollowing = isFollowing;
      });
    }
  }

  Future<void> _loadBlockStatus() async {
    await _blockService.init();
    final isBlocked = await _blockService.isBlocked(widget.user.userId);
    if (mounted) {
      setState(() {
        _isBlocked = isBlocked;
      });
    }
  }

  Future<void> _toggleFollow() async {
    final newStatus = await _followService.toggleFollow(widget.user.userId);
    if (mounted) {
      setState(() {
        _isFollowing = newStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFollowing ? 'Following' : 'Unfollow'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _toggleBlock() async {
    final newStatus = await _blockService.toggleBlock(widget.user.userId);
    if (mounted) {
      setState(() {
        _isBlocked = newStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isBlocked ? 'Added ${widget.user.name} to blocklist' : 'Removed ${widget.user.name} from blocklist'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _startChat() async {
    if (await _blockService.isBlocked(widget.user.userId)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot chat with blocked users'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(user: _convertUserModelToUser(widget.user)),
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Spam'),
              onTap: () {
                Navigator.pop(context);
                _submitReport('Spam');
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning),
              title: const Text('Inappropriate Content'),
              onTap: () {
                Navigator.pop(context);
                _submitReport('Inappropriate Content');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_off),
              title: const Text('Impersonation'),
              onTap: () {
                Navigator.pop(context);
                _submitReport('Impersonation');
              },
            ),
            ListTile(
              leading: const Icon(Icons.error),
              title: const Text('Other'),
              onTap: () {
                Navigator.pop(context);
                _submitReport('Other');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submitReport(String reason) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report received, we will review it soon'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.report_problem,
                color: Colors.orange[700],
              ),
              title: const Text('Report User'),
              onTap: () {
                Navigator.pop(context);
                _showReportDialog();
              },
            ),
            ListTile(
              leading: Icon(
                _isBlocked ? Icons.person_add : Icons.person_off,
                color: _isBlocked ? Colors.blue : Colors.red,
              ),
              title: Text(_isBlocked ? 'Unblock User' : 'Block User'),
              onTap: () {
                Navigator.pop(context);
                _toggleBlock();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: _showMoreOptions,
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Cover Image with Gradient
                    ShaderMask(
                      shaderCallback: (rect) {
                        return LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black, Colors.transparent],
                        ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                      },
                      blendMode: BlendMode.dstIn,
                      child: Image.asset(
                        widget.user.userCover,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // User Info Container
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // User Avatar and Name
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage: AssetImage(widget.user.userIcon),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.user.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.user.signa,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // User Introduction
                            Text(
                              widget.user.introduction,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Action Buttons
                            if (!_isBlocked) Container(
                              width: screenWidth - 32,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 44,
                                      child: ElevatedButton.icon(
                                        onPressed: _toggleFollow,
                                        icon: Icon(
                                          _isFollowing ? Icons.check : Icons.add,
                                          size: 20,
                                        ),
                                        label: Text(
                                          _isFollowing ? 'Following' : 'Follow',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _isFollowing ? Colors.white24 : Colors.blue,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(22),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      height: 44,
                                      child: ElevatedButton.icon(
                                        onPressed: _startChat,
                                        icon: const Icon(
                                          Icons.chat_bubble_outline,
                                          size: 20,
                                        ),
                                        label: const Text(
                                          'Message',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white24,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(22),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Tab Bar
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue,
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.photo_library),
                      text: 'Photos',
                    ),
                    Tab(
                      icon: Icon(Icons.format_list_bulleted),
                      text: 'Posts',
                    ),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: Column(
          children: [
            if (!_isBlocked) Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Photos Tab
                  CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final photos = _getPhotos();
                              if (index >= photos.length) return null;
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PhotoPreviewScreen(
                                        imageUrls: photos,
                                        initialIndex: index,
                                      ),
                                    ),
                                  );
                                },
                                child: Hero(
                                  tag: photos[index],
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      photos[index],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: _getPhotos().length,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Posts Tab
                  CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index >= widget.user.posts.length) return null;
                              final post = widget.user.posts[index];
                              return GestureDetector(
                                onTap: () {
                                  // 跳转到帖子详情页面
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PostDetailScreen(
                                        post: _convertUserPostToPost(post),
                                        user: _convertUserModelToUser(widget.user),
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (post.isPic == "1" && post.postpic != null)
                                        ClipRRect(
                                          borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(8),
                                          ),
                                          child: Image.asset(
                                            post.postpic!,
                                            width: double.infinity,
                                            height: 200,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      else if (post.isPic == "0" && post.playVideo != null)
                                        GestureDetector(
                                          onTap: () {
                                            // TODO: 实现视频播放功能
                                            debugPrint('Playing video: ${post.playVideo}');
                                          },
                                          child: _buildVideoThumbnail(post.playVideo!, post.postId),
                                        ),
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              post.postmsg,
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            childCount: widget.user.posts.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ) else Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.block,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'User is blocked',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: _toggleBlock,
                    child: const Text('Unblock'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getPhotos() {
    List<String> photos = [];
    
    // 添加用户资料图片
    photos.add(widget.user.userIcon);  // 头像
    photos.add(widget.user.userCover); // 封面图片

    // 添加所有动态中的图片
    for (var post in widget.user.posts) {
      if (post.isPic == "1") {
        if (post.postpic != null && post.postpic!.isNotEmpty) {
          photos.add(post.postpic!);
        }
        if (post.postpic2 != null && post.postpic2!.isNotEmpty) {
          photos.add(post.postpic2!);
        }
        if (post.postpic3 != null && post.postpic3!.isNotEmpty) {
          photos.add(post.postpic3!);
        }
      }
    }
    
    // 过滤掉重复的图片
    return photos.toSet().toList();
  }

  Widget _buildVideoThumbnail(String videoPath, String postId) {
    final controller = _videoControllers[postId];
    if (controller == null || !controller.value.isInitialized) {
      return Container(
        height: 200,
        color: Colors.black12,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(8),
          ),
          child: SizedBox(
            height: 200,
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.cover,
              alignment: Alignment.center,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
          ),
        ),
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blue.withValues(alpha: 0.7),
          child: const Icon(
            Icons.play_arrow,
            size: 40,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
} 