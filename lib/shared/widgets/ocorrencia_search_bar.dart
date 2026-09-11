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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: TextStyle(color: SafeCoreColors.dark.fg0, fontSize: 13),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Buscar por título, localização ou código...',
              hintStyle: TextStyle(color: SafeCoreColors.dark.fg3, fontSize: 13),
              prefixIcon: Icon(Icons.search_rounded, size: 19, color: SafeCoreColors.dark.fg2),
              filled: true,
              fillColor: SafeCoreColors.dark.bgSurface,
              contentPadding: const EdgeInsets.symmetric(vertical: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SafeCoreRadius.md),
                borderSide: BorderSide(color: SafeCoreColors.dark.borderSoft),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SafeCoreRadius.md),
                borderSide: BorderSide(color: SafeCoreColors.dark.borderSoft),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SafeCoreRadius.md),
                borderSide: BorderSide(color: SafeCoreColors.dark.accent, width: 1.4),
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
    final active = count > 0;
    return InkWell(
      borderRadius: BorderRadius.circular(SafeCoreRadius.md),
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? SafeCoreColors.dark.accent.withValues(alpha: 0.15) : SafeCoreColors.dark.bgSurface,
          borderRadius: BorderRadius.circular(SafeCoreRadius.md),
          border: Border.all(color: active ? SafeCoreColors.dark.accent : SafeCoreColors.dark.borderSoft),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Icon(
                Icons.tune_rounded,
                size: 20,
                color: active ? SafeCoreColors.dark.accent : SafeCoreColors.dark.fg2,
              ),
            ),
            if (active)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  decoration: BoxDecoration(color: SafeCoreColors.dark.accent, shape: BoxShape.circle),
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
