import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class OcorrenciaSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final int activeFilterCount;
  final VoidCallback onFilterTap;

  const OcorrenciaSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.activeFilterCount,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: SafeCoreType.bodyMedium.copyWith(color: c.fg0),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Buscar por título, localização ou código...',
              hintStyle: SafeCoreType.bodyMedium.copyWith(color: c.fg2),
              prefixIcon: Icon(Icons.search_rounded, size: 19, color: c.fg2),
              filled: true,
              fillColor: c.bgSurface,
              contentPadding: const EdgeInsets.symmetric(vertical: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SafeCoreRadius.md),
                borderSide: BorderSide(color: c.borderSoft),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SafeCoreRadius.md),
                borderSide: BorderSide(color: c.borderSoft),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SafeCoreRadius.md),
                borderSide: BorderSide(color: c.accent, width: 1.4),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _FilterButton(count: activeFilterCount, onTap: onFilterTap),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _FilterButton({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final active = count > 0;
    return InkWell(
      borderRadius: BorderRadius.circular(SafeCoreRadius.md),
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? c.accent.withValues(alpha: 0.15) : c.bgSurface,
          borderRadius: BorderRadius.circular(SafeCoreRadius.md),
          border: Border.all(color: active ? c.accent : c.borderSoft),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Icon(
                Icons.tune_rounded,
                size: 20,
                color: active ? c.accent : c.fg2,
              ),
            ),
            if (active)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
                  child: Text(
                    '$count',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
