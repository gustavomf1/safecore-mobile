import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/theme/tokens.dart';
import 'provider/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> with SingleTickerProviderStateMixin {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;
  bool remember = true;
  bool showPassword = false;
  String? _errorMsg;

  late final AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    _spinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() { loading = true; _errorMsg = null; });
    _spinController.repeat();
    try {
      await ref.read(authProvider.notifier).login(
        email.text.trim(),
        password.text,
      );
      if (!mounted) return;
      final authState = ref.read(authProvider);
      if (authState.hasError) {
        setState(() => _errorMsg = 'Erro ao conectar. Verifique suas credenciais.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMsg = 'Erro ao conectar. Verifique sua conexão.');
    } finally {
      if (mounted) {
        _spinController.stop();
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      backgroundColor: c.bgBase,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-bleed hero — SafeCore wordmark + tagline live in the top ~30%,
          // so keep alignment at topCenter or the form panel covers them on tall screens.
          const Image(
            image: AssetImage('assets/branding/login_hero.jpg'),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
          // Fades the photo into the flat background color so the form panel
          // below has no visible seam.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0, 0.5, 0.78, 1],
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    c.bgBase.withValues(alpha: .7),
                    c.bgBase,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  reverse: true,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 520),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(offset: Offset(0, 18 * (1 - value)), child: child),
                                );
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Bem-vindo de volta', style: SafeCoreType.headline.copyWith(color: c.fg0)),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Entre para registrar ocorrências e acompanhar tratativas em campo.',
                                    textAlign: TextAlign.center,
                                    style: SafeCoreType.bodyRegular.copyWith(color: c.fg2, fontSize: 13, height: 1.5),
                                  ),
                                  const SizedBox(height: 22),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: c.bgSurface,
                                      borderRadius: BorderRadius.circular(SafeCoreRadius.lg),
                                      border: Border.all(color: c.borderSoft),
                                      boxShadow: SafeCoreShadows.md,
                                    ),
                                    child: Column(
                                      children: [
                                        _LoginInput(controller: email, icon: Icons.mail_rounded, hint: 'seu@email.com.br', keyboardType: TextInputType.emailAddress),
                                        const SizedBox(height: 10),
                                        _LoginInput(
                                          controller: password,
                                          icon: Icons.lock_rounded,
                                          hint: 'Senha',
                                          obscure: !showPassword,
                                          trailing: showPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                          onTrailingTap: () => setState(() => showPassword = !showPassword),
                                        ),
                                        if (_errorMsg != null) ...[
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Icon(Icons.error_outline_rounded, color: c.statusRedFg, size: 14),
                                              const SizedBox(width: 6),
                                              Expanded(child: Text(_errorMsg!, style: SafeCoreType.body.copyWith(color: c.statusRedFg))),
                                            ],
                                          ),
                                        ],
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: InkWell(
                                                borderRadius: BorderRadius.circular(8),
                                                onTap: () => setState(() => remember = !remember),
                                                child: Row(
                                                  children: [
                                                    AnimatedContainer(
                                                      duration: SafeCoreMotion.fast,
                                                      width: 18,
                                                      height: 18,
                                                      decoration: BoxDecoration(
                                                        color: remember ? c.accent : Colors.transparent,
                                                        borderRadius: BorderRadius.circular(5),
                                                        border: Border.all(color: remember ? c.accent : c.borderMain),
                                                      ),
                                                      child: remember ? const Icon(Icons.check_rounded, color: Colors.white, size: 13) : null,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Flexible(
                                                      child: Text(
                                                        'Manter conectado',
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: SafeCoreType.label.copyWith(color: c.fg2),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            TextButton(
                                              onPressed: () => context.push('/esqueci-senha'),
                                              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 32), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                              child: Text('Esqueci a senha', style: SafeCoreType.label.copyWith(color: c.accent)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 18),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 52,
                                          child: FilledButton.icon(
                                            style: FilledButton.styleFrom(
                                              backgroundColor: c.accent,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SafeCoreRadius.md)),
                                            ),
                                            onPressed: loading ? null : _submit,
                                            icon: loading
                                                ? RotationTransition(
                                                    turns: _spinController,
                                                    child: const Icon(Icons.sync_rounded, size: 18),
                                                  )
                                                : const Icon(Icons.arrow_forward_rounded, size: 18),
                                            label: Text(loading ? 'Entrando...' : 'Entrar', style: SafeCoreType.subtitle.copyWith(color: Colors.white)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text('v1.0.0 · build 2026.05.06', style: SafeCoreType.micro.copyWith(color: c.fg3)),
                                  const SizedBox(height: 4),
                                  Text('SafeCore / SGS · ERS Engenharia', style: SafeCoreType.micro.copyWith(color: c.fg3)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginInput extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final IconData? trailing;
  final VoidCallback? onTrailingTap;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;

  const _LoginInput({
    required this.controller,
    required this.icon,
    required this.hint,
    this.trailing,
    this.onTrailingTap,
    this.obscure = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: c.bgElevated,
        borderRadius: BorderRadius.circular(SafeCoreRadius.md),
        border: Border.all(color: c.borderSoft),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: SafeCoreType.bodyMedium.copyWith(color: c.fg0),
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          hintText: hint,
          hintStyle: SafeCoreType.bodyMedium.copyWith(color: c.fg2),
          prefixIcon: Icon(icon, size: 17, color: c.fg2),
          suffixIcon: trailing == null
              ? null
              : IconButton(
                  icon: Icon(trailing, size: 17, color: c.fg2),
                  onPressed: onTrailingTap,
                ),
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
