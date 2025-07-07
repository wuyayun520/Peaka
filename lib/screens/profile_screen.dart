import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../main.dart';
import '../models/user.dart';
import 'message_center_screen.dart';
import 'about_us_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _profileImagePath;
  String _userName = '';
  String _userDescription = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? '';
      _userDescription = prefs.getString('user_description') ?? '';
      _profileImagePath = prefs.getString('profile_image_path');
      
      _nameController.text = _userName;
      _descriptionController.text = _userDescription;
    });
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text);
    await prefs.setString('user_description', _descriptionController.text);
    if (_profileImagePath != null) {
      await prefs.setString('profile_image_path', _profileImagePath!);
    }
    
    setState(() {
      _userName = _nameController.text;
      _userDescription = _descriptionController.text;
    });
  }

  // 清理旧的头像文件
  Future<void> _cleanupOldProfileImage(String? oldImagePath) async {
    if (oldImagePath != null && oldImagePath.isNotEmpty) {
      try {
        final File oldFile = File(oldImagePath);
        if (await oldFile.exists()) {
          await oldFile.delete();
          debugPrint('Old profile image deleted: $oldImagePath');
        }
      } catch (e) {
        debugPrint('Error deleting old profile image: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (image != null) {
      try {
        // 获取应用文档目录
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String appDocPath = appDocDir.path;
        
        // 创建一个唯一的文件名
        final String fileName = 'profile_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String permanentPath = '$appDocPath/$fileName';
        
        // 将临时文件复制到永久位置
        final File tempFile = File(image.path);
        final File permanentFile = await tempFile.copy(permanentPath);
        
        // 清理旧的头像文件
        await _cleanupOldProfileImage(_profileImagePath);
        
        setState(() {
          _profileImagePath = permanentFile.path;
        });
        await _saveUserData();
      } catch (e) {
        debugPrint('Error saving profile image: $e');
        // 如果复制失败，可以显示错误消息
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save profile image'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _saveUserData();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/peaka_nor_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Consumer<AppState>(
          builder: (context, appState, child) {
            final currentUser = appState.dataService.users.isNotEmpty
                ? appState.dataService.users.first
                : null;

            return Stack(
              children: [
                // Top Background Image - Now covers status bar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: MediaQuery.of(context).padding.top + 200, // 包含状态栏高度
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/peaka_me_topnor.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                
                // Main Content
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20), // 减少水平内边距
                    child: Column(
                      children: [
                        const SizedBox(height: 80),
                        
                        // Profile Avatar with Edit Button
                        GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: _getProfileImage(currentUser),
                                child: _getProfileImage(currentUser) == null
                                    ? Text(
                                        _userName.isNotEmpty 
                                            ? _userName[0].toUpperCase() 
                                            : (currentUser?.name.isNotEmpty == true
                                                ? currentUser!.name[0].toUpperCase()
                                                : 'U'),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // User Name - Editable
                        GestureDetector(
                          onTap: _showEditDialog,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _userName.isNotEmpty 
                                    ? _userName 
                                    : (currentUser?.name ?? 'Tap to edit name'),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.edit,
                                size: 20,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // User Description - Editable
                        GestureDetector(
                          onTap: _showEditDialog,
                          child: Text(
                            _userDescription.isNotEmpty 
                                ? _userDescription 
                                : (currentUser?.signa.isNotEmpty == true 
                                    ? currentUser!.signa 
                                    : 'Tap to add description'),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Menu Items - 悬浮半透明样式
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9), // 半透明白色
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildMenuItem(
                                Icons.message,
                                'Message Center',
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const MessageCenterScreen(),
                                    ),
                                  );
                                },
                              ),
                              Divider(
                                height: 1,
                                color: Colors.grey.withValues(alpha: 0.3),
                              ),
                              _buildMenuItem(
                                Icons.privacy_tip,
                                'Privacy Policy',
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const PrivacyPolicyScreen(),
                                    ),
                                  );
                                },
                              ),
                              Divider(
                                height: 1,
                                color: Colors.grey.withValues(alpha: 0.3),
                              ),
                              _buildMenuItem(
                                Icons.description,
                                'Terms of Service',
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const TermsOfServiceScreen(),
                                    ),
                                  );
                                },
                              ),
                              Divider(
                                height: 1,
                                color: Colors.grey.withValues(alpha: 0.3),
                              ),
                              _buildMenuItem(
                                Icons.info,
                                'About Us',
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AboutUsScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        width: double.infinity,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1), // 更透明的背景
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 22,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider? _getProfileImage(User? user) {
    if (_profileImagePath != null) {
      final File imageFile = File(_profileImagePath!);
      if (imageFile.existsSync()) {
        return FileImage(imageFile);
      } else {
        // 如果文件不存在，清理无效路径
        _cleanupInvalidImagePath();
      }
    }
    
    if (user?.userIcon.isNotEmpty == true) {
      return AssetImage(user!.userIcon) as ImageProvider;
    }
    
    return null;
  }

  // 清理无效的图片路径
  void _cleanupInvalidImagePath() {
    if (_profileImagePath != null) {
      debugPrint('Profile image file not found, cleaning up path: $_profileImagePath');
      _profileImagePath = null;
      _saveUserData(); // 保存更新后的状态
    }
  }
} 