import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/theme/tokens.dart';
import 'repository/auth_repository_impl.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  int step = 0;
  String email = '';
  String resetToken = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.c.bgBase,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 6, 24, 22),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              child: _buildStep(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (step) {
      case 0:
        return _StepEmail(
          key: const ValueKey('email'),
          onNext: (e) => setState(() { email = e; step = 1; }),
        );
      case 1:
        return _StepCodigo(
          key: const ValueKey('codigo'),
          email: email,
          onNext: (rt) => setState(() { resetToken = rt; step = 2; }),
          onBack: () => setState(() => step = 0),
        );
      case 2:
        return _StepNovaSenha(
          key: const ValueKey('novaSenha'),
          resetToken: resetToken,
          onNext: () => setState(() => step = 3),
        );
      default:
        return const _StepSucesso(key: ValueKey('sucesso'));
    }
  }
}

class _StepEmail extends ConsumerStatefulWidget {
  final void Function(String email) onNext;
  const _StepEmail({super.key, required this.onNext});

  @override
  ConsumerState<_StepEmail> createState() => _StepEmailState();
}

class _StepEmailState extends ConsumerState<_StepEmail> {
  final email = TextEditingController();
  bool loading = false;
  String? error;

  bool get _valid => RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email.text.trim());

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_valid || loading) return;
    setState(() { loading = true; error = null; });
    try {
      final trimmed = email.text.trim();
      await ref.read(authRepositoryProvider).solicitarReset(trimmed);
      if (!mounted) return;
      widget.onNext(trimmed);
    } catch (_) {
      if (mounted) setState(() => error = 'Erro ao enviar código. Tente novamente.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ForgotCard(
      onBack: () => context.pop(),
      title: 'Esqueceu a senha?',
      subtitle: 'Informe o e-mail da sua conta e enviaremos um código de verificação de 6 dígitos.',
      child: Column(
        children: [
          _ForgotInput(
            controller: email,
            icon: Icons.mail_rounded,
            hint: 'seu@email.com.br',
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => setState(() {}),
          ),
          if (error != null) ...[
            const SizedBox(height: 8),
            _ErrorLine(error!),
          ],
          const SizedBox(height: 16),
          _PrimaryButton(
            label: 'Enviar código',
            loading: loading,
            enabled: _valid,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class _StepCodigo extends ConsumerStatefulWidget {
  final String email;
  final void Function(String resetToken) onNext;
  final VoidCallback onBack;
  const _StepCodigo({super.key, required this.email, required this.onNext, required this.onBack});

  @override
  ConsumerState<_StepCodigo> createState() => _StepCodigoState();
}

class _StepCodigoState extends ConsumerState<_StepCodigo> {
  final digits = List.generate(6, (_) => TextEditingController());
  final focus = List.generate(6, (_) => FocusNode());
  bool loading = false;
  bool err = false;

  bool get _complete => digits.every((c) => c.text.isNotEmpty);
  String get _code => digits.map((c) => c.text).join();

  @override
  void dispose() {
    for (final c in digits) { c.dispose(); }
    for (final f in focus) { f.dispose(); }
    super.dispose();
  }

  void _onChanged(int i, String v) {
    setState(() => err = false);
    if (v.isNotEmpty && i < 5) focus[i + 1].requestFocus();
  }

  Future<void> _verify() async {
    if (!_complete || loading) return;
    setState(() { loading = true; err = false; });
    try {
      final resetToken = await ref.read(authRepositoryProvider).verificarOtp(widget.email, _code);
      if (!mounted) return;
      widget.onNext(resetToken);
    } catch (_) {
      if (!mounted) return;
      setState(() => err = true);
      for (final c in digits) { c.clear(); }
      focus[0].requestFocus();
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final masked = _maskEmail(widget.email);
    return _ForgotCard(
      onBack: widget.onBack,
      title: 'Verifique seu e-mail',
      subtitle: 'Enviamos um código de 6 dígitos para $masked. Digite-o abaixo.',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (i) => SizedBox(
              width: 44,
              height: 52,
              child: TextField(
                controller: digits[i],
                focusNode: focus[i],
                textAlign: TextAlign.center,
                maxLength: 1,
                keyboardType: TextInputType.number,
                style: SafeCoreType.title.copyWith(color: c.fg0, fontSize: 20),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: c.bgElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: err ? c.statusRedFg : c.borderSoft),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: err ? c.statusRedFg : c.borderSoft),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: c.accent),
                  ),
                ),
                onChanged: (v) => _onChanged(i, v),
              ),
            )),
          ),
          if (err) ...[
            const SizedBox(height: 10),
            const _ErrorLine('Código incorreto. Tente novamente.'),
          ],
          const SizedBox(height: 18),
          _PrimaryButton(
            label: 'Verificar e continuar',
            loading: loading,
            enabled: _complete,
            onPressed: _verify,
          ),
        ],
      ),
    );
  }
}

class _StepNovaSenha extends ConsumerStatefulWidget {
  final String resetToken;
  final VoidCallback onNext;
  const _StepNovaSenha({super.key, required this.resetToken, required this.onNext});

  @override
  ConsumerState<_StepNovaSenha> createState() => _StepNovaSenhaState();
}

class _StepNovaSenhaState extends ConsumerState<_StepNovaSenha> {
  final pw = TextEditingController();
  final pw2 = TextEditingController();
  bool show = false;
  bool loading = false;
  String? error;

  Map<String, bool> get _checks => {
    'len': pw.text.length >= 8,
    'upper': RegExp(r'[A-Z]').hasMatch(pw.text),
    'num': RegExp(r'[0-9]').hasMatch(pw.text),
    'sym': RegExp(r'[^A-Za-z0-9]').hasMatch(pw.text),
  };
  bool get _allMet => _checks.values.every((v) => v);
  bool get _match => pw.text.isNotEmpty && pw.text == pw2.text;

  @override
  void dispose() {
    pw.dispose();
    pw2.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_allMet || !_match || loading) return;
    setState(() { loading = true; error = null; });
    try {
      await ref.read(authRepositoryProvider).redefinirSenha(widget.resetToken, pw.text);
      if (!mounted) return;
      widget.onNext();
    } catch (_) {
      if (mounted) setState(() => error = 'Erro ao redefinir senha. O código pode ter expirado.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  static const _reqs = [
    ('len', 'Mín. 8 caracteres'),
    ('upper', '1 letra maiúscula'),
    ('num', '1 número'),
    ('sym', '1 símbolo'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final checks = _checks;
    return _ForgotCard(
      onBack: null,
      title: 'Crie uma nova senha',
      subtitle: 'Escolha uma senha forte e diferente das anteriores.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nova senha', style: SafeCoreType.label.copyWith(color: c.fg2)),
          const SizedBox(height: 6),
          _ForgotInput(
            controller: pw,
            icon: Icons.lock_rounded,
            hint: '••••••••',
            obscure: !show,
            trailing: show ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            onTrailingTap: () => setState(() => show = !show),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: _reqs.map((r) {
              final met = checks[r.$1]!;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(met ? Icons.check_circle : Icons.circle_outlined,
                      size: 13, color: met ? c.statusGreenFg : c.fg2),
                  const SizedBox(width: 4),
                  Text(r.$2, style: SafeCoreType.body.copyWith(color: met ? c.fg0 : c.fg2)),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text('Confirmar nova senha', style: SafeCoreType.label.copyWith(color: c.fg2)),
          const SizedBox(height: 6),
          _ForgotInput(
            controller: pw2,
            icon: Icons.lock_rounded,
            hint: '••••••••',
            obscure: !show,
            onChanged: (_) => setState(() {}),
          ),
          if (pw2.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(_match ? Icons.check_circle : Icons.cancel,
                    size: 14, color: _match ? c.statusGreenFg : c.statusRedFg),
                const SizedBox(width: 6),
                Text(_match ? 'As senhas coincidem' : 'As senhas não coincidem',
                    style: SafeCoreType.body.copyWith(color: _match ? c.statusGreenFg : c.statusRedFg)),
              ],
            ),
          ],
          if (error != null) ...[
            const SizedBox(height: 10),
            _ErrorLine(error!),
          ],
          const SizedBox(height: 18),
          _PrimaryButton(
            label: 'Redefinir senha',
            loading: loading,
            enabled: _allMet && _match,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class _StepSucesso extends StatelessWidget {
  const _StepSucesso({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.bgSurface,
        borderRadius: BorderRadius.circular(SafeCoreRadius.lg),
        border: Border.all(color: c.borderSoft),
      ),
      constraints: const BoxConstraints(maxWidth: 380),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: c.statusGreenFg, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 34),
          ),
          const SizedBox(height: 18),
          Text('Senha alterada!', style: SafeCoreType.title.copyWith(color: c.fg0, fontSize: 20)),
          const SizedBox(height: 8),
          Text(
            'Sua senha foi redefinida com sucesso. Já pode acessar o sistema com a nova senha.',
            textAlign: TextAlign.center,
            style: SafeCoreType.bodyRegular.copyWith(color: c.fg2, fontSize: 12, height: 1.45),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: c.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SafeCoreRadius.md)),
              ),
              onPressed: () => context.go('/login'),
              child: Text('Ir para o login', style: SafeCoreType.subtitle.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForgotCard extends StatelessWidget {
  final VoidCallback? onBack;
  final String title;
  final String subtitle;
  final Widget child;

  const _ForgotCard({
    required this.onBack,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.bgSurface,
        borderRadius: BorderRadius.circular(SafeCoreRadius.lg),
        border: Border.all(color: c.borderSoft),
      ),
      constraints: const BoxConstraints(maxWidth: 380),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onBack != null)
            TextButton.icon(
              onPressed: onBack,
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 32)),
              icon: Icon(Icons.arrow_back_rounded, size: 15, color: c.fg2),
              label: Text('Voltar', style: SafeCoreType.label.copyWith(color: c.fg2)),
            ),
          if (onBack != null) const SizedBox(height: 8),
          Text(title, style: SafeCoreType.title.copyWith(color: c.fg0, fontSize: 20)),
          const SizedBox(height: 6),
          Text(subtitle, style: SafeCoreType.bodyRegular.copyWith(color: c.fg2, fontSize: 12, height: 1.45)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _ForgotInput extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final IconData? trailing;
  final VoidCallback? onTrailingTap;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const _ForgotInput({
    required this.controller,
    required this.icon,
    required this.hint,
    this.trailing,
    this.onTrailingTap,
    this.obscure = false,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: c.bgElevated,
        borderRadius: BorderRadius.circular(SafeCoreRadius.md),
        border: Border.all(color: c.borderSoft),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: SafeCoreType.bodyMedium.copyWith(color: c.fg0),
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          hintText: hint,
          prefixIcon: Icon(icon, size: 16, color: c.fg2),
          suffixIcon: trailing == null ? null : IconButton(
            icon: Icon(trailing, size: 16, color: c.fg2),
            onPressed: onTrailingTap,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool loading;
  final bool enabled;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.loading,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: c.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SafeCoreRadius.md)),
        ),
        onPressed: (enabled && !loading) ? onPressed : null,
        child: loading
            ? const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(label, style: SafeCoreType.subtitle.copyWith(color: Colors.white)),
      ),
    );
  }
}

class _ErrorLine extends StatelessWidget {
  final String message;
  const _ErrorLine(this.message);

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Row(
      children: [
        Icon(Icons.error_outline_rounded, color: c.statusRedFg, size: 14),
        const SizedBox(width: 6),
        Expanded(child: Text(message, style: SafeCoreType.body.copyWith(color: c.statusRedFg))),
      ],
    );
  }
}

String _maskEmail(String e) {
  final parts = e.split('@');
  if (parts.length != 2) return e;
  final local = parts[0];
  final domain = parts[1];
  final visible = local.length >= 2 ? local.substring(0, 2) : local;
  final dots = '•' * (local.length - visible.length).clamp(3, 20);
  return '$visible$dots@$domain';
}
