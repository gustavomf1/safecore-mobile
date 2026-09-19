import 'package:flutter/material.dart';

import '../../../shared/theme/tokens.dart';
import '../../../shared/widgets/prototype_ui.dart';

/// Dois seletores segmentados (severidade 1-5, probabilidade 1-4) com label
/// do nível de risco derivado. Reporta valores via callbacks.
class RiskPicker extends StatelessWidget {
  final int severidade;
  final int probabilidade;
  final ValueChanged<int> onSeveridade;
  final ValueChanged<int> onProbabilidade;

  const RiskPicker({
    super.key,
    required this.severidade,
    required this.probabilidade,
    required this.onSeveridade,
    required this.onProbabilidade,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final score = severidade * probabilidade;
    final (label, color) = _nivel(score, c);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProtoSectionTitle('Severidade'),
        const SizedBox(height: 8),
        _Ramp(count: 5, value: severidade, onTap: onSeveridade),
        const SizedBox(height: 16),
        const ProtoSectionTitle('Probabilidade'),
        const SizedBox(height: 8),
        _Ramp(count: 4, value: probabilidade, onTap: onProbabilidade),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              'Nivel de risco',
              style: TextStyle(
                  color: c.fg2,
                  fontSize: 12,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            ProtoPill(
              label: label,
              bg: color.withValues(alpha: .18),
              fg: color,
            ),
          ],
        ),
      ],
    );
  }

  (String, Color) _nivel(int score, SafeCoreColors c) {
    if (score >= 15) return ('CRITICO', c.statusRedFg);
    if (score >= 9) return ('ALTO', c.statusOrangeFg);
    if (score >= 4) return ('MEDIO', c.statusYellowFg);
    return ('BAIXO', c.statusGreenFg);
  }
}

class _Ramp extends StatelessWidget {
  final int count;
  final int value;
  final ValueChanged<int> onTap;
  const _Ramp({required this.count, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Row(
      children: List.generate(count, (i) {
        final n = i + 1;
        final active = n <= value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == count - 1 ? 0 : 6),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => onTap(n),
              child: Container(
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? c.accent : c.bgElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: c.borderSoft),
                ),
                child: Text(
                  '$n',
                  style: TextStyle(
                    color: active ? Colors.white : c.fg2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
