class UserPost {
  final String postId;
  final String postmsg;
  final String isPic;
  final String? postpic;
  final String? postpic2;
  final String? postpic3;
  final String? playVideo;

  UserPost({
    required this.postId,
    required this.postmsg,
    required this.isPic,
    this.postpic,
    this.postpic2,
    this.postpic3,
    this.playVideo,
  });

  factory UserPost.fromJson(Map<String, dynamic> json) {
    return UserPost(
      postId: json['postId'] as String,
      postmsg: json['postmsg'] as String,
      isPic: json['isPic'] as String,
      postpic: json['postpic'] as String?,
      postpic2: json['postpic2'] as String?,
      postpic3: json['postpic3'] as String?,
      playVideo: json['playVideo'] as String?,
    );
  }
}

class UserModel {
  final String userId;
  final String name;
  final String userIcon;
  final String userIconBg;
  final String userCover;
  final String introduction;
  final String signa;
  final List<UserPost> posts;

  UserModel({
    required this.userId,
    required this.name,
    required this.userIcon,
    required this.userIconBg,
    required this.userCover,
    required this.introduction,
    required this.signa,
    required this.posts,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as String,
      name: json['name'] as String,
      userIcon: json['userIcon'] as String,
      userIconBg: json['userIconBg'] as String,
      userCover: json['userCover'] as String,
      introduction: json['Introduction'] as String,
      signa: json['signa'] as String,
      posts: (json['post'] as List<dynamic>)
          .map((post) => UserPost.fromJson(post as Map<String, dynamic>))
          .toList(),
    );
  }
} 