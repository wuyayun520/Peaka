class User {
  final String userId;
  final String name;
  final String userIcon;
  final String userIconBg;
  final String userCover;
  final String introduction;
  final String signa;
  final List<Post> posts;

  User({
    required this.userId,
    required this.name,
    required this.userIcon,
    required this.userIconBg,
    required this.userCover,
    required this.introduction,
    required this.signa,
    required this.posts,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      userIcon: json['userIcon'] ?? '',
      userIconBg: json['userIconBg'] ?? '',
      userCover: json['userCover'] ?? '',
      introduction: json['Introduction'] ?? '',
      signa: json['signa'] ?? '',
      posts: (json['post'] as List<dynamic>?)
          ?.map((post) => Post.fromJson(post))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'userIcon': userIcon,
      'userIconBg': userIconBg,
      'userCover': userCover,
      'Introduction': introduction,
      'signa': signa,
      'post': posts.map((post) => post.toJson()).toList(),
    };
  }
}

class Post {
  final String postId;
  final String postMsg;
  final String isPic;
  final String? postPic;
  final String? postPic2;
  final String? postPic3;
  final String? playVideo;
  final DateTime? createdAt;
  final int likes;
  final int comments;

  Post({
    required this.postId,
    required this.postMsg,
    required this.isPic,
    this.postPic,
    this.postPic2,
    this.postPic3,
    this.playVideo,
    this.createdAt,
    this.likes = 0,
    this.comments = 0,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postId: json['postId'] ?? '',
      postMsg: json['postmsg'] ?? '',
      isPic: json['isPic'] ?? '0',
      postPic: json['postpic'],
      postPic2: json['postpic2'],
      postPic3: json['postpic3'],
      playVideo: json['playVideo'],
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'])
          : DateTime.now(),
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'postmsg': postMsg,
      'isPic': isPic,
      'postpic': postPic,
      'postpic2': postPic2,
      'postpic3': postPic3,
      'playVideo': playVideo,
      'createdAt': createdAt?.toIso8601String(),
      'likes': likes,
      'comments': comments,
    };
  }

  List<String> get allImages {
    List<String> images = [];
    if (postPic != null) images.add(postPic!);
    if (postPic2 != null) images.add(postPic2!);
    if (postPic3 != null) images.add(postPic3!);
    return images;
  }

  bool get hasImages => isPic == '1' && allImages.isNotEmpty;
  bool get hasVideo => playVideo != null && playVideo!.isNotEmpty;
} 