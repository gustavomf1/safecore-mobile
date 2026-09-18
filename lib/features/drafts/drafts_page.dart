import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/ocorrencias/model/rascunho_local.dart';
import '../../features/ocorrencias/repository/draft_repository_impl.dart';
import '../../shared/theme/tokens.dart';
import '../../shared/widgets/prototype_ui.dart';

class DraftsPage extends ConsumerWidget {
  const DraftsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final draftsAsync = ref.watch(draftsProvider);

    return Scaffold(
      backgroundColor: c.bgBase,
      body: SafeArea(
        bottom: false,
        child: draftsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erro: $e', style: TextStyle(color: c.statusRedFg))),
          data: (drafts) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 104),
            children: [
              Align(alignment: Alignment.centerRight, child: ProtoIconButton(icon: Icons.notifications_none_rounded, onTap: () {})),
              const SizedBox(height: 8),
              Text('Rascunhos', style: SafeCoreType.headline.copyWith(color: c.fg0)),
              const SizedBox(height: 3),
              Text('${drafts.length} pendentes de sincronização', style: SafeCoreType.body.copyWith(color: c.fg2)),
              const SizedBox(height: 14),
              ProtoCard(
                color: c.statusGreenBg,
                child: Row(
                  children: [
                    Container(width: 44, height: 44, decoration: BoxDecoration(color: c.statusGreenFg, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.cloud_sync_rounded, color: Colors.white)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Os rascunhos serão enviados automaticamente.', style: SafeCoreType.bodyStrong.copyWith(color: c.fg0)),
                          const SizedBox(height: 3),
                          Text('Sincronização automática ao conectar.', style: SafeCoreType.micro.copyWith(color: c.fg2)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: c.bgSurface, borderRadius: BorderRadius.circular(8)),
                      child: Text('Forçar', style: SafeCoreType.label.copyWith(color: c.statusGreenFg)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              for (final draft in drafts) _DraftCard(draft: draft),
              const SizedBox(height: 10),
              ProtoCard(
                color: c.bgElevated,
                child: Center(child: Text('Rascunhos ficam no dispositivo até serem publicados.', style: SafeCoreType.micro.copyWith(color: c.fg3))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DraftCard extends StatelessWidget {
  final RascunhoLocal draft;
  const _DraftCard({required this.draft});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final isNc = draft.tipo == 'NC';
    final synced = draft.sincronizado == 1;
    final color = synced ? c.statusGreenFg : (isNc ? c.statusRedFg : c.statusYellowFg);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ProtoCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 46, height: 46, decoration: BoxDecoration(color: color.withValues(alpha: .16), borderRadius: BorderRadius.circular(12)), child: Icon(isNc ? Icons.shield_outlined : Icons.warning_amber_rounded, color: color, size: 23)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(spacing: 6, children: [
                    ProtoPill(label: draft.tipo, bg: isNc ? c.statusRedBg : c.statusYellowBg, fg: isNc ? c.statusRedFg : c.statusYellowFg),
                    ProtoPill(label: synced ? 'Sincronizado' : 'Pendente', bg: color.withValues(alpha: .16), fg: color),
                  ]),
                  const SizedBox(height: 6),
                  Text(draft.titulo, maxLines: 2, overflow: TextOverflow.ellipsis, style: SafeCoreType.bodyStrong.copyWith(color: c.fg0)),
                  const SizedBox(height: 5),
                  Text(draft.descricao ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: SafeCoreType.micro.copyWith(color: c.fg2)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
