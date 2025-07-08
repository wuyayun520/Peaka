import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../utils/theme.dart';
import '../widgets/sport_card.dart';
import '../widgets/sport_type_selector.dart';
import '../widgets/activity_card.dart';
import '../models/activity.dart';
import '../services/user_service.dart';
import 'user_profile_screen.dart';
import 'in_app_purchases_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserService _userService = UserService();
  int _selectedTypeIndex = 1; // 默认Skydiving
  List<Activity> _activities = [];
  bool _loadingActivities = false;
  int _sportsPoints = 0;
  Set<String> _unlockedUsers = {};
  
  static const int _viewUserCost = 5; // 查看用户需要消耗的金币数

  final List<String> _activityJsonFiles = [
    'assets/data/surfing_activities.json',
    'assets/data/skydiving_activities.json',
    'assets/data/climbing_activities.json',
    'assets/data/diving_activities.json',
  ];

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadActivities(_selectedTypeIndex);
    _loadSportsPoints();
    _loadUnlockedUsers();
  }

  Future<void> _loadUsers() async {
    await _userService.loadUsers();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadActivities(int typeIndex) async {
    setState(() {
      _loadingActivities = true;
      _activities = [];
    });
    final file = _activityJsonFiles[typeIndex];
    final jsonStr = await rootBundle.loadString(file);
    final Map<String, dynamic> data = json.decode(jsonStr);
    // 取第一个key的value（如 surfing_activities）
    final List<dynamic> list = data.values.first as List<dynamic>;
    setState(() {
      _activities = list.map((e) => Activity.fromJson(e)).toList();
      _loadingActivities = false;
    });
  }

  Future<void> _loadSportsPoints() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sportsPoints = prefs.getInt('sportsPoints') ?? 0;
    });
  }

  Future<void> _loadUnlockedUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? unlockedList = prefs.getStringList('unlockedUsers');
    setState(() {
      _unlockedUsers = unlockedList?.toSet() ?? {};
    });
  }

  Future<void> _saveSportsPoints(int points) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sportsPoints', points);
    setState(() {
      _sportsPoints = points;
    });
  }

  Future<void> _saveUnlockedUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('unlockedUsers', _unlockedUsers.toList());
  }

  Future<void> _handleUserCardTap(user) async {
    // 检查用户是否已解锁
    if (_unlockedUsers.contains(user.name)) {
      // 已解锁，直接跳转
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfileScreen(user: user),
        ),
      );
      return;
    }

    // 检查金币是否足够
    if (_sportsPoints >= _viewUserCost) {
      // 金币足够，消耗金币并解锁用户
      await _saveSportsPoints(_sportsPoints - _viewUserCost);
      _unlockedUsers.add(user.name);
      await _saveUnlockedUsers();
      
      // 显示消耗金币提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unlocked ${user.name}! -$_viewUserCost Sports Points'),
            backgroundColor: const Color(0xFF1976D2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      
      // 跳转到用户详情页
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfileScreen(user: user),
        ),
      );
    } else {
      // 金币不足，显示提示对话框
      _showInsufficientCoinsDialog(user);
    }
  }

  void _showInsufficientCoinsDialog(user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.sports,
                color: const Color(0xFF1976D2),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Insufficient Sports Points',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You need $_viewUserCost Sports Points to view ${user.name}\'s profile.',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1976D2).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Current Balance:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$_sportsPoints Sports Points',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Would you like to purchase more Sports Points?',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 跳转到内购页面
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InAppPurchasesPage(),
                  ),
                ).then((_) {
                  // 从内购页面返回后，重新加载金币数量
                  _loadSportsPoints();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Purchase',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/peaka_nor_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Title Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'POPULAR SPORTS',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.black,
                          letterSpacing: 2,
                          height: 1.2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // 显示金币余额
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1976D2).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF1976D2).withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.sports,
                              size: 16,
                              color: const Color(0xFF1976D2),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$_sportsPoints',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1976D2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Sports Cards Carousel
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 24),
                sliver: SliverToBoxAdapter(
                  child: _userService.users.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : Container(
                          width: double.infinity,
                          child: carousel.CarouselSlider(
                            options: carousel.CarouselOptions(
                              height: 400,
                              enlargeCenterPage: true,
                              enlargeFactor: 0.25,
                              autoPlay: true,
                              aspectRatio: 16 / 9,
                              autoPlayCurve: Curves.fastOutSlowIn,
                              enableInfiniteScroll: true,
                              autoPlayAnimationDuration: const Duration(milliseconds: 800),
                              viewportFraction: 0.68,
                            ),
                            items: _userService.users.map((user) {
                              final isUnlocked = _unlockedUsers.contains(user.name);
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                child: Stack(
                                  children: [
                                    SportCard(
                                      title: user.name,
                                      subtitle: user.signa,
                                      description: user.introduction,
                                      imageUrl: user.userCover,
                                      onTap: () => _handleUserCardTap(user),
                                    ),
                                    // 解锁状态指示器
                                    if (isUnlocked)
                                      Positioned(
                                        top: 12,
                                        right: 12,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.2),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    // 未解锁状态指示器
                                    if (!isUnlocked)
                                      Positioned(
                                        top: 12,
                                        right: 12,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1976D2),
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.2),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.sports,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                '$_viewUserCost',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                ),
              ),

              // Activities Title
              SliverPadding(
                padding: const EdgeInsets.only(left: 20),
                sliver: SliverToBoxAdapter(
                  child: Image.asset(
                    'assets/type/peaka_home_activities.png',
                    height: 24,
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),

              // Sport Type Selector
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: SportTypeSelector(
                    onTypeSelected: (index) {
                      setState(() {
                        _selectedTypeIndex = index;
                      });
                      _loadActivities(index);
                    },
                  ),
                ),
              ),

              // Activities List
              SliverToBoxAdapter(
                child: _loadingActivities
                    ? const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : (_activities.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: Center(child: Text('No activities found.')),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _activities.length,
                            itemBuilder: (context, idx) {
                              return ActivityCard(activity: _activities[idx]);
                            },
                          )),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 