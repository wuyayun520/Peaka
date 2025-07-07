import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel;
import '../models/activity.dart';
import '../utils/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityDetailScreen extends StatefulWidget {
  final Activity activity;

  const ActivityDetailScreen({
    super.key,
    required this.activity,
  });

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  int currentImageIndex = 0;
  ActivityDate? selectedDate;
  bool _joined = false;

  @override
  void initState() {
    super.initState();
    _checkJoined();
  }

  Future<void> _checkJoined() async {
    final prefs = await SharedPreferences.getInstance();
    final joinedIds = prefs.getStringList('joined_activities') ?? [];
    setState(() {
      _joined = joinedIds.contains(widget.activity.id);
    });
  }

  Future<void> _joinActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final joinedIds = prefs.getStringList('joined_activities') ?? [];
    if (!joinedIds.contains(widget.activity.id)) {
      joinedIds.add(widget.activity.id);
      await prefs.setStringList('joined_activities', joinedIds);
      setState(() {
        _joined = true;
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully signed up!'),
          backgroundColor: AppTheme.successColor,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar with Images
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageCarousel(),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
           
          ),

          // Activity Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Location
                  _buildHeader(),
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Quick Info
                  _buildQuickInfo(),
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Description
                  _buildDescription(),
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Highlights
                  if (widget.activity.highlights.isNotEmpty) ...[
                    _buildHighlights(),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  
                  // What's Included
                  if (widget.activity.included.isNotEmpty) ...[
                    _buildIncluded(),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  
                  // Requirements
                  if (widget.activity.requirements.isNotEmpty) ...[
                    _buildRequirements(),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  
                  // Available Dates
                  if (widget.activity.dates.isNotEmpty) ...[
                    _buildAvailableDates(),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  
                  // Booking section spacing
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Bottom booking bar
      bottomNavigationBar: _buildBookingBar(),
    );
  }

  Widget _buildImageCarousel() {
    if (widget.activity.images.isEmpty) {
      return Container(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        child: const Center(
          child: Icon(
            Icons.image,
            size: 60,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(18),
        topRight: Radius.circular(18),
      ),
      child: Image.asset(
        widget.activity.images,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 300,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            child: const Center(
              child: Icon(
                Icons.image_not_supported,
                size: 40,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.activity.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            const Icon(
              Icons.location_on,
              size: 16,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                widget.activity.location,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickInfo() {
    return Row(
      children: [
        _buildInfoChip(
          icon: Icons.trending_up,
          label: widget.activity.difficulty,
          color: _getDifficultyColor(widget.activity.difficulty),
        ),
        const SizedBox(width: AppSpacing.sm),
        _buildInfoChip(
          icon: Icons.access_time,
          label: widget.activity.duration,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: AppSpacing.sm),
        _buildInfoChip(
          icon: Icons.group,
          label: 'Max ${widget.activity.maxParticipants}',
          color: AppTheme.successColor,
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppTheme.successColor;
      case 'medium':
        return AppTheme.warningColor;
      case 'hard':
        return AppTheme.errorColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          widget.activity.description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildHighlights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Highlights',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...widget.activity.highlights.map((highlight) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 16,
                  color: AppTheme.successColor,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    highlight,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildIncluded() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What\'s Included',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...widget.activity.included.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRequirements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Requirements',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...widget.activity.requirements.map((requirement) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppTheme.warningColor,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    requirement,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAvailableDates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Dates',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...widget.activity.dates.map((date) {
          final activityDate = ActivityDate.fromJson(date as Map<String, dynamic>);
          final isSelected = selectedDate != null &&
              selectedDate!.startDate == activityDate.startDate &&
              selectedDate!.endDate == activityDate.endDate;
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: InkWell(
              onTap: () {
                setState(() {
                  selectedDate = isSelected ? null : activityDate;
                });
              },
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '${activityDate.startDate} - ${activityDate.endDate}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected ? AppTheme.primaryColor : null,
                        ),
                      ),
                    ),
                    Text(
                      '${activityDate.availableSpots} spots left',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBookingBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          top: BorderSide(
            color: AppTheme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Price info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  
                ],
              ),
            ),
            
            // Book button
            SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: _joined ? null : _joinActivity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _joined ? Colors.grey : Colors.blue,
                  minimumSize: const Size(180, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  _joined ? 'Joined' : 'Sign Up',
                  style: const TextStyle(fontSize: 18)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 