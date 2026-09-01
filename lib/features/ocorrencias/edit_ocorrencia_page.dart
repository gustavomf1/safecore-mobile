import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'detail_page.dart' show ncDetailProvider;
import 'model/criar_desvio_request.dart';
import 'model/criar_nc_request.dart';
import 'model/desvio_detail.dart';
import 'model/localizacao.dart';
import 'model/nc_detail.dart';
import 'model/nc_trecho_norma.dart';
import 'model/norma.dart';
import 'model/usuario_summary.dart';
import 'nc_reincidencia.dart';
import 'repository/desvio_repository_impl.dart';
import 'repository/nc_repository_impl.dart';
import 'repository/nc_trecho_norma_repository_impl.dart';
import 'repository/support_repository_impl.dart';
import 'widgets/trecho_manual_sheet.dart';

class _EColors {
  static const bg = Color(0xFF0B1118);
  static const surface = Color(0xFF151A21);
  static const surface2 = Color(0xFF1A2028);
  static const border = Color(0xFF26303B);
  static const text = Color(0xFFF8FBFF);
  static const muted = Color(0xFF566170);
  static const muted2 = Color(0xFF3F4A57);
  static const blue = Color(0xFF58A6FF);
  static const red = Color(0xFFFF4D4D);
  static const green = Color(0xFF3FB950);
  static const orange = Color(0xFFFF7A1A);
}

class EditOcorrenciaPage extends ConsumerWidget {
  final String tipo; // 'nc' | 'desvio'
  final String id;
  const EditOcorrenciaPage({super.key, required this.tipo, required this.id});

  bool get isNc => tipo == 'nc';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isNc) {
      final ncAsync = ref.watch(ncDetailProvider(id));
      final trechosAsync = ref.watch(ncTrechosProvider(id));
      if (ncAsync.isLoading || trechosAsync.isLoading) {
        return const _EditScaffold(child: Center(child: CircularProgressIndicator()));
      }
      if (ncAsync.hasError) {
        return _EditScaffold(
          child: Center(
            child: Text('Erro ao carregar: ${ncAsync.error}', style: const TextStyle(color: _EColors.red)),
          ),
        );
      }
      // Trechos de norma são um extra sobre o formulário, não um bloqueio:
      // se a listagem falhar (ex.: permissão), a edição segue sem eles em
      // vez de travar a tela inteira por causa de um recurso secundário.
      return _EditForm(
        tipo: tipo,
        id: id,
        nc: ncAsync.value,
        desvio: null,
        initialTrechos: trechosAsync.value ?? const [],
      );
    }
    final async = ref.watch(desvioDetailProvider(id));
    return async.when(
      loading: () => const _EditScaffold(child: Center(child: CircularProgressIndicator())),
      error: (err, _) => _EditScaffold(
        child: Center(
          child: Text('Erro ao carregar: $err', style: const TextStyle(color: _EColors.red)),
        ),
      ),
      data: (d) => _EditForm(tipo: tipo, id: id, nc: null, desvio: d),
    );
  }
}

class _EditScaffold extends StatelessWidget {
  final Widget child;
  const _EditScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _EColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const _EditHeader(title: 'Editar'),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 38,
      child: IconButton(
        style: IconButton.styleFrom(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: _EColors.muted2),
          ),
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 19, color: _EColors.text),
      ),
    );
  }
}

class _EditHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _EditHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      decoration: const BoxDecoration(
        color: _EColors.surface,
        border: Border(bottom: BorderSide(color: _EColors.border)),
      ),
      child: Row(
        children: [
          _HeaderIconButton(
            icon: Icons.chevron_left_rounded,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: _EColors.text, fontSize: 14, fontWeight: FontWeight.w900)),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!,
                      style: const TextStyle(
                          color: _EColors.muted, fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditForm extends ConsumerStatefulWidget {
  final String tipo;
  final String id;
  final NcDetail? nc;
  final DesvioDetail? desvio;
  final List<NcTrechoNorma> initialTrechos;
  const _EditForm({
    required this.tipo,
    required this.id,
    this.nc,
    this.desvio,
    this.initialTrechos = const [],
  });

  @override
  ConsumerState<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends ConsumerState<_EditForm> {
  bool get isNc => widget.tipo == 'nc';

  late final _tituloCtrl = TextEditingController(
    text: isNc ? widget.nc!.titulo : widget.desvio!.titulo,
  );
  late final _descCtrl = TextEditingController(
    text: (isNc ? widget.nc!.descricao : widget.desvio!.descricao) ?? '',
  );

  late final _orientacaoCtrl = TextEditingController(
    text: widget.desvio?.orientacaoRealizada ?? '',
  );

  late int _severidade = widget.nc?.severidade ?? 0;
  late int _probabilidade = widget.nc?.probabilidade ?? 0;
  late bool _regraDeOuro = isNc ? widget.nc!.regraDeOuro : widget.desvio!.regraDeOuro;
  late bool _reincidencia = widget.nc?.reincidencia ?? false;
  late String? _ncAnteriorId = widget.nc?.ncAnteriorId;
  late String? _localizacaoId = isNc ? widget.nc!.localizacaoId : widget.desvio!.localizacaoId;
  late String? _responsavelTratativaId =
      isNc ? widget.nc!.responsavelTrativaId : widget.desvio!.responsavelTratativaId;
  late String? _responsavelNcId = widget.nc?.responsavelNcId;
  late String? _responsavelDesvioId = widget.desvio?.responsavelDesvioId;
  late final Set<String> _normaIds =
      isNc ? widget.nc!.normas.map((n) => n['id'] as String).toSet() : <String>{};

  // Trechos de norma: estado desejado (staged) vs. o que já está persistido —
  // a diferença entre os dois é o que _salvar() precisa criar/apagar.
  late final Map<String, NcTrechoNorma> _persistedTrechos = {
    for (final t in widget.initialTrechos) t.normaId: t,
  };
  late final Map<String, TrechoManualResult> _trechos = {
    for (final t in widget.initialTrechos)
      t.normaId: TrechoManualResult(clausulaReferencia: t.clausulaReferencia, textoEditado: t.textoEditado),
  };

  bool _saving = false;
  String? _error;

  String get _estabelecimentoId => isNc ? widget.nc!.estabelecimentoId : widget.desvio!.estabelecimentoId;
  String? get _empresaContratadaId => isNc ? widget.nc!.empresaContratadaId : widget.desvio!.empresaContratadaId;

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    _orientacaoCtrl.dispose();
    super.dispose();
  }

  /// Aplica o diff entre o que estava persistido e o estado desejado
  /// (_trechos). Não há PUT no backend — trocar o texto de um trecho já
  /// salvo é apagar o registro antigo e criar um novo.
  Future<void> _flushTrechos() async {
    final repo = ref.read(ncTrechoNormaRepositoryProvider);
    // Itera sobre cópias — o corpo mutila _persistedTrechos para que, se uma
    // chamada no meio do caminho falhar, um novo "Salvar" retome do estado
    // real (já refletido no servidor) em vez de repetir operações concluídas.
    for (final entry in _persistedTrechos.entries.toList()) {
      final normaId = entry.key;
      final persisted = entry.value;
      final desired = _trechos[normaId];
      if (desired == null) {
        await repo.deletar(widget.id, persisted.id);
        _persistedTrechos.remove(normaId);
      } else if (desired.textoEditado != persisted.textoEditado ||
          desired.clausulaReferencia != persisted.clausulaReferencia) {
        await repo.deletar(widget.id, persisted.id);
        _persistedTrechos.remove(normaId);
        final novo = await repo.vincular(widget.id,
            normaId: normaId, clausulaReferencia: desired.clausulaReferencia, textoEditado: desired.textoEditado);
        _persistedTrechos[normaId] = novo;
      }
    }
    for (final entry in _trechos.entries.toList()) {
      if (!_persistedTrechos.containsKey(entry.key)) {
        final novo = await repo.vincular(widget.id,
            normaId: entry.key, clausulaReferencia: entry.value.clausulaReferencia, textoEditado: entry.value.textoEditado);
        _persistedTrechos[entry.key] = novo;
      }
    }
  }

  Future<void> _salvar() async {
    if (_tituloCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Título é obrigatório.');
      return;
    }
    if (isNc && _reincidencia && _ncAnteriorId == null) {
      setState(() => _error = 'Selecione a NC anterior ou desmarque Reincidência.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final descricao = _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim();
      if (isNc) {
        final req = CriarNcRequest(
          estabelecimentoId: _estabelecimentoId,
          titulo: _tituloCtrl.text.trim(),
          descricao: descricao,
          severidade: _severidade > 0 ? _severidade : null,
          probabilidade: _probabilidade > 0 ? _probabilidade : null,
          regraDeOuro: _regraDeOuro,
          reincidencia: _reincidencia,
          localizacaoId: _localizacaoId,
          responsavelNcId: _responsavelNcId,
          responsavelTrativaId: _responsavelTratativaId,
          ncAnteriorId: _reincidencia ? _ncAnteriorId : null,
          normaIds: _normaIds.toList(),
          empresaContratadaId: _empresaContratadaId,
        );
        await ref.read(ncRepositoryProvider).atualizar(widget.id, req);
        await _flushTrechos();
        ref.invalidate(ncDetailProvider(widget.id));
        ref.invalidate(ncTrechosProvider(widget.id));
      } else {
        final req = CriarDesvioRequest(
          estabelecimentoId: _estabelecimentoId,
          titulo: _tituloCtrl.text.trim(),
          descricao: descricao,
          localizacaoId: _localizacaoId,
          orientacaoRealizada: _orientacaoCtrl.text.trim().isEmpty ? null : _orientacaoCtrl.text.trim(),
          regraDeOuro: _regraDeOuro,
          responsavelDesvioId: _responsavelDesvioId,
          responsavelTratativaId: _responsavelTratativaId,
          empresaContratadaId: _empresaContratadaId,
        );
        await ref.read(desvioRepositoryProvider).atualizar(widget.id, req);
        ref.invalidate(desvioDetailProvider(widget.id));
      }
      if (mounted) context.pop();
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map && data['message'] is String ? data['message'] as String : null;
      setState(() => _error = message ?? 'Falha ao salvar: $e');
    } catch (e) {
      setState(() => _error = 'Falha ao salvar: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _EColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _EditHeader(
              title: isNc ? 'Editar NC' : 'Editar Desvio',
              subtitle: _tituloCtrl.text.trim().isEmpty ? null : _tituloCtrl.text.trim(),
            ),
            Expanded(child: _buildForm(context)),
            _EditFooter(
              saving: _saving,
              canSave: _empresaContratadaId != null,
              onCancel: () => Navigator.of(context).maybePop(),
              onSave: _salvar,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      children: [
        if (_error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0x22FF4D4D),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _EColors.red.withValues(alpha: .4)),
                ),
                child: Text(_error!, style: const TextStyle(color: _EColors.red, fontSize: 13)),
              ),
            _EField(
              label: 'Título',
              helper: 'Resumo curto que aparecerá nas listagens',
              child: _EInput(controller: _tituloCtrl),
            ),
            const SizedBox(height: 20),
            _EField(
              label: isNc ? 'Descrição Detalhada' : 'Descrição Curta',
              helper: isNc
                  ? 'Descreva fato, local e impacto.'
                  : 'Descreva brevemente o desvio identificado.',
              child: _EInput(controller: _descCtrl, maxLines: isNc ? 5 : 3),
            ),
            const SizedBox(height: 20),
            _EField(
              label: 'Localização',
              child: _LocalizacaoField(
                estabelecimentoId: _estabelecimentoId,
                selected: _localizacaoId,
                onChanged: (v) => setState(() => _localizacaoId = v),
              ),
            ),
            const SizedBox(height: 16),
            _SignalCheckRow(
              checked: _regraDeOuro,
              title: 'Regra de Ouro',
              subtitle: 'Marque se a ocorrência viola uma regra crítica de segurança',
              color: _EColors.red,
              onTap: () => setState(() => _regraDeOuro = !_regraDeOuro),
            ),
            if (isNc) ...[
              const SizedBox(height: 16),
              _SignalCheckRow(
                checked: _reincidencia,
                title: 'Reincidência',
                subtitle: 'Marque se esta NC é recorrência de uma ocorrência anterior',
                color: _EColors.orange,
                onTap: () => setState(() {
                  _reincidencia = !_reincidencia;
                  if (!_reincidencia) _ncAnteriorId = null;
                }),
              ),
              if (_reincidencia) ...[
                const SizedBox(height: 10),
                _NcAnteriorField(
                  estabelecimentoId: _estabelecimentoId,
                  excludeId: widget.id,
                  selectedId: _ncAnteriorId,
                  onChanged: (v) => setState(() => _ncAnteriorId = v),
                ),
              ],
              const SizedBox(height: 20),
              _EField(
                label: 'Matriz de Risco',
                child: _RiscoPicker(
                  severidade: _severidade,
                  probabilidade: _probabilidade,
                  onSeveridade: (v) => setState(() => _severidade = v),
                  onProbabilidade: (v) => setState(() => _probabilidade = v),
                ),
              ),
              const SizedBox(height: 20),
              _EField(
                label: 'Normas',
                child: _NormasChecklist(
                  selectedIds: _normaIds,
                  onToggle: (normaId) => setState(() {
                    if (_normaIds.contains(normaId)) {
                      _normaIds.remove(normaId);
                      _trechos.remove(normaId);
                    } else {
                      _normaIds.add(normaId);
                    }
                  }),
                  trechos: _trechos,
                  onTrechoChanged: (normaId, trecho) => setState(() {
                    if (trecho == null) {
                      _trechos.remove(normaId);
                    } else {
                      _trechos[normaId] = trecho;
                    }
                  }),
                ),
              ),
              const SizedBox(height: 20),
              _EField(
                label: 'Responsável pela NC',
                child: _ResponsavelField(
                  sourceId: _estabelecimentoId,
                  porEmpresa: false,
                  filterPerfis: const ['ENGENHEIRO', 'TECNICO'],
                  selectedId: _responsavelNcId,
                  onChanged: (v) => setState(() => _responsavelNcId = v),
                ),
              ),
            ] else ...[
              const SizedBox(height: 20),
              _EField(
                label: 'Orientação Realizada',
                child: _EInput(controller: _orientacaoCtrl, maxLines: 3),
              ),
              const SizedBox(height: 20),
              _EField(
                label: 'Responsável pelo Desvio',
                child: _ResponsavelField(
                  sourceId: _estabelecimentoId,
                  porEmpresa: false,
                  filterPerfis: const ['ENGENHEIRO', 'TECNICO'],
                  selectedId: _responsavelDesvioId,
                  onChanged: (v) => setState(() => _responsavelDesvioId = v),
                ),
              ),
            ],
            const SizedBox(height: 16),
            _EField(
              label: 'Responsável pela Tratativa',
              child: _empresaContratadaId == null
                  ? const Text('Empresa contratada não definida nesta ocorrência.',
                      style: TextStyle(color: _EColors.muted2, fontSize: 12))
                  : _ResponsavelField(
                      sourceId: _empresaContratadaId!,
                      porEmpresa: true,
                      filterPerfis: const ['EXTERNO', 'ENGENHEIRO'],
                      selectedId: _responsavelTratativaId,
                      onChanged: (v) => setState(() => _responsavelTratativaId = v),
                    ),
            ),
            if (_empresaContratadaId == null)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Esta ocorrência não tem empresa contratada definida e não pode ser salva pelo app. Edite pelo sistema web.',
                  style: TextStyle(color: _EColors.red, fontSize: 12),
                ),
              ),
      ],
    );
  }
}

class _EField extends StatelessWidget {
  final String label;
  final Widget child;
  final String? helper;
  const _EField({required this.label, required this.child, this.helper});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(
                color: _EColors.muted, fontSize: 12, letterSpacing: .45, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        child,
        if (helper != null) ...[
          const SizedBox(height: 6),
          Text(helper!, style: const TextStyle(color: _EColors.muted2, fontSize: 11)),
        ],
      ],
    );
  }
}

class _EInput extends StatelessWidget {
  final TextEditingController controller;
  final int maxLines;
  const _EInput({required this.controller, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: _EColors.text, fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: _EColors.surface2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _EColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _EColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _EColors.blue),
        ),
      ),
    );
  }
}

class _NcAnteriorField extends ConsumerWidget {
  final String estabelecimentoId;
  final String excludeId;
  final String? selectedId;
  final ValueChanged<String?> onChanged;
  const _NcAnteriorField({
    required this.estabelecimentoId,
    required this.excludeId,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(ncListProvider(estabelecimentoId));
    return async.when(
      loading: () => const SizedBox(
        height: 18,
        width: 18,
        child: CircularProgressIndicator(strokeWidth: 2, color: _EColors.orange),
      ),
      error: (_, __) => const Text('Erro ao carregar NCs', style: TextStyle(color: _EColors.red, fontSize: 12)),
      data: (todos) {
        final ncs = todos.where((nc) => nc.id != excludeId).toList();
        final warning = selectedId == null ? null : reincidenciaChainEnd(ncs, selectedId!, excludeId: excludeId);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: _EColors.surface2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: warning != null ? _EColors.orange : _EColors.orange.withValues(alpha: .5)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  isExpanded: true,
                  dropdownColor: _EColors.surface,
                  value: ncs.any((nc) => nc.id == selectedId) ? selectedId : null,
                  hint: const Text('Selecionar NC anterior', style: TextStyle(color: _EColors.muted, fontSize: 13)),
                  style: const TextStyle(color: _EColors.text, fontSize: 13),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('— Nenhuma', style: TextStyle(color: _EColors.muted, fontSize: 13))),
                    ...ncs.map((nc) => DropdownMenuItem(
                          value: nc.id,
                          child: Text('${nc.titulo} · ${nc.status}', maxLines: 1, overflow: TextOverflow.ellipsis),
                        )),
                  ],
                  onChanged: onChanged,
                ),
              ),
            ),
            if (warning != null) ...[
              const SizedBox(height: 8),
              _ReincidenciaWarning(ultimaNcTitulo: warning.titulo, onUsarEsta: () => onChanged(warning.id)),
            ],
          ],
        );
      },
    );
  }
}

class _ReincidenciaWarning extends StatelessWidget {
  final String ultimaNcTitulo;
  final VoidCallback onUsarEsta;
  const _ReincidenciaWarning({required this.ultimaNcTitulo, required this.onUsarEsta});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _EColors.orange.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _EColors.orange.withValues(alpha: .4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚠ Esta NC já possui uma reincidência registrada',
              style: TextStyle(color: _EColors.orange, fontSize: 12, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Para manter o rastro linear, selecione a última NC da cadeia:',
              style: TextStyle(color: _EColors.muted, fontSize: 11)),
          const SizedBox(height: 8),
          Text(ultimaNcTitulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: _EColors.text, fontSize: 12, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onUsarEsta,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _EColors.orange.withValues(alpha: .18),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _EColors.orange),
              ),
              child: const Text('Usar esta NC',
                  style: TextStyle(color: _EColors.orange, fontSize: 12, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocalizacaoField extends ConsumerWidget {
  final String estabelecimentoId;
  final String? selected;
  final ValueChanged<String?> onChanged;
  const _LocalizacaoField({required this.estabelecimentoId, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(localizacoesProvider(estabelecimentoId));
    return async.when(
      loading: () => const SizedBox(
        height: 46,
        child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
      ),
      error: (_, __) => const Text('Erro ao carregar localizações', style: TextStyle(color: _EColors.red, fontSize: 12)),
      data: (locs) {
        final items = locs.cast<Localizacao>();
        return Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: _EColors.surface2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _EColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: items.any((l) => l.id == selected) ? selected : null,
              hint: const Text('Selecione...', style: TextStyle(color: _EColors.muted, fontSize: 14)),
              isExpanded: true,
              dropdownColor: _EColors.surface2,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _EColors.muted),
              items: items
                  .map((l) => DropdownMenuItem<String?>(
                        value: l.id,
                        child: Text(l.nome, style: const TextStyle(color: _EColors.text, fontSize: 14)),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        );
      },
    );
  }
}

const _sevOpts = [
  (value: 1, label: 'Insignificante', color: Color(0xFF3fb950)),
  (value: 2, label: 'Pequena', color: Color(0xFF3fb950)),
  (value: 3, label: 'Moderada', color: Color(0xFFd29922)),
  (value: 4, label: 'Alta', color: Color(0xFFf97316)),
  (value: 5, label: 'Catastrófica', color: Color(0xFFf85149)),
];

const _probOpts = [
  (value: 1, label: 'Rara', color: Color(0xFF3fb950)),
  (value: 2, label: 'Improvável', color: Color(0xFF3fb950)),
  (value: 3, label: 'Possível', color: Color(0xFFd29922)),
  (value: 4, label: 'Provável', color: Color(0xFFf97316)),
];

Color _riskColor(int score) {
  if (score <= 4) return _EColors.green;
  if (score <= 9) return const Color(0xFFDCA31D);
  if (score <= 15) return _EColors.orange;
  return _EColors.red;
}

String _riskLabel(int score) {
  if (score <= 4) return 'Risco Baixo';
  if (score <= 9) return 'Risco Moderado';
  if (score <= 15) return 'Risco Alto';
  return 'Risco Crítico';
}

class _RiscoPicker extends StatelessWidget {
  final int severidade;
  final int probabilidade;
  final ValueChanged<int> onSeveridade;
  final ValueChanged<int> onProbabilidade;
  const _RiscoPicker({
    required this.severidade,
    required this.probabilidade,
    required this.onSeveridade,
    required this.onProbabilidade,
  });

  @override
  Widget build(BuildContext context) {
    final score = severidade * probabilidade;
    final hasScore = severidade > 0 && probabilidade > 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _EColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _EColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SEVERIDADE',
              style: TextStyle(color: _EColors.muted, fontSize: 11, letterSpacing: .4, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          _RampRow(
              value: severidade,
              options: _sevOpts,
              onPick: (v) => onSeveridade(severidade == v ? 0 : v)),
          const SizedBox(height: 18),
          const Text('PROBABILIDADE',
              style: TextStyle(color: _EColors.muted, fontSize: 11, letterSpacing: .4, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          _RampRow(
              value: probabilidade,
              options: _probOpts,
              onPick: (v) => onProbabilidade(probabilidade == v ? 0 : v)),
          const SizedBox(height: 20),
          const Row(
            children: [
              Expanded(
                  child: Text('Matriz de Risco 5×4',
                      style: TextStyle(color: Color(0xFFD7E8FF), fontSize: 13, fontWeight: FontWeight.w900))),
              Text('SEV × PROB',
                  style: TextStyle(color: _EColors.muted, fontSize: 10, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 12),
          const Row(children: [
            SizedBox(width: 28),
            _Axis('P1'),
            _Axis('P2'),
            _Axis('P3'),
            _Axis('P4'),
          ]),
          for (int s = 5; s >= 1; s--)
            Row(
              children: [
                SizedBox(
                    width: 28,
                    child: Text('S$s',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: _EColors.muted, fontSize: 11, fontWeight: FontWeight.w800))),
                for (int p = 1; p <= 4; p++)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        onSeveridade(s);
                        onProbabilidade(p);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        height: 44,
                        margin: const EdgeInsets.all(2.5),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _riskColor(s * p),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: severidade == s && probabilidade == p ? Colors.white : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: severidade == s && probabilidade == p
                              ? [BoxShadow(color: Colors.white.withValues(alpha: .28), blurRadius: 0, spreadRadius: 2)]
                              : null,
                        ),
                        child: Text('${s * p}',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ),
              ],
            ),
          if (hasScore) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: _EColors.surface2, borderRadius: BorderRadius.circular(10), border: Border.all(color: _EColors.border)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('PONTUAÇÃO',
                            style: TextStyle(color: _EColors.muted, fontSize: 10, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Text(_riskLabel(score),
                            style: TextStyle(color: _riskColor(score), fontSize: 12, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                  Text('$score',
                      style: TextStyle(color: _riskColor(score), fontSize: 25, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Axis extends StatelessWidget {
  final String text;
  const _Axis(this.text);
  @override
  Widget build(BuildContext context) => Expanded(
      child: Center(
          child: Text(text,
              style: const TextStyle(color: _EColors.muted, fontSize: 11, fontWeight: FontWeight.w800))));
}

class _RampRow extends StatelessWidget {
  final int value;
  final List<({int value, String label, Color color})> options;
  final ValueChanged<int> onPick;
  const _RampRow({required this.value, required this.options, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.map((o) {
        final active = value == o.value;
        return Expanded(
          child: GestureDetector(
            onTap: () => onPick(o.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: active ? o.color.withValues(alpha: .18) : _EColors.surface2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: active ? o.color : _EColors.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${o.value}',
                      style: TextStyle(color: active ? o.color : _EColors.text, fontSize: 16, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 3),
                  Text(
                    o.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: active ? o.color : _EColors.muted, fontSize: 9, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _NormasChecklist extends ConsumerWidget {
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;
  final Map<String, TrechoManualResult> trechos;
  final void Function(String normaId, TrechoManualResult? trecho) onTrechoChanged;
  const _NormasChecklist({
    required this.selectedIds,
    required this.onToggle,
    required this.trechos,
    required this.onTrechoChanged,
  });

  Future<void> _openManual(BuildContext context, Norma n) async {
    final existing = trechos[n.id];
    final result = await showTrechoManualSheet(
      context,
      code: n.codigo,
      existingClausula: existing?.clausulaReferencia,
      existingTexto: existing?.textoEditado,
    );
    if (result != null) onTrechoChanged(n.id, result);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(normasProvider);
    return async.when(
      loading: () => const SizedBox(
        height: 46,
        child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
      ),
      error: (_, __) => const Text('Erro ao carregar normas', style: TextStyle(color: _EColors.red, fontSize: 12)),
      data: (normas) {
        final items = normas.cast<Norma>();
        if (items.isEmpty) {
          return const Text('Nenhuma norma cadastrada.', style: TextStyle(color: _EColors.muted2, fontSize: 12));
        }
        return Column(
          children: items.map((n) {
            final checked = selectedIds.contains(n.id);
            final trecho = trechos[n.id];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: checked ? _EColors.blue.withValues(alpha: .08) : _EColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: checked ? _EColors.blue : _EColors.border),
                ),
                child: Column(children: [
                  InkWell(
                    onTap: () => onToggle(n.id),
                    borderRadius:
                        checked ? const BorderRadius.vertical(top: Radius.circular(10)) : BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                      child: Row(children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: checked ? _EColors.blue : Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: checked ? _EColors.blue : _EColors.muted2, width: 1.5),
                          ),
                          child: checked ? const Icon(Icons.check, color: Colors.white, size: 13) : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(n.nome,
                              style: TextStyle(
                                  color: checked ? _EColors.blue : _EColors.text,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ]),
                    ),
                  ),
                  if (checked) ...[
                    Container(height: 1, color: _EColors.border),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (trecho != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: _EColors.surface2,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: _EColors.muted2),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.format_quote, color: _EColors.blue, size: 14),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      trecho.clausulaReferencia != null
                                          ? '${trecho.clausulaReferencia} — ${trecho.textoEditado}'
                                          : trecho.textoEditado,
                                      style: const TextStyle(color: _EColors.text, fontSize: 12, height: 1.4),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => onTrechoChanged(n.id, null),
                                    child: const Icon(Icons.close, color: _EColors.muted, size: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          GestureDetector(
                            onTap: () => _openManual(context, n),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: _EColors.surface2,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: _EColors.border),
                              ),
                              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.edit_outlined, color: _EColors.muted, size: 13),
                                SizedBox(width: 5),
                                Text('Escrever manual',
                                    style: TextStyle(color: _EColors.text, fontSize: 12, fontWeight: FontWeight.w700)),
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ]),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ResponsavelField extends ConsumerWidget {
  final String sourceId;
  final bool porEmpresa;
  final List<String> filterPerfis;
  final String? selectedId;
  final ValueChanged<String?> onChanged;
  const _ResponsavelField({
    required this.sourceId,
    required this.porEmpresa,
    required this.filterPerfis,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = porEmpresa
        ? ref.watch(usuariosPorEmpresaProvider(sourceId))
        : ref.watch(usuariosProvider(sourceId));
    return async.when(
      loading: () => const SizedBox(
        height: 46,
        child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
      ),
      error: (_, __) => const Text('Erro ao carregar usuários', style: TextStyle(color: _EColors.red, fontSize: 12)),
      data: (todos) {
        final usuarios = todos.cast<UsuarioSummary>().where((u) => filterPerfis.contains(u.perfil)).toList();
        final selected = usuarios.where((u) => u.id == selectedId).cast<UsuarioSummary?>().firstOrNull;
        return GestureDetector(
          onTap: () => _showPicker(context, usuarios, selected),
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: _EColors.surface2,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _EColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_outline_rounded, color: _EColors.muted, size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selected?.nome ?? 'Selecionar responsável',
                    style: TextStyle(
                      color: selected != null ? _EColors.text : _EColors.muted,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, color: _EColors.muted, size: 18),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPicker(BuildContext context, List<UsuarioSummary> usuarios, UsuarioSummary? selected) {
    // showModalBottomSheet resolve com `null` tanto quando o usuário toca fora
    // da sheet (cancelar) quanto quando escolhe explicitamente uma opção que
    // representa "nenhum". _PickResult existe só para distinguir os dois casos:
    // resultado `null` = cancelou (ignorar); `_PickResult(null)` = escolheu limpar.
    showModalBottomSheet<_PickResult>(
      context: context,
      backgroundColor: _EColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: const Text('— Nenhum —', style: TextStyle(color: _EColors.muted, fontSize: 14)),
              onTap: () => Navigator.pop(sheetContext, const _PickResult(null)),
            ),
            for (final u in usuarios)
              ListTile(
                title: Text(u.nome, style: const TextStyle(color: _EColors.text, fontSize: 14)),
                subtitle: Text(u.perfil, style: const TextStyle(color: _EColors.muted2, fontSize: 11)),
                trailing: u.id == selected?.id ? const Icon(Icons.check, color: _EColors.green) : null,
                onTap: () => Navigator.pop(sheetContext, _PickResult(u)),
              ),
          ],
        ),
      ),
    ).then((result) {
      if (result == null) return; // sheet fechada sem escolher nada
      onChanged(result.value?.id);
    });
  }
}

class _PickResult {
  final UsuarioSummary? value;
  const _PickResult(this.value);
}

class _SignalCheckRow extends StatelessWidget {
  final bool checked;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _SignalCheckRow({
    required this.checked,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: checked ? color.withValues(alpha: .07) : _EColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: checked ? color : _EColors.border),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: checked ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: checked ? color : _EColors.muted2, width: 1.5),
              ),
              child: checked ? const Icon(Icons.check, color: Colors.white, size: 13) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: checked ? color : _EColors.text,
                          fontSize: 13,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(color: _EColors.muted, fontSize: 11, height: 1.3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditFooter extends StatelessWidget {
  final bool saving;
  final bool canSave;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  const _EditFooter({
    required this.saving,
    required this.canSave,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
          color: _EColors.surface,
          border: Border(top: BorderSide(color: _EColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: _EditFooterButton(
                label: 'Cancelar',
                onTap: saving ? null : onCancel,
                primary: false,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: _EditFooterButton(
                label: 'Salvar',
                icon: Icons.check_rounded,
                loading: saving,
                onTap: (saving || !canSave) ? null : onSave,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditFooterButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool primary;
  final bool loading;
  final IconData? icon;
  const _EditFooterButton({
    required this.label,
    required this.onTap,
    this.primary = true,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: primary ? _EColors.blue : _EColors.surface2,
          foregroundColor: primary ? Colors.white : _EColors.text,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onTap,
        icon: loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : (primary ? Icon(icon ?? Icons.arrow_forward_rounded, size: 16) : const SizedBox.shrink()),
        label: Text(label, maxLines: 1, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }
}
