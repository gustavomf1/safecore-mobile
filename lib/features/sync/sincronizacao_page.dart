import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ocorrencias/model/rascunho_local.dart';
import '../ocorrencias/repository/draft_repository_impl.dart';
import '../auth/provider/auth_provider.dart';
import '../../core/network/connectivity_provider.dart';
import '../../core/sync/sync_service.dart';
import '../../shared/theme/tokens.dart';
import '../../shared/widgets/prototype_ui.dart';

class SincronizacaoPage extends ConsumerWidget {
  const SincronizacaoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final usuarioId = ref.watch(authProvider).valueOrNull?.id ?? '';
    final draftsAsync = ref.watch(draftsProvider(usuarioId));
    final online = ref.watch(connectivityProvider).valueOrNull ?? false;

    return Scaffold(
      backgroundColor: c.bgBase,
      body: SafeArea(
        bottom: false,
        child: draftsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erro: $e', style: TextStyle(color: c.statusRedFg))),
          data: (drafts) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 104),
            children: [
              Text('Sincronização', style: SafeCoreType.headline.copyWith(color: c.fg0)),
              const SizedBox(height: 3),
              Text('${drafts.length} pendentes de sincronização', style: SafeCoreType.body.copyWith(color: c.fg2)),
              const SizedBox(height: 14),
              if (drafts.isNotEmpty)
                _ActionButton(
                  label: 'Sincronizar tudo',
                  onTap: online
                      ? () async {
                          for (final d in drafts) {
                            await ref.read(syncServiceProvider).sincronizarRascunho(d);
                          }
                        }
                      : null,
                ),
              const SizedBox(height: 12),
              for (final draft in drafts)
                _SincronizacaoCard(
                  draft: draft,
                  online: online,
                  onSincronizar: () => ref.read(syncServiceProvider).sincronizarRascunho(draft),
                  onExcluir: () => ref.read(draftRepositoryProvider).deletar(draft.id),
                ),
              if (drafts.isEmpty)
                ProtoCard(
                  color: c.bgElevated,
                  child: Center(
                    child: Text(
                      'Nenhum rascunho pendente.',
                      style: SafeCoreType.micro.copyWith(color: c.fg3),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SincronizacaoCard extends StatelessWidget {
  final RascunhoLocal draft;
  final bool online;
  final VoidCallback onSincronizar;
  final VoidCallback onExcluir;

  const _SincronizacaoCard({
    required this.draft,
    required this.online,
    required this.onSincronizar,
    required this.onExcluir,
  });

  Future<void> _confirmarExclusao(BuildContext context) async {
    final c = context.c;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF151A21),
        title: Text('Excluir rascunho?', style: TextStyle(color: c.fg0, fontWeight: FontWeight.w900)),
        content: Text(
          'Os dados preenchidos offline serão perdidos.',
          style: TextStyle(color: c.fg2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: TextStyle(color: c.fg2)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: c.statusRedFg),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar == true) onExcluir();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final isNc = draft.tipo == 'NC';
    final statusLabel = switch (draft.status) {
      'sincronizando' => 'Sincronizando',
      'erro' => 'Erro',
      _ => 'Pendente',
    };
    final color = switch (draft.status) {
      'erro' => c.statusRedFg,
      'sincronizando' => c.statusYellowFg,
      _ => c.statusYellowFg,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ProtoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(color: color.withValues(alpha: .16), borderRadius: BorderRadius.circular(12)),
                  child: Icon(isNc ? Icons.shield_outlined : Icons.warning_amber_rounded, color: color, size: 23),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(spacing: 6, children: [
                        ProtoPill(label: draft.tipo, bg: isNc ? c.statusRedBg : c.statusYellowBg, fg: isNc ? c.statusRedFg : c.statusYellowFg),
                        ProtoPill(label: statusLabel, bg: color.withValues(alpha: .16), fg: color),
                      ]),
                      const SizedBox(height: 6),
                      Text(draft.titulo, maxLines: 2, overflow: TextOverflow.ellipsis, style: SafeCoreType.bodyStrong.copyWith(color: c.fg0)),
                      if (draft.status == 'erro' && draft.erroMensagem != null) ...[
                        const SizedBox(height: 4),
                        Text(draft.erroMensagem!, maxLines: 2, overflow: TextOverflow.ellipsis, style: SafeCoreType.micro.copyWith(color: c.statusRedFg)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(label: 'Sincronizar', onTap: online ? onSincronizar : null),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionButton(
                    label: 'Excluir',
                    danger: true,
                    onTap: () => _confirmarExclusao(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool danger;

  const _ActionButton({required this.label, required this.onTap, this.danger = false});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final enabled = onTap != null;
    final fg = danger ? c.statusRedFg : c.accent;
    return Material(
      color: enabled ? fg.withValues(alpha: .16) : c.bgElevated,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Center(
            child: Text(label, style: SafeCoreType.label.copyWith(color: enabled ? fg : c.fg3)),
          ),
        ),
      ),
    );
  }
}
