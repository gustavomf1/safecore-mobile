import 'package:flutter/material.dart';

import '../../../shared/theme/tokens.dart';

/// Etapa (1..4) de uma NC ou Desvio a partir do status bruto do backend.
/// NC e Desvio compartilham o mesmo vocabulário de status (ver statusLabel
/// em shared/data/mock_data.dart), então a mesma trilha serve para os dois.
int stageIndexForStatus(String status) => switch (status.toUpperCase()) {
      'ABERTA' || 'ABERTO' => 1,
      'AGUARDANDO_TRATATIVA' ||
      'EM_AJUSTE_PELO_EXTERNO' ||
      'AGUARDANDO_APROVACAO_PLANO' ||
      'AGUARDANDO_APROVACAO' =>
        2,
      'EM_EXECUCAO' || 'AGUARDANDO_VALIDACAO_FINAL' => 3,
      'CONCLUIDA' || 'CONCLUIDO' || 'FECHADA' || 'FECHADO' => 4,
      _ => 1,
    };

const detailStageLabels = ['Registro', 'Tratativa', 'Execução', 'Conclusão'];

/// Trilha de progresso de 4 segmentos usada no cabeçalho de NC e Desvio.
class DetailProgressRail extends StatelessWidget {
  final int stage; // 1..4
  const DetailProgressRail({super.key, required this.stage});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(detailStageLabels.length, (i) {
            final filled = i < stage;
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: i == detailStageLabels.length - 1 ? 0 : 4),
                decoration: BoxDecoration(
                  color: filled ? c.statusGreenFg : c.bgMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: detailStageLabels
              .map((l) => Text(l.toUpperCase(), style: SafeCoreType.micro.copyWith(color: c.fg3, fontSize: 9)))
              .toList(),
        ),
      ],
    );
  }
}

/// Código curto da ocorrência (`NC #id` / `Desvio #id`) exibido na
/// barra de navegação do cabeçalho de detalhe.
class DetailIdBadge extends StatelessWidget {
  final String prefix;
  final String id;
  const DetailIdBadge({super.key, required this.prefix, required this.id});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$prefix #$id',
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: context.c.fg3, fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'monospace'),
    );
  }
}

/// Texto com clamp de altura e alternância "Ver mais"/"Ver menos", usado
/// nas descrições longas de NC/Desvio.
class ExpandableText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final int collapsedMaxLines;
  const ExpandableText({super.key, required this.text, required this.style, this.collapsedMaxLines = 4});

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final span = TextSpan(text: widget.text, style: widget.style);
      final painter = TextPainter(
        text: span,
        maxLines: widget.collapsedMaxLines,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: constraints.maxWidth);
      final overflows = painter.didExceedMaxLines;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.text,
            style: widget.style,
            maxLines: _expanded ? null : widget.collapsedMaxLines,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
          if (overflows) ...[
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Text(
                _expanded ? 'Ver menos' : 'Ver mais',
                style: TextStyle(color: context.c.accent, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      );
    });
  }
}
