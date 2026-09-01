import 'package:flutter/material.dart';

import '../../../shared/widgets/prototype_ui.dart';

class TrechoManualResult {
  final String? clausulaReferencia;
  final String textoEditado;
  const TrechoManualResult({this.clausulaReferencia, required this.textoEditado});
}

/// Bottom sheet para escrever manualmente o trecho de uma norma vinculado a
/// uma NC (equivalente ao TrechoManualModal do web). Usado tanto no wizard de
/// criação quanto na edição — o chamador decide como persistir o resultado.
Future<TrechoManualResult?> showTrechoManualSheet(
  BuildContext context, {
  required String code,
  String? existingClausula,
  String? existingTexto,
}) {
  return showModalBottomSheet<TrechoManualResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: _TrechoManualSheet(
        code: code,
        existingClausula: existingClausula,
        existingTexto: existingTexto,
      ),
    ),
  );
}

class _TrechoManualSheet extends StatefulWidget {
  final String code;
  final String? existingClausula;
  final String? existingTexto;
  const _TrechoManualSheet({required this.code, this.existingClausula, this.existingTexto});

  @override
  State<_TrechoManualSheet> createState() => _TrechoManualSheetState();
}

class _TrechoManualSheetState extends State<_TrechoManualSheet> {
  late final _clauseRefCtrl = TextEditingController(text: widget.existingClausula ?? '');
  late final _textCtrl = TextEditingController(text: widget.existingTexto ?? '');
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _charCount = _textCtrl.text.length;
    _textCtrl.addListener(() => setState(() => _charCount = _textCtrl.text.length));
  }

  @override
  void dispose() {
    _clauseRefCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  TrechoManualResult? get _result {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return null;
    final ref = _clauseRefCtrl.text.trim();
    return TrechoManualResult(clausulaReferencia: ref.isEmpty ? null : ref, textoEditado: text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      decoration: const BoxDecoration(
        color: ProtoColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(color: ProtoColors.muted, borderRadius: BorderRadius.circular(99)),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            const Icon(Icons.edit_outlined, color: ProtoColors.blue, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Escrever trecho manual',
                      style: TextStyle(color: ProtoColors.text, fontSize: 16, fontWeight: FontWeight.w900)),
                  Text(widget.code, style: const TextStyle(color: ProtoColors.muted, fontSize: 12)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.close, color: ProtoColors.muted),
            ),
          ]),
          const SizedBox(height: 16),
          const Text('Cláusula / Item',
              style: TextStyle(color: ProtoColors.text, fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('opcional', style: TextStyle(color: ProtoColors.muted, fontSize: 11)),
          const SizedBox(height: 8),
          Container(
            height: 44,
            decoration: BoxDecoration(
                color: ProtoColors.surface2, borderRadius: BorderRadius.circular(10), border: Border.all(color: ProtoColors.border)),
            child: TextField(
              controller: _clauseRefCtrl,
              style: const TextStyle(color: ProtoColors.text, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Ex: 12.38, item 4.2…',
                hintStyle: TextStyle(color: ProtoColors.muted, fontSize: 13),
                contentPadding: EdgeInsets.symmetric(horizontal: 14),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Row(children: [
            Text('Texto do trecho', style: TextStyle(color: ProtoColors.text, fontSize: 13, fontWeight: FontWeight.w700)),
            SizedBox(width: 6),
            Text('*', style: TextStyle(color: ProtoColors.red, fontSize: 13, fontWeight: FontWeight.w900)),
          ]),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
                color: ProtoColors.surface2, borderRadius: BorderRadius.circular(10), border: Border.all(color: ProtoColors.border)),
            child: TextField(
              controller: _textCtrl,
              maxLines: 5,
              style: const TextStyle(color: ProtoColors.text, fontSize: 13, height: 1.4),
              decoration: const InputDecoration(
                hintText: 'Cole ou escreva o trecho da norma aqui…',
                hintStyle: TextStyle(color: ProtoColors.muted, fontSize: 13),
                contentPadding: EdgeInsets.all(14),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text('$_charCount caracteres', style: const TextStyle(color: ProtoColors.muted2, fontSize: 11)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: SizedBox(
                height: 46,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      foregroundColor: ProtoColors.text,
                      side: const BorderSide(color: ProtoColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 46,
                child: AnimatedBuilder(
                  animation: _textCtrl,
                  builder: (_, __) {
                    final result = _result;
                    return FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: result != null ? ProtoColors.blue : ProtoColors.surface2,
                        foregroundColor: result != null ? Colors.white : ProtoColors.muted,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: result != null ? () => Navigator.pop(context, result) : null,
                      icon: const Icon(Icons.link_rounded, size: 16),
                      label: const Text('Adicionar trecho', style: TextStyle(fontWeight: FontWeight.w900)),
                    );
                  },
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
