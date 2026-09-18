import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/theme/tokens.dart';
import '../../shared/widgets/prototype_ui.dart';
import '../auth/provider/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  static String _initials(String nome) {
    final parts = nome.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  static String _perfilLabel(String perfil, bool isAdmin) {
    if (isAdmin) return 'Administrador';
    return switch (perfil.toUpperCase()) {
      'ENGENHEIRO' => 'Engenheiro',
      'TECNICO'    => 'Técnico de Segurança',
      'EXTERNO'    => 'Externo',
      _            => perfil,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final user = ref.watch(authProvider).valueOrNull;
    final workspace = ref.watch(workspaceProvider);

    final nome = user?.nome ?? '—';
    final email = user?.email ?? '—';
    final perfil = user != null ? _perfilLabel(user.perfil, user.isAdmin) : '—';
    final initials = _initials(nome);

    return Scaffold(
      backgroundColor: c.bgBase,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 104),
          children: [
            // ── Avatar + identidade ────────────────────────────────────────
            ProtoCard(
              color: c.bgMuted,
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [c.accent, c.accentHover],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(SafeCoreRadius.lg),
                    ),
                    child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nome, style: SafeCoreType.title.copyWith(color: c.fg0)),
                        const SizedBox(height: 4),
                        Text(email, style: SafeCoreType.body.copyWith(color: c.fg2)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: c.accent.withValues(alpha: .18),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(perfil, style: SafeCoreType.label.copyWith(color: c.accent)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Workspace ─────────────────────────────────────────────────
            ProtoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ProtoSectionTitle('Workspace'),
                  const SizedBox(height: 14),
                  if (workspace != null) ...[
                    _Kv(label: 'Empresa', value: workspace.empresaFilha.nome),
                    _Kv(label: 'Contratante', value: workspace.empresa.nome),
                    _Kv(label: 'Estabelecimento', value: workspace.estabelecimento.nome),
                  ] else
                    _Kv(label: 'Workspace', value: 'Não selecionado', valueColor: c.fg2),
                  _Kv(label: 'Status', value: 'Online', valueColor: c.statusGreenFg),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── Configurações ─────────────────────────────────────────────
            _ProfileRow(icon: Icons.storage_rounded, label: 'Rascunhos locais', value: '', onTap: () => context.go('/drafts')),
            _ProfileRow(icon: Icons.help_outline_rounded, label: 'Ajuda & Suporte', value: '', onTap: () {}),
            const SizedBox(height: 8),

            // ── Logout ────────────────────────────────────────────────────
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                await ref.read(authProvider.notifier).logout();
              },
              child: ProtoCard(
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.logout_rounded, color: c.statusRedFg, size: 16),
                      const SizedBox(width: 8),
                      Text('Sair da conta', style: SafeCoreType.subtitle.copyWith(color: c.statusRedFg)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text('SafeCore/SGS · v1.0.0 (build 2026.05.06)', style: SafeCoreType.micro.copyWith(color: c.fg2)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Kv extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _Kv({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(child: Text(label, style: SafeCoreType.body.copyWith(color: c.fg2))),
          Flexible(child: Text(value, style: SafeCoreType.bodyStrong.copyWith(color: valueColor ?? c.fg0), textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ProfileRow({required this.icon, required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: ProtoCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(width: 32, height: 32, decoration: BoxDecoration(color: c.bgElevated, borderRadius: BorderRadius.circular(9)), child: Icon(icon, color: c.fg0, size: 17)),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: SafeCoreType.title.copyWith(color: c.fg0, fontSize: 15))),
              if (value.isNotEmpty) Text(value, style: SafeCoreType.body.copyWith(color: c.fg2)),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: c.fg2, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
