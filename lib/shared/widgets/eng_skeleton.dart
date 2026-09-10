import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/tokens.dart';

class EngSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const EngSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: EngSegColors.dark.bgElevated,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: const Duration(milliseconds: 1200),
          color: EngSegColors.dark.bgMuted,
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
          EngSkeleton(height: 180, borderRadius: EngSegRadius.md),
          SizedBox(height: 10),
          Row(children: [
            EngSkeleton(width: 60, height: 22, borderRadius: 999),
            SizedBox(width: 6),
            EngSkeleton(width: 80, height: 22, borderRadius: 999),
          ]),
          SizedBox(height: 8),
          EngSkeleton(height: 16),
          SizedBox(height: 5),
          EngSkeleton(width: 200, height: 12),
        ],
      ),
    );
  }
}
