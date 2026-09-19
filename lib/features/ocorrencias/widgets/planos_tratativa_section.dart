import 'package:flutter/material.dart';

import '../../../shared/theme/tokens.dart';
import '../../../shared/widgets/prototype_ui.dart';
import '../model/desvio_detail.dart';
import '../model/plano_tratativa.dart';
import 'tratativa_item_card.dart';

/// Histórico de "Planos" de tratativa de um Desvio: cada rodada vira um card
/// recolhível, com o resultado (Reprovado/Aprovado/Em análise) sinalizado por
/// uma faixa colorida à esquerda. O plano da rodada atual vem expandido por
/// padrão; planos reprovados anteriores vêm recolhidos, mas sinalizam em
/// vermelho quem reprovou e quando.
class PlanosTratativaSection extends StatefulWidget {
  final DesvioDetail d;
  final String? token;

  const PlanosTratativaSection({super.key, required this.d, required this.token});

  @override
  State<PlanosTratativaSection> createState() => _PlanosTratativaSectionState();
}

class _PlanosTratativaSectionState extends State<PlanosTratativaSection> {
  late Set<int> _expandidos;

  @override
  void initState() {
    super.initState();
    final planos = buildPlanos(widget.d.tratativas, widget.d.historico);
    _expandidos = {if (planos.isNotEmpty) planos.last.rodada};
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final planos = buildPlanos(widget.d.tratativas, widget.d.historico);
    if (planos.isEmpty) {
      return ProtoCard(
        child: Row(children: [
          Icon(Icons.inbox_outlined, color: c.fg2, size: 18),
          const SizedBox(width: 10),
          Text('Nenhuma tratativa ainda',
              style: TextStyle(color: c.fg2, fontSize: 13)),
        ]),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PLANOS DE TRATATIVA',
          style: SafeCoreType.label.copyWith(color: c.fg2, letterSpacing: .5),
        ),
        const SizedBox(height: 8),
        for (final plano in planos) ...[
          _planoCard(plano),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _planoCard(Plano plano) {
    final c = context.c;
    final (accent, label) = switch (plano.resultado) {
      ResultadoPlano.reprovado => (c.statusRedFg, 'Reprovado'),
      ResultadoPlano.aprovado => (c.statusGreenFg, 'Aprovado'),
      ResultadoPlano.emAnalise => (c.accent, 'Em análise'),
    };
    // Fixed near-black, not theme-reactive: both light/dark accent are bright
    // enough that a dark label reads far better on the "Em análise" chip than
    // white would (the reprovado/aprovado chips use saturated colors that
    // already contrast well with white).
    final pillFg =
        plano.resultado == ResultadoPlano.emAnalise ? const Color(0xFF0B1118) : Colors.white;
    final expandido = _expandidos.contains(plano.rodada);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: c.bgSurface,
          border: Border.all(color: c.borderSoft),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: accent),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => setState(() {
                        if (expandido) {
                          _expandidos.remove(plano.rodada);
                        } else {
                          _expandidos.add(plano.rodada);
                        }
                      }),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      Text('Plano ${plano.rodada}',
                                          style: TextStyle(
                                              color: c.fg0,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w900)),
                                      if (plano.dataSubmissao != null)
                                        Text(_fmtDateTime(plano.dataSubmissao),
                                            style: TextStyle(
                                                color: c.fg2,
                                                fontSize: 11)),
                                      ProtoPill(label: label, bg: accent, fg: pillFg),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  expandido ? Icons.expand_less : Icons.expand_more,
                                  color: c.fg2,
                                  size: 20,
                                ),
                              ],
                            ),
                            if (!expandido &&
                                plano.resultado == ResultadoPlano.reprovado &&
                                plano.revisorNome != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Reprovado por ${plano.revisorNome} • ${_fmtDateTime(plano.dataResultado)}',
                                style: TextStyle(
                                    color: c.statusRedFg,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (expandido)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (plano.resultado == ResultadoPlano.aprovado &&
                                (plano.comentario?.isNotEmpty ?? false))
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: c.statusGreenBg,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text('Comentário: ${plano.comentario}',
                                    style: TextStyle(
                                        color: c.statusGreenFg, fontSize: 12)),
                              ),
                            for (final t in plano.tratativas)
                              TratativaItemCard(tratativa: t, token: widget.token),
                            if (plano.revisorNome != null)
                              Text(
                                '${plano.resultado == ResultadoPlano.reprovado ? 'Reprovado' : 'Aprovado'} por ${plano.revisorNome} • ${_fmtDateTime(plano.dataResultado)}',
                                style: TextStyle(
                                    color: plano.resultado == ResultadoPlano.reprovado
                                        ? c.statusRedFg
                                        : c.fg2,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

String _fmtDateTime(String? iso) {
  if (iso == null || iso.isEmpty) return '—';
  try {
    final utc = DateTime.parse(iso.contains('Z') ? iso : '${iso}Z');
    final br = utc.subtract(const Duration(hours: 3));
    return '${br.day.toString().padLeft(2, '0')}/${br.month.toString().padLeft(2, '0')}/${br.year} '
        '${br.hour.toString().padLeft(2, '0')}:${br.minute.toString().padLeft(2, '0')}';
  } catch (_) {
    return iso;
  }
}
