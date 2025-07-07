import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../utils/theme.dart';
import 'dart:math';
import '../screens/activity_detail_screen.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;

  const ActivityCard({Key? key, required this.activity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 随机取3个不同的头像图片
    final List<String> avatars = [
      'assets/images/picket/1/user_1.jpg',
      'assets/images/picket/2/user_2.jpg',
      'assets/images/picket/3/user_3.jpg',
      'assets/images/picket/4/user_1.jpg',
      'assets/images/picket/5/user_2.jpg',
      'assets/images/picket/6/user_3.jpg',
      'assets/images/picket/7/user_1.jpg',
      'assets/images/picket/8/user_2.jpg',
      'assets/images/picket/9/user_3.jpg',
      'assets/images/picket/10/user_1.jpg',
    ];
    final random = Random(activity.id.hashCode);
    final Set<int> indices = {};
    while (indices.length < 3) {
      indices.add(random.nextInt(avatars.length));
    }
    final List<String> selectedAvatars = indices.map((i) => avatars[i]).toList();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActivityDetailScreen(activity: activity),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                  child: Image.asset(
                    activity.images,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                      activity.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                          Shadow(
                            color: Colors.black38,
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  ...selectedAvatars.asMap().entries.map((entry) => Padding(
                    padding: EdgeInsets.only(right: entry.key < 2 ? 4 : 0),
                    child: CircleAvatar(
                      radius: 12,
                      backgroundImage: AssetImage(entry.value),
                    ),
                  )),
                  const SizedBox(width: 8),
                  Text(
                    '${activity.maxParticipants} followers',
                    style: const TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 15,
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: const [
                        Text('🙌', style: TextStyle(fontSize: 18)),
                        SizedBox(width: 6),
                        Text(
                          'Wants Join',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
} 