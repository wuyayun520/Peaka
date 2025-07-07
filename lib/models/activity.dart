class Activity {
  final String id;
  final String title;
  final String location;
  final String description;
  final String difficulty;
  final String duration;
  final num price;
  final String currency;
  final int maxParticipants;
  final int minAge;
  final String images;
  final List<String> included;
  final List<String> requirements;
  final List<dynamic> dates;
  final List<String> highlights;

  Activity({
    required this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.difficulty,
    required this.duration,
    required this.price,
    required this.currency,
    required this.maxParticipants,
    required this.minAge,
    required this.images,
    required this.included,
    required this.requirements,
    required this.dates,
    required this.highlights,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      difficulty: json['difficulty'] ?? '',
      duration: json['duration'] ?? '',
      price: json['price'] ?? 0,
      currency: json['currency'] ?? '',
      maxParticipants: json['max_participants'] ?? 0,
      minAge: json['min_age'] ?? 0,
      images: json['images'] ?? '',
      included: List<String>.from(json['included'] ?? []),
      requirements: List<String>.from(json['requirements'] ?? []),
      dates: json['dates'] ?? [],
      highlights: List<String>.from(json['highlights'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'description': description,
      'difficulty': difficulty,
      'duration': duration,
      'price': price,
      'currency': currency,
      'max_participants': maxParticipants,
      'min_age': minAge,
      'images': images,
      'included': included,
      'requirements': requirements,
      'dates': dates,
      'highlights': highlights,
    };
  }
}

class ActivityDate {
  final String startDate;
  final String endDate;
  final int availableSpots;

  ActivityDate({
    required this.startDate,
    required this.endDate,
    required this.availableSpots,
  });

  factory ActivityDate.fromJson(Map<String, dynamic> json) {
    return ActivityDate(
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      availableSpots: json['available_spots'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start_date': startDate,
      'end_date': endDate,
      'available_spots': availableSpots,
    };
  }
}

class ActivityCategory {
  final String name;
  final String imagePath;
  final List<Activity> activities;

  ActivityCategory({
    required this.name,
    required this.imagePath,
    required this.activities,
  });

  static List<ActivityCategory> getCategories() {
    return [
      ActivityCategory(
        name: 'Surfing',
        imagePath: 'assets/category/Surfing/Surfing1.jpg',
        activities: [],
      ),
      ActivityCategory(
        name: 'Skydiving',
        imagePath: 'assets/category/skydiving/skydiving1.jpg',
        activities: [],
      ),
      ActivityCategory(
        name: 'Climbing',
        imagePath: 'assets/category/Climbing/Climbing1.jpg',
        activities: [],
      ),
      ActivityCategory(
        name: 'Diving',
        imagePath: 'assets/category/Diving/Diving1.jpg',
        activities: [],
      ),
    ];
  }
} 