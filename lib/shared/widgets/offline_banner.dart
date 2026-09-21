import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/connectivity_provider.dart';
import '../theme/tokens.dart';

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Enquanto o estado inicial de conectividade ainda não chegou, assume
    // online — evita um flash do aviso de "sem internet" logo na abertura
    // do app quando na verdade há conexão.
    final online = ref.watch(connectivityProvider).valueOrNull ?? true;
    if (online) return const SizedBox.shrink();

    final c = context.c;
    return SafeArea(
      bottom: false,
      child: Material(
        color: c.statusRedBg,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.wifi_off_rounded, color: c.statusRedFg, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Você está sem internet. Suas ações são limitadas.',
                  style: SafeCoreType.bodyStrong.copyWith(color: c.statusRedFg, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
