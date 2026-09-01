import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'detail_page.dart' show ncDetailProvider;
import 'model/criar_desvio_request.dart';
import 'model/criar_nc_request.dart';
import 'model/desvio_detail.dart';
import 'model/localizacao.dart';
import 'model/nc_detail.dart';
import 'model/norma.dart';
import 'model/usuario_summary.dart';
import 'repository/desvio_repository_impl.dart';
import 'repository/nc_repository_impl.dart';
import 'repository/support_repository_impl.dart';

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
}

class EditOcorrenciaPage extends ConsumerWidget {
  final String tipo; // 'nc' | 'desvio'
  final String id;
  const EditOcorrenciaPage({super.key, required this.tipo, required this.id});

  bool get isNc => tipo == 'nc';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isNc) {
      final async = ref.watch(ncDetailProvider(id));
      return async.when(
        loading: () => const _EditScaffold(child: Center(child: CircularProgressIndicator())),
        error: (err, _) => _EditScaffold(
          child: Center(
            child: Text('Erro ao carregar: $err', style: const TextStyle(color: _EColors.red)),
          ),
        ),
        data: (nc) => _EditForm(tipo: tipo, id: id, nc: nc, desvio: null),
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
      appBar: AppBar(
        backgroundColor: _EColors.bg,
        foregroundColor: _EColors.text,
        title: const Text('Editar'),
      ),
      body: SafeArea(child: child),
    );
  }
}

class _EditForm extends ConsumerStatefulWidget {
  final String tipo;
  final String id;
  final NcDetail? nc;
  final DesvioDetail? desvio;
  const _EditForm({required this.tipo, required this.id, this.nc, this.desvio});

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

  late int _severidade = widget.nc?.severidade ?? 0;
  late int _probabilidade = widget.nc?.probabilidade ?? 0;
  late bool _regraDeOuro = isNc ? widget.nc!.regraDeOuro : widget.desvio!.regraDeOuro;
  late String? _localizacaoId = isNc ? widget.nc!.localizacaoId : widget.desvio!.localizacaoId;
  late String? _responsavelTratativaId =
      isNc ? widget.nc!.responsavelTrativaId : widget.desvio!.responsavelTratativaId;
  late String? _responsavelNcId = widget.nc?.responsavelNcId;
  late String? _responsavelDesvioId = widget.desvio?.responsavelDesvioId;
  late final Set<String> _normaIds =
      isNc ? widget.nc!.normas.map((n) => n['id'] as String).toSet() : <String>{};

  bool _saving = false;
  String? _error;

  String get _estabelecimentoId => isNc ? widget.nc!.estabelecimentoId : widget.desvio!.estabelecimentoId;
  String? get _empresaContratadaId => isNc ? widget.nc!.empresaContratadaId : widget.desvio!.empresaContratadaId;

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_tituloCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Título é obrigatório.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final descricao = _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim();
      if (isNc) {
        final nc = widget.nc!;
        final req = CriarNcRequest(
          estabelecimentoId: _estabelecimentoId,
          titulo: _tituloCtrl.text.trim(),
          descricao: descricao,
          severidade: _severidade > 0 ? _severidade : null,
          probabilidade: _probabilidade > 0 ? _probabilidade : null,
          regraDeOuro: _regraDeOuro,
          reincidencia: nc.reincidencia,
          localizacaoId: _localizacaoId,
          responsavelNcId: _responsavelNcId,
          responsavelTrativaId: _responsavelTratativaId,
          ncAnteriorId: nc.ncAnteriorId,
          normaIds: _normaIds.toList(),
          empresaContratadaId: _empresaContratadaId,
        );
        await ref.read(ncRepositoryProvider).atualizar(widget.id, req);
        ref.invalidate(ncDetailProvider(widget.id));
      } else {
        final d = widget.desvio!;
        final req = CriarDesvioRequest(
          estabelecimentoId: _estabelecimentoId,
          titulo: _tituloCtrl.text.trim(),
          descricao: descricao,
          localizacaoId: _localizacaoId,
          orientacaoRealizada: d.orientacaoRealizada,
          regraDeOuro: _regraDeOuro,
          responsavelDesvioId: _responsavelDesvioId,
          responsavelTratativaId: _responsavelTratativaId,
          empresaContratadaId: _empresaContratadaId,
        );
        await ref.read(desvioRepositoryProvider).atualizar(widget.id, req);
        ref.invalidate(desvioDetailProvider(widget.id));
      }
      if (mounted) context.pop();
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
      appBar: AppBar(
        backgroundColor: _EColors.bg,
        foregroundColor: _EColors.text,
        title: Text(isNc ? 'Editar NC' : 'Editar Desvio'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
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
              child: _EInput(controller: _tituloCtrl),
            ),
            const SizedBox(height: 16),
            _EField(
              label: isNc ? 'Descrição Detalhada' : 'Descrição Curta',
              child: _EInput(controller: _descCtrl, maxLines: isNc ? 5 : 3),
            ),
            const SizedBox(height: 16),
            _EField(
              label: 'Localização',
              child: _LocalizacaoField(
                estabelecimentoId: _estabelecimentoId,
                selected: _localizacaoId,
                onChanged: (v) => setState(() => _localizacaoId = v),
              ),
            ),
            const SizedBox(height: 16),
            _EField(
              label: 'Regra de Ouro',
              child: Row(
                children: [
                  Switch(
                    value: _regraDeOuro,
                    activeThumbColor: _EColors.red,
                    onChanged: (v) => setState(() => _regraDeOuro = v),
                  ),
                  const SizedBox(width: 8),
                  const Text('Viola uma regra crítica', style: TextStyle(color: _EColors.muted, fontSize: 13)),
                ],
              ),
            ),
            if (isNc) ...[
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
                    } else {
                      _normaIds.add(normaId);
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
            const SizedBox(height: 28),
            SizedBox(
              height: 50,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _EColors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _saving ? null : _salvar,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Salvar', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EField extends StatelessWidget {
  final String label;
  final Widget child;
  const _EField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: _EColors.muted, fontSize: 11, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        child,
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

const _sevOpts = [1, 2, 3, 4, 5];
const _probOpts = [1, 2, 3, 4];

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
          const Text('Severidade', style: TextStyle(color: _EColors.muted, fontSize: 11, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          _RampRow(value: severidade, options: _sevOpts, onPick: onSeveridade),
          const SizedBox(height: 16),
          const Text('Probabilidade', style: TextStyle(color: _EColors.muted, fontSize: 11, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          _RampRow(value: probabilidade, options: _probOpts, onPick: onProbabilidade),
        ],
      ),
    );
  }
}

class _RampRow extends StatelessWidget {
  final int value;
  final List<int> options;
  final ValueChanged<int> onPick;
  const _RampRow({required this.value, required this.options, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.map((o) {
        final active = value == o;
        return Expanded(
          child: GestureDetector(
            onTap: () => onPick(active ? 0 : o),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? _EColors.blue.withValues(alpha: .18) : _EColors.surface2,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: active ? _EColors.blue : _EColors.border),
              ),
              child: Text(
                '$o',
                style: TextStyle(
                  color: active ? _EColors.blue : _EColors.muted,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
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
  const _NormasChecklist({required this.selectedIds, required this.onToggle});

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
        return Container(
          decoration: BoxDecoration(
            color: _EColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _EColors.border),
          ),
          child: Column(
            children: items.map((n) {
              final checked = selectedIds.contains(n.id);
              return CheckboxListTile(
                value: checked,
                onChanged: (_) => onToggle(n.id),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: _EColors.blue,
                checkColor: Colors.white,
                title: Text(n.nome, style: const TextStyle(color: _EColors.text, fontSize: 13, fontWeight: FontWeight.w700)),
                dense: true,
              );
            }).toList(),
          ),
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
