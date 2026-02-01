import 'package:eccd/util/menu_tap.dart';
import 'package:flutter/material.dart';

class DataSourceTile extends StatelessWidget {
  final String section;
  final String schoolYear;
  final Color color;
  final VoidCallback onActivate;
  final VoidCallback onDeactivate;

  const DataSourceTile({
    Key? key,
    required this.section,
    required this.schoolYear,
    required this.color,
    required this.onActivate,
    required this.onDeactivate,
}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 180,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 18,
              color: Colors.black
            ),
      ),
            Positioned(
              top: 6,
              right: 6,
              child: MenuTap(
                onActivate: () {},
                onDeactivate: () {},
              ),
            ),


            Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          schoolYear,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height:6),
        Text(
          section,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  ),
        ],
      ),
    );
  }

}