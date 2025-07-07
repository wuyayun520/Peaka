import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import '../main.dart';
import '../models/user.dart';
import 'chat_page.dart';

class MessageCenterScreen extends StatefulWidget {
  const MessageCenterScreen({super.key});

  @override
  State<MessageCenterScreen> createState() => _MessageCenterScreenState();
}

class _MessageCenterScreenState extends State<MessageCenterScreen> {
  List<ChatHistoryItem> _chatHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final users = appState.dataService.users;
      final dir = await getApplicationDocumentsDirectory();
      
      List<ChatHistoryItem> historyItems = [];
      
      for (User user in users) {
        final file = File('${dir.path}/chat_history_${user.userId}.json');
        if (await file.exists()) {
          try {
            final jsonStr = await file.readAsString();
            final List<dynamic> jsonList = json.decode(jsonStr);
            
            if (jsonList.isNotEmpty) {
              // 获取最新的消息
              final latestMessage = jsonList.last;
              final messageTime = DateTime.tryParse(latestMessage['timestamp'] ?? '') ?? 
                                 _parseTimeToDateTime(latestMessage['time'] ?? '');
              
              // 计算未读消息数量（假设对方发送的消息为未读）
              int unreadCount = 0;
              for (var msg in jsonList.reversed) {
                if (msg['isMe'] == false) {
                  unreadCount++;
                } else {
                  break;
                }
              }
              
              historyItems.add(ChatHistoryItem(
                user: user,
                lastMessage: _formatLastMessage(latestMessage),
                timestamp: messageTime,
                unreadCount: unreadCount,
              ));
            }
          } catch (e) {
            debugPrint('Error reading chat history for user ${user.userId}: $e');
          }
        }
      }
      
      // 按时间排序，最新的在前面
      historyItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      setState(() {
        _chatHistory = historyItems;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading chat history: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatLastMessage(Map<String, dynamic> message) {
    final type = message['type'] ?? 'text';
    switch (type) {
      case 'text':
        return message['text'] ?? '';
      case 'image':
        return '📷 Photo';
      case 'audio':
        return '🎵 Voice message';
      default:
        return 'Message';
    }
  }

  DateTime _parseTimeToDateTime(String timeStr) {
    try {
      // 假设时间格式是 "HH:mm"
      final now = DateTime.now();
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return DateTime(now.year, now.month, now.day, hour, minute);
      }
    } catch (e) {
      debugPrint('Error parsing time: $e');
    }
    return DateTime.now();
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Message Center',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black),
              onPressed: _loadChatHistory,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _chatHistory.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No conversations yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start chatting with someone!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadChatHistory,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _chatHistory.length,
                      itemBuilder: (context, index) {
                        final chatItem = _chatHistory[index];
                        return _buildMessageItem(chatItem);
                      },
                    ),
                  ),
      ),
    );
  }

  Widget _buildMessageItem(ChatHistoryItem chatItem) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage(chatItem.user.userIcon),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                chatItem.user.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              _formatTimestamp(chatItem.timestamp),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  chatItem.lastMessage,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (chatItem.unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    chatItem.unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(user: chatItem.user),
            ),
          );
        },
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.month}/${timestamp.day}';
    }
  }
}

class ChatHistoryItem {
  final User user;
  final String lastMessage;
  final DateTime timestamp;
  final int unreadCount;

  ChatHistoryItem({
    required this.user,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
  });
} 