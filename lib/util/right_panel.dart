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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Progress Overview",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DonutProgress(
                progress: pct,
                size: 110,
                strokeWidth: 12,
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _miniStat("Data Sources", totalDataSource.toString()),
                    if (isTeacher) const SizedBox(height: 10),
                    if (isTeacher)
                      _miniStat("Total Students", totalStudent.toString()),
                    const SizedBox(height: 10),
                    _miniStat("Overall", "${(pct * 100).toStringAsFixed(0)}%"),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // progress bar (overall)
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Overall Progress",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
              Text(
                "${(pct * 100).toStringAsFixed(0)}%",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              color: Colors.green,
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
            style: const TextStyle(fontSize: 12, color: Colors.black54),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
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
    this.size = 110,
    this.strokeWidth = 12,
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
              trackColor: Colors.grey.shade200,
              progressColor: Colors.green,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$percent%",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              const Text(
                "done",
                style: TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ],
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

    final startAngle = -1.57079632679;
    final sweepAngle = 6.28318530718 * progress;

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
