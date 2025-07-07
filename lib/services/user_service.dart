import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/user_model.dart';

class UserService {
  List<UserModel> _users = [];
  List<UserModel> get users => _users;

  Future<void> loadUsers() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/passtell.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> usersData = jsonData['allData'];
      
      _users = usersData
          .map((userData) => UserModel.fromJson(userData as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading users: $e');
      _users = [];
    }
  }
} 