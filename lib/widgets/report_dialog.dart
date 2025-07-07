import 'package:flutter/material.dart';
import '../services/report_service.dart';
import '../utils/theme.dart';

class ReportDialog extends StatefulWidget {
  final String targetId;
  final ReportType reportType;
  final String targetTitle; // Post title or comment content preview

  const ReportDialog({
    super.key,
    required this.targetId,
    required this.reportType,
    required this.targetTitle,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String? _selectedReportType;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitReport() async {
    if (_selectedReportType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a report type')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Check if already reported
      final hasReported = await ReportService.hasReported(
        targetId: widget.targetId,
        reporterId: 'current_user', // In real app, use actual user ID
      );

      if (hasReported) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You have already reported this content')),
          );
          Navigator.of(context).pop();
        }
        return;
      }

      // Submit report
      if (widget.reportType == ReportType.post) {
        await ReportService.reportPost(
          postId: widget.targetId,
          reportType: _selectedReportType!,
          description: _descriptionController.text.trim(),
          reporterId: 'current_user',
        );
      } else {
        await ReportService.reportComment(
          commentId: widget.targetId,
          reportType: _selectedReportType!,
          description: _descriptionController.text.trim(),
          reporterId: 'current_user',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit report. Please try again')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.report_outlined,
            color: Colors.red,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            'Report ${widget.reportType == ReportType.post ? 'Post' : 'Comment'}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show preview of reported content
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.targetTitle,
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 14,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            
            // Report type selection
            const Text(
              'Report Type:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            
            // Report type list
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: Column(
                  children: ReportService.reportTypes.map((type) {
                    return RadioListTile<String>(
                      title: Text(type),
                      value: type,
                      groupValue: _selectedReportType,
                      onChanged: (value) {
                        setState(() {
                          _selectedReportType = value;
                        });
                      },
                      activeColor: AppTheme.primaryColor,
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList(),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Detailed description
            const Text(
              'Description (Optional):',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Please describe the reason for reporting...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitReport,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Submit Report'),
        ),
      ],
    );
  }
}

// Convenience method to show report dialog
void showReportDialog(
  BuildContext context, {
  required String targetId,
  required ReportType reportType,
  required String targetTitle,
}) {
  showDialog(
    context: context,
    builder: (context) => ReportDialog(
      targetId: targetId,
      reportType: reportType,
      targetTitle: targetTitle,
    ),
  );
} 