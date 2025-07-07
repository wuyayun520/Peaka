import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/activity.dart';
import '../models/user.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  List<Activity> _surfingActivities = [];
  List<Activity> _skydivingActivities = [];
  List<Activity> _climbingActivities = [];
  List<Activity> _divingActivities = [];
  List<User> _users = [];

  List<Activity> get surfingActivities => _surfingActivities;
  List<Activity> get skydivingActivities => _skydivingActivities;
  List<Activity> get climbingActivities => _climbingActivities;
  List<Activity> get divingActivities => _divingActivities;
  List<User> get users => _users;

  List<Activity> get allActivities => [
    ..._surfingActivities,
    ..._skydivingActivities,
    ..._climbingActivities,
    ..._divingActivities,
  ];

  Future<void> loadAllData() async {
    try {
      await Future.wait([
        _loadSurfingActivities(),
        _loadSkydivingActivities(),
        _loadClimbingActivities(),
        _loadDivingActivities(),
        _loadUsers(),
      ]);
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  Future<void> _loadSurfingActivities() async {
    try {
      final String response = await rootBundle.loadString('assets/data/surfing_activities.json');
      final data = json.decode(response);
      _surfingActivities = (data['surfing_activities'] as List)
          .map((item) => Activity.fromJson(item))
          .toList();
    } catch (e) {
      print('Error loading surfing activities: $e');
    }
  }

  Future<void> _loadSkydivingActivities() async {
    try {
      final String response = await rootBundle.loadString('assets/data/skydiving_activities.json');
      final data = json.decode(response);
      _skydivingActivities = (data['skydiving_activities'] as List)
          .map((item) => Activity.fromJson(item))
          .toList();
    } catch (e) {
      print('Error loading skydiving activities: $e');
    }
  }

  Future<void> _loadClimbingActivities() async {
    try {
      final String response = await rootBundle.loadString('assets/data/climbing_activities.json');
      final data = json.decode(response);
      _climbingActivities = (data['climbing_activities'] as List)
          .map((item) => Activity.fromJson(item))
          .toList();
    } catch (e) {
      print('Error loading climbing activities: $e');
    }
  }

  Future<void> _loadDivingActivities() async {
    try {
      final String response = await rootBundle.loadString('assets/data/diving_activities.json');
      final data = json.decode(response);
      _divingActivities = (data['diving_activities'] as List)
          .map((item) => Activity.fromJson(item))
          .toList();
    } catch (e) {
      print('Error loading diving activities: $e');
    }
  }

  Future<void> _loadUsers() async {
    try {
      final String response = await rootBundle.loadString('assets/data/passtell.json');
      final data = json.decode(response);
      _users = (data['allData'] as List)
          .map((item) => User.fromJson(item))
          .toList();
    } catch (e) {
      print('Error loading users: $e');
    }
  }

  List<Activity> getActivitiesByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'surfing':
        return _surfingActivities;
      case 'skydiving':
        return _skydivingActivities;
      case 'climbing':
        return _climbingActivities;
      case 'diving':
        return _divingActivities;
      default:
        return [];
    }
  }

  Activity? getActivityById(String id) {
    return allActivities.firstWhere(
      (activity) => activity.id == id,
      orElse: () => Activity(
        id: '',
        title: '',
        location: '',
        description: '',
        difficulty: '',
        duration: '',
        price: 0.0,
        currency: '',
        maxParticipants: 0,
        minAge: 0,
        images: '',
        included: [],
        requirements: [],
        dates: [],
        highlights: [],
      ),
    );
  }

  User? getUserById(String userId) {
    return _users.firstWhere(
      (user) => user.userId == userId,
      orElse: () => User(
        userId: '',
        name: '',
        userIcon: '',
        userIconBg: '',
        userCover: '',
        introduction: '',
        signa: '',
        posts: [],
      ),
    );
  }

  List<Post> getAllPosts() {
    List<Post> allPosts = [];
    for (var user in _users) {
      for (var post in user.posts) {
        allPosts.add(post);
      }
    }
    return allPosts;
  }
} 