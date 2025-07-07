import 'package:flutter/material.dart';

class SportType {
  final String name;
  final String imagePath;

  SportType({required this.name, required this.imagePath});
}

class SportTypeSelector extends StatefulWidget {
  final Function(int) onTypeSelected;

  const SportTypeSelector({
    Key? key,
    required this.onTypeSelected,
  }) : super(key: key);

  @override
  State<SportTypeSelector> createState() => _SportTypeSelectorState();
}

class _SportTypeSelectorState extends State<SportTypeSelector> {
  int _selectedIndex = 1; // Default to Skydiving

  final List<SportType> _sportTypes = [
    SportType(name: 'Surfing', imagePath: 'assets/type/peaka_home_surfing.png'),
    SportType(name: 'Skydiving', imagePath: 'assets/type/peaka_home_skydiving.png'),
    SportType(name: 'Climbing', imagePath: 'assets/type/peaka_home_climbing.png'),
    SportType(name: 'Diving', imagePath: 'assets/type/peaka_home_diving.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_sportTypes.length, (index) {
            final sportType = _sportTypes[index];
            final isSelected = _selectedIndex == index;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
                widget.onTypeSelected(index);
              },
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: const Color(0xFF1689FE), width: 2)
                          : null,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        sportType.imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sportType.name,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected
                          ? const Color(0xFF1689FE)
                          : const Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
} 