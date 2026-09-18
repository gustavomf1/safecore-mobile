import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/tokens.dart';

class SafeCoreSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SafeCoreSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: c.bgElevated,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    )
        .animate(onPlay: (a) => a.repeat())
        .shimmer(
          duration: const Duration(milliseconds: 1200),
          color: c.bgMuted,
        );
  }
}

class CoverCardSkeleton extends StatelessWidget {
  const CoverCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeCoreSkeleton(height: 180, borderRadius: SafeCoreRadius.md),
          SizedBox(height: 10),
          Row(children: [
            SafeCoreSkeleton(width: 60, height: 22, borderRadius: 999),
            SizedBox(width: 6),
            SafeCoreSkeleton(width: 80, height: 22, borderRadius: 999),
          ]),
          SizedBox(height: 8),
          SafeCoreSkeleton(height: 16),
          SizedBox(height: 5),
          SafeCoreSkeleton(width: 200, height: 12),
        ],
      ),
    );
  }
}
