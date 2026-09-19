import 'package:flutter/material.dart';
import '../theme/tokens.dart';

// ignore_for_file: deprecated_member_use_from_same_package
@Deprecated('Use context.c (SafeCoreColors) em novo código.')
class ProtoColors {
  static const bg = Color(0xFF0B1118);
  static const hero = Color(0xFF1A2534);
  static const surface = Color(0xFF151A21);
  static const surface2 = Color(0xFF1A2028);
  static const border = Color(0xFF26303B);
  static const borderStrong = Color(0xFF748195);
  static const text = Color(0xFFF8FBFF);
  static const muted = Color(0xFF566170);
  static const muted2 = Color(0xFF3F4A57);
  static const blue = Color(0xFF58A6FF);
  static const purple = Color(0xFF5F3FF2);
  static const red = Color(0xFFFF4D4D);
  static const yellow = Color(0xFFD29922);
  static const orange = Color(0xFFFF7A1A);
  static const green = Color(0xFF3FB950);
}


class ProtoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  // Was a fixed default (ProtoColors.surface) that never adapted to theme.
  // Null now means "follow the active theme's surface color."
  final Color? color;
  final Border? border;

  const ProtoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? c.bgSurface,
        borderRadius: BorderRadius.circular(SafeCoreRadius.md),
        border: border ?? Border.all(color: c.borderSoft),
      ),
      child: child,
    );
  }
}

class ProtoPill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final IconData? icon;

  const ProtoPill({super.key, required this.label, required this.bg, required this.fg, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: fg, size: 10),
            const SizedBox(width: 4),
          ],
          Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class ProtoIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const ProtoIconButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SizedBox(
      width: 38,
      height: 38,
      child: IconButton(
        style: IconButton.styleFrom(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: c.borderMain)),
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 19, color: c.fg0),
      ),
    );
  }
}

class ProtoSectionTitle extends StatelessWidget {
  final String label;

  const ProtoSectionTitle(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: SafeCoreType.label.copyWith(color: context.c.accent, fontSize: 13, letterSpacing: .45),
    );
  }
}

class ProtoMetricBox extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const ProtoMetricBox({super.key, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 69,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color.withValues(alpha: .18), borderRadius: BorderRadius.circular(SafeCoreRadius.sm + 1)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(label, style: SafeCoreType.body.copyWith(color: context.c.fg2)),
          ],
        ),
      ),
    );
  }
}
