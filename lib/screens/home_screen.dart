import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel;
import 'dart:convert';
import 'package:flutter/services.dart';
import '../main.dart';
import '../utils/theme.dart';
import '../widgets/sport_card.dart';
import '../widgets/sport_type_selector.dart';
import '../widgets/activity_card.dart';
import '../models/activity.dart';
import '../services/user_service.dart';
import 'user_profile_screen.dart';

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
                  child: Text(
                    'POPULAR SPORTS',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                      letterSpacing: 2,
                      height: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
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
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                child: SportCard(
                                  title: user.name,
                                  subtitle: user.signa,
                                  description: user.introduction,
                                  imageUrl: user.userCover,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserProfileScreen(user: user),
                                      ),
                                    );
                                  },
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