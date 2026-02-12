import 'package:flutter/material.dart';

class RightPanel extends StatelessWidget {
  final String role;
  final int totalDataSource;
  final int totalStudent;
  final double overallProgress;
  final List<String> items;

  const RightPanel({
    Key? key,
    required this.role,
    required this.totalDataSource,
    required this.totalStudent,
    required this.overallProgress,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isTeacher = role == "Teacher";
    final double pct = (overallProgress / 100).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _statusCard(pct, isTeacher),
          const SizedBox(height: 16),
          _chartCard(pct),
        ],
      ),
    );
  }

  Widget _statusCard(double pct, bool isTeacher) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Status",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          DonutProgress(
            progress: pct,
            size: 140,
            strokeWidth: 14,
          ),
          const SizedBox(height: 16),
          _miniStat("Data Sources", totalDataSource.toString()),
          if (isTeacher) const SizedBox(height: 8),
          if (isTeacher)
            _miniStat("Total Students", totalStudent.toString()),
        ],
      ),
    );
  }

  Widget _chartCard(double pct) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Progress Chart",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _bar(pct * 180),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _bar(double height) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          height: height.clamp(0, 180),
          decoration: BoxDecoration(
            color: const Color(0xFF8B1C23),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}

class DonutProgress extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;

  const DonutProgress({
    Key? key,
    required this.progress,
    this.size = 140,
    this.strokeWidth = 14,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int percent = (progress.clamp(0.0, 1.0) * 100).round();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _DonutPainter(
              progress: progress.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              trackColor: Colors.grey.shade300,
              progressColor: const Color(0xFF4A1511),
            ),
          ),
          Text(
            "$percent%",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;

  _DonutPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    const startAngle = -3.14159265359 / 2;
    final sweepAngle = 2 * 3.14159265359 * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}
