import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ReportService {
  static const String _reportsKey = 'reports';
  
  // Report types
  static const List<String> reportTypes = [
    'Spam',
    'Inappropriate Content',
    'Harassment',
    'False Information',
    'Copyright Violation',
    'Violent Content',
    'Hate Speech',
    'Other'
  ];

  // 举报帖子
  static Future<void> reportPost({
    required String postId,
    required String reportType,
    required String description,
    required String reporterId,
  }) async {
    final report = Report(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ReportType.post,
      targetId: postId,
      reportType: reportType,
      description: description,
      reporterId: reporterId,
      timestamp: DateTime.now(),
      status: ReportStatus.pending,
    );
    
    await _saveReport(report);
  }

  // 举报评论
  static Future<void> reportComment({
    required String commentId,
    required String reportType,
    required String description,
    required String reporterId,
  }) async {
    final report = Report(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ReportType.comment,
      targetId: commentId,
      reportType: reportType,
      description: description,
      reporterId: reporterId,
      timestamp: DateTime.now(),
      status: ReportStatus.pending,
    );
    
    await _saveReport(report);
  }

  // 保存举报
  static Future<void> _saveReport(Report report) async {
    final prefs = await SharedPreferences.getInstance();
    final reports = await _getReports();
    reports.add(report);
    
    final reportsJson = json.encode(reports.map((r) => r.toJson()).toList());
    await prefs.setString(_reportsKey, reportsJson);
  }

  // 获取所有举报
  static Future<List<Report>> _getReports() async {
    final prefs = await SharedPreferences.getInstance();
    final reportsJson = prefs.getString(_reportsKey);
    
    if (reportsJson != null) {
      final List<dynamic> reportsList = json.decode(reportsJson);
      return reportsList.map((json) => Report.fromJson(json)).toList();
    }
    
    return [];
  }

  // 检查是否已举报
  static Future<bool> hasReported({
    required String targetId,
    required String reporterId,
  }) async {
    final reports = await _getReports();
    return reports.any((report) => 
      report.targetId == targetId && 
      report.reporterId == reporterId
    );
  }

  // 获取举报数量
  static Future<int> getReportCount(String targetId) async {
    final reports = await _getReports();
    return reports.where((report) => report.targetId == targetId).length;
  }

  // 清除所有举报（用于测试）
  static Future<void> clearAllReports() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_reportsKey);
  }
}

// 举报类型枚举
enum ReportType {
  post,
  comment,
}

// 举报状态枚举
enum ReportStatus {
  pending,
  reviewed,
  resolved,
  dismissed,
}

// 举报模型
class Report {
  final String id;
  final ReportType type;
  final String targetId;
  final String reportType;
  final String description;
  final String reporterId;
  final DateTime timestamp;
  final ReportStatus status;

  Report({
    required this.id,
    required this.type,
    required this.targetId,
    required this.reportType,
    required this.description,
    required this.reporterId,
    required this.timestamp,
    required this.status,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] ?? '',
      type: ReportType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => ReportType.post,
      ),
      targetId: json['targetId'] ?? '',
      reportType: json['reportType'] ?? '',
      description: json['description'] ?? '',
      reporterId: json['reporterId'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      status: ReportStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => ReportStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'targetId': targetId,
      'reportType': reportType,
      'description': description,
      'reporterId': reporterId,
      'timestamp': timestamp.toIso8601String(),
      'status': status.toString(),
    };
  }
} 