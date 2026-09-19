import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/theme/tokens.dart';
import 'provider/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1200), _checkSession);
  }

  Future<void> _checkSession() async {
    if (!mounted) return;
    debugPrint('[Splash] aguardando authProvider...');
    final session = await ref.read(authProvider.future).timeout(
      const Duration(seconds: 5),
      onTimeout: () => null,
    );
    debugPrint('[Splash] session: $session');
    if (!mounted) return;
    if (session == null) {
      context.go('/login');
    } else {
      final workspace = ref.read(workspaceProvider);
      final isExterno = session.perfil == 'EXTERNO';
      context.go((isExterno || workspace != null) ? '/feed' : '/workspace');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      backgroundColor: c.bgBase,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: .82, end: 1),
                  duration: const Duration(milliseconds: 650),
                  curve: Curves.easeOutBack,
                  builder: (_, scale, child) => Opacity(opacity: scale.clamp(0, 1), child: Transform.scale(scale: scale, child: child)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: c.accent.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(SafeCoreRadius.xl + 4),
                          border: Border.all(color: c.accent.withValues(alpha: .3), width: 1.5),
                          boxShadow: [
                            BoxShadow(color: c.accent.withValues(alpha: .18), blurRadius: 32, spreadRadius: 2),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(SafeCoreRadius.lg),
                          child: Image.asset(
                            'assets/icon/icon.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text('SafeCore', style: SafeCoreType.display.copyWith(color: c.fg0)),
                      const SizedBox(height: 8),
                      Text(
                        'SISTEMA DE GESTÃO DE SEGURANÇA',
                        style: SafeCoreType.micro.copyWith(color: c.fg2, letterSpacing: 1.4),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        width: 64,
                        height: 3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(SafeCoreRadius.pill),
                          gradient: LinearGradient(colors: [c.bgMuted, c.accent, c.bgMuted]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: SizedBox(
                width: 120,
                height: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(SafeCoreRadius.pill),
                  child: LinearProgressIndicator(
                    backgroundColor: c.bgMuted,
                    valueColor: AlwaysStoppedAnimation(c.accent),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
