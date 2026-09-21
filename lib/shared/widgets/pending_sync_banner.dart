import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/connectivity_provider.dart';
import '../../features/auth/provider/auth_provider.dart';
import '../../features/ocorrencias/repository/draft_repository_impl.dart';
import '../theme/tokens.dart';

class PendingSyncBanner extends ConsumerWidget {
  const PendingSyncBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(connectivityProvider).valueOrNull ?? false;
    final usuarioId = ref.watch(authProvider).valueOrNull?.id;
    if (!online || usuarioId == null) return const SizedBox.shrink();

    final draftsAsync = ref.watch(draftsProvider(usuarioId));
    final count = draftsAsync.valueOrNull?.length ?? 0;
    if (count == 0) return const SizedBox.shrink();

    final c = context.c;
    return Material(
      color: c.statusYellowBg,
      child: InkWell(
        onTap: () => context.go('/sincronizacao'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.cloud_upload_outlined, color: c.statusYellowFg, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  count == 1
                      ? 'Você tem 1 item para sincronizar'
                      : 'Você tem $count itens para sincronizar',
                  style: SafeCoreType.body.copyWith(color: c.statusYellowFg),
                ),
              ),
              Text('Ver', style: SafeCoreType.bodyStrong.copyWith(color: c.statusYellowFg)),
            ],
          ),
        ),
      ),
    );
  }
}
