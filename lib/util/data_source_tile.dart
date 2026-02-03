import 'package:eccd/util/menu_tap.dart';
import 'package:flutter/material.dart';

class DataSourceTile extends StatelessWidget {
  final String section;
  final String schoolYear;
  final String level;
  final Color color;
  final VoidCallback onActivate;
  final VoidCallback onDeactivate;
  final VoidCallback onTap;

  const DataSourceTile({
    Key? key,
    required this.section,
    required this.schoolYear,
    required this.level,
    required this.color,
    required this.onActivate,
    required this.onDeactivate,
    required this.onTap,
  }) : super(key: key);

  Color _randomColor() {
    final colors = [
      const Color(0xFF8B1C23),
      const Color(0xFF1C4E80),
      const Color(0xFF2E7D32),
      const Color(0xFFF57C00),
      const Color(0xFF6A1B9A),
      const Color(0xFF00695C),
      const Color(0xFF283593),
      const Color(0xFFC2185B),
    ];
    final seed = section.hashCode + schoolYear.hashCode + level.hashCode;
    return colors[seed.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final tileColor = _randomColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 180,
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 18,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: MenuTap(
                onActivate: onActivate,
                onDeactivate: onDeactivate,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      schoolYear,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      level,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Container(width: 60, height: 1, color: Colors.white70),
                    const SizedBox(height: 6),
                    Text(
                      section,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
