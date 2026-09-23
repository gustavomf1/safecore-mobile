import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/connectivity_provider.dart';
import '../../shared/providers/capture_provider.dart';
import '../../shared/theme/tokens.dart';
import '../../shared/widgets/prototype_ui.dart';
import '../auth/provider/auth_provider.dart';
import '../ocorrencias/model/criar_desvio_request.dart';
import '../ocorrencias/model/criar_nc_request.dart';
import '../ocorrencias/model/email_padrao.dart';
import '../ocorrencias/model/evidencia_metadata.dart';
import '../ocorrencias/model/localizacao.dart';
import '../ocorrencias/model/nc_summary.dart';
import '../ocorrencias/model/norma.dart';
import '../ocorrencias/model/usuario_summary.dart';
import '../ocorrencias/nc_reincidencia.dart';
import '../ocorrencias/repository/desvio_repository_impl.dart';
import '../ocorrencias/repository/email_padrao_repository.dart';
import '../ocorrencias/repository/evidencia_repository_impl.dart';
import '../ocorrencias/repository/nc_repository_impl.dart';
import '../ocorrencias/repository/nc_trecho_norma_repository_impl.dart';
import '../ocorrencias/repository/support_repository_impl.dart';
import '../ocorrencias/widgets/trecho_manual_sheet.dart';
import 'rascunho_offline.dart';

class WizardPage extends ConsumerStatefulWidget {
  final String tipo;
  final Map<String, dynamic>? extra; // fotoPath, latitude, longitude, capturedAt, cidade

  const WizardPage({super.key, required this.tipo, this.extra});

  @override
  ConsumerState<WizardPage> createState() => _WizardPageState();
}

class _WizardPageState extends ConsumerState<WizardPage> {
  late final bool isNc = widget.tipo.toLowerCase() == 'nc';
  late int step = 0;

  // Risk step state
  int severity = 0;
  int probability = 0;

  // Description step state (lifted from _DescriptionStep)
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _orientacaoCtrl = TextEditingController();
  bool _reincidencia = false;
  bool _regraDeOuro = false;

  // Normas selection (IDs) e trechos manuais staged por normaId (persistidos
  // de verdade só depois que a NC existe, em _publicar).
  final Set<String> _selectedNormaIds = {};
  final Map<String, TrechoManualResult> _normaTrechos = {};

  // Localização
  String? _localizacaoId;

  // Responsável pickers
  UsuarioSummary? _responsavel;
  UsuarioSummary? _responsavelTratativa;

  // NC anterior (reincidência)
  NcSummary? _ncAnterior;

  int get stepCount => isNc ? 4 : 2;

  String get stepTitle {
    if (!isNc) {
      return switch (step) {
        0 => 'Descrição',
        _ => 'Revisão',
      };
    }
    return switch (step) {
      0 => 'Descrição',
      1 => 'Matriz de Risco',
      2 => 'Normas',
      _ => 'Revisão',
    };
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    _orientacaoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.c.bgBase,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _WizardHeader(
              title: isNc ? 'Nova Nao Conformidade' : 'Novo Desvio',
              subtitle: 'Passo ${step + 1} de $stepCount · $stepTitle',
              step: step,
              total: stepCount,
              onBack: () => context.go('/feed'),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                children: [
                  if (step == 0)
                    _DescriptionStep(
                      isNc: isNc,
                      tituloCtrl: _tituloCtrl,
                      descCtrl: _descCtrl,
                      orientacaoCtrl: _orientacaoCtrl,
                      reincidencia: _reincidencia,
                      regraDeOuro: _regraDeOuro,
                      onReincidencia: (v) => setState(() => _reincidencia = v),
                      onRegraDeOuro: (v) => setState(() => _regraDeOuro = v),
                      responsavel: _responsavel,
                      responsavelTratativa: _responsavelTratativa,
                      onResponsavel: (u) => setState(() => _responsavel = u),
                      onResponsavelTratativa: (u) =>
                          setState(() => _responsavelTratativa = u),
                      ncAnterior: _ncAnterior,
                      onNcAnterior: (nc) => setState(() => _ncAnterior = nc),
                      localizacaoId: _localizacaoId,
                      onLocalizacao: (id) => setState(() => _localizacaoId = id),
                    ),
                  if (isNc && step == 1)
                    _RiskStep(
                      severity: severity,
                      probability: probability,
                      onSeverity: (s) => setState(() => severity = s),
                      onProbability: (p) => setState(() => probability = p),
                    ),
                  if (isNc && step == 2)
                    _NormsStep(
                      selectedIds: _selectedNormaIds,
                      onToggle: (id, selected) => setState(() {
                        if (selected) {
                          _selectedNormaIds.add(id);
                        } else {
                          _selectedNormaIds.remove(id);
                          _normaTrechos.remove(id);
                        }
                      }),
                      trechos: _normaTrechos,
                      onTrechoChanged: (normaId, trecho) => setState(() {
                        if (trecho == null) {
                          _normaTrechos.remove(normaId);
                        } else {
                          _normaTrechos[normaId] = trecho;
                        }
                      }),
                    ),
                  if ((isNc && step == 3) || (!isNc && step == 1))
                    _ReviewStep(
                      isNc: isNc,
                      titulo: _tituloCtrl.text.trim(),
                      severity: severity,
                      probability: probability,
                      responsavelNome: _responsavel?.nome,
                      responsavelTrativaNome: _responsavelTratativa?.nome,
                      reincidencia: _reincidencia,
                      regraDeOuro: _regraDeOuro,
                      normaCount: _selectedNormaIds.length,
                      photosCount: ref.watch(captureProvider).length,
                    ),
                ],
              ),
            ),
            _Footer(
              backLabel: step == 0 ? 'Cancelar' : 'Voltar',
              nextLabel: step == stepCount - 1
                  ? (isNc ? 'Publicar como ABERTA' : 'Publicar')
                  : 'Continuar',
              nextIcon: step == stepCount - 1
                  ? Icons.send_outlined
                  : Icons.arrow_forward_rounded,
              onBack: step == 0
                  ? () => context.go('/feed')
                  : () => setState(() => step--),
              onNext: step == stepCount - 1
                  ? _openConfirm
                  : () {
                      if (step == 0) {
                        if (_tituloCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Título é obrigatório.')),
                          );
                          return;
                        }
                        if (_localizacaoId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Localização é obrigatória.')),
                          );
                          return;
                        }
                      }
                      setState(() => step = (step + 1).clamp(0, stepCount - 1));
                    },
            ),
          ],
        ),
      ),
    );
  }

  void _openConfirm() {
    final photos = ref.read(captureProvider);
    final workspace = ref.read(workspaceProvider);
    final titulo = _tituloCtrl.text.trim();

    final rows = <_ConfirmRow>[
      _ConfirmRow('Tipo', isNc ? 'Nao Conformidade' : 'Desvio'),
      _ConfirmRow('Titulo', titulo.isEmpty ? '(sem titulo)' : titulo),
      _ConfirmRow('Estabelecimento', workspace?.estabelecimento.nome ?? '—'),
      if (isNc) ...[
        if (severity > 0 && probability > 0)
          _ConfirmRow('Risco', '$severity × $probability = ${severity * probability}',
              red: severity * probability >= 15)
        else
          const _ConfirmRow('Risco', 'Não definido'),
        _ConfirmRow('Regra de Ouro', _regraDeOuro ? 'Sim' : 'Nao', red: _regraDeOuro),
        _ConfirmRow('Reincidencia', _reincidencia ? 'Sim' : 'Nao'),
        const _ConfirmRow('Prazo tratativa', '30 dias (a partir do envio para tratativa)'),
        _ConfirmRow('Normas', '${_selectedNormaIds.length} selecionada(s)'),
        _ConfirmRow('Resp. NC', _responsavel?.nome ?? '—'),
        _ConfirmRow('Resp. Tratativa', _responsavelTratativa?.nome ?? '—'),
      ] else ...[
        _ConfirmRow('Resp. Desvio', _responsavel?.nome ?? '—'),
        _ConfirmRow('Resp. Tratativa', _responsavelTratativa?.nome ?? '—'),
      ],
      _ConfirmRow('Fotos', photos.isEmpty ? 'Sem foto' : '${photos.length} foto(s)'),
    ];

    // Destinatários dinâmicos (automáticos): você + responsáveis selecionados.
    final user = ref.read(authProvider).valueOrNull;
    final recipients = <_Recipient>[];
    if (user != null && user.email.isNotEmpty) {
      recipients.add(_Recipient(name: user.nome, email: user.email, tag: 'você'));
    }
    if (isNc) {
      final rt = _responsavelTratativa;
      if (rt != null && rt.email.isNotEmpty) {
        recipients.add(_Recipient(name: rt.nome, email: rt.email, tag: 'Resp. Tratativa'));
      }
      final rv = _responsavel;
      if (rv != null && rv.email.isNotEmpty) {
        recipients.add(_Recipient(name: rv.nome, email: rv.email, tag: 'Resp. NC'));
      }
    } else {
      final rd = _responsavel;
      if (rd != null && rd.email.isNotEmpty) {
        recipients.add(_Recipient(name: rd.nome, email: rd.email, tag: 'Resp. Desvio'));
      }
      final rt = _responsavelTratativa;
      if (rt != null && rt.email.isNotEmpty) {
        recipients.add(_Recipient(name: rt.nome, email: rt.email, tag: 'Resp. Tratativa'));
      }
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => _ConfirmPublishModal(
        isNc: isNc,
        rows: rows,
        dynamicRecipients: recipients,
        estabelecimentoId: workspace?.estabelecimento.id,
        empresaId: workspace?.empresaFilha.id,
        onPublish: _publicar,
      ),
    );
  }

  Future<void> _publicar({
    List<String> emailsManuais = const [],
    List<String> emailsPadraoExcluidos = const [],
  }) async {
    final workspace = ref.read(workspaceProvider);
    final workspaceId = workspace?.estabelecimento.id;
    if (workspaceId == null) {
      throw Exception('Nenhum estabelecimento selecionado');
    }
    final empresaFilhaId = workspace?.empresaFilha.id;

    final titulo = _tituloCtrl.text.trim();
    if (titulo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Título é obrigatório.')),
      );
      return;
    }
    if (_localizacaoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Localização é obrigatória.')),
      );
      return;
    }
    final descricao =
        _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim();

    final online = ref.read(connectivityProvider).valueOrNull ?? true;
    if (!online) {
      final usuarioId = ref.read(authProvider).valueOrNull?.id ?? '';
      final Map<String, dynamic> dadosJson = isNc
          ? CriarNcRequest(
              estabelecimentoId: workspaceId,
              titulo: titulo,
              descricao: descricao,
              severidade: severity > 0 ? severity : null,
              probabilidade: probability > 0 ? probability : null,
              regraDeOuro: _regraDeOuro,
              reincidencia: _reincidencia,
              normaIds: _selectedNormaIds.toList(),
              localizacaoId: _localizacaoId,
              responsavelNcId: _responsavel?.id,
              responsavelTrativaId: _responsavelTratativa?.id,
              ncAnteriorId: _ncAnterior?.id,
              empresaContratadaId: empresaFilhaId,
              emailsManuais: emailsManuais,
              emailsPadraoExcluidos: emailsPadraoExcluidos,
            ).toJson()
          : CriarDesvioRequest(
              estabelecimentoId: workspaceId,
              titulo: titulo,
              descricao: descricao,
              localizacaoId: _localizacaoId,
              orientacaoRealizada: descricao,
              regraDeOuro: _regraDeOuro,
              responsavelDesvioId: _responsavel?.id,
              responsavelTratativaId: _responsavelTratativa?.id,
              empresaContratadaId: empresaFilhaId,
              emailsManuais: emailsManuais,
              emailsPadraoExcluidos: emailsPadraoExcluidos,
            ).toJson();

      await salvarRascunhoOffline(
        container: ProviderScope.containerOf(context, listen: false),
        usuarioId: usuarioId,
        tipo: isNc ? 'NC' : 'DESVIO',
        dadosJson: dadosJson,
        fotos: ref.read(captureProvider).map((x) => File(x.path)).toList(),
        normaTrechos: _normaTrechos.map(
          (normaId, t) => MapEntry(normaId, (clausulaReferencia: t.clausulaReferencia, textoEditado: t.textoEditado)),
        ),
        latitude: (widget.extra?['latitude'] as num?)?.toDouble(),
        longitude: (widget.extra?['longitude'] as num?)?.toDouble(),
        capturedAt: widget.extra?['capturedAt'] as int?,
      );
      ref.read(captureProvider.notifier).clear();
      if (mounted) context.go('/sincronizacao');
      return;
    }

    // --- tudo abaixo é o código que já existe hoje, sem alteração ---
    if (isNc) {
      final request = CriarNcRequest(
        estabelecimentoId: workspaceId,
        titulo: titulo,
        descricao: descricao,
        severidade: severity > 0 ? severity : null,
        probabilidade: probability > 0 ? probability : null,
        regraDeOuro: _regraDeOuro,
        reincidencia: _reincidencia,
        normaIds: _selectedNormaIds.toList(),
        localizacaoId: _localizacaoId,
        responsavelNcId: _responsavel?.id,
        responsavelTrativaId: _responsavelTratativa?.id,
        ncAnteriorId: _ncAnterior?.id,
        empresaContratadaId: empresaFilhaId,
        emailsManuais: emailsManuais,
        emailsPadraoExcluidos: emailsPadraoExcluidos,
      );
      final nc = await ref.read(ncRepositoryProvider).criar(request);
      final trechoRepo = ref.read(ncTrechoNormaRepositoryProvider);
      for (final entry in _normaTrechos.entries) {
        await trechoRepo.vincular(
          nc.id,
          normaId: entry.key,
          clausulaReferencia: entry.value.clausulaReferencia,
          textoEditado: entry.value.textoEditado,
        );
      }
      await _uploadPhotos(nc.id, isNc: true);
      if (mounted) {
        ref.invalidate(ncListProvider(workspaceId));
        context.go('/oc/${nc.id}');
      }
    } else {
      final orientacao = _descCtrl.text.trim().isEmpty
          ? null
          : _descCtrl.text.trim();
      final request = CriarDesvioRequest(
        estabelecimentoId: workspaceId,
        titulo: titulo,
        descricao: descricao,
        localizacaoId: _localizacaoId,
        orientacaoRealizada: orientacao,
        regraDeOuro: _regraDeOuro,
        responsavelDesvioId: _responsavel?.id,
        responsavelTratativaId: _responsavelTratativa?.id,
        empresaContratadaId: empresaFilhaId,
        emailsManuais: emailsManuais,
        emailsPadraoExcluidos: emailsPadraoExcluidos,
      );
      final desvio = await ref.read(desvioRepositoryProvider).criar(request);
      final desvioId = desvio['id'] as String;
      await _uploadPhotos(desvioId, isNc: false);
      if (mounted) {
        ref.invalidate(desvioListProvider(workspaceId));
        context.go('/desvios');
      }
    }
  }

  Future<void> _uploadPhotos(String id, {required bool isNc}) async {
    final photos = ref.read(captureProvider).map((x) => File(x.path)).toList();
    if (photos.isEmpty) return;
    final extra = widget.extra ?? {};
    final meta = EvidenciaMetadata(
      latitude: (extra['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (extra['longitude'] as num?)?.toDouble() ?? 0,
      capturedAt: (extra['capturedAt'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
      cidade: extra['cidade'] as String?,
    );
    final repo = ref.read(evidenciaRepositoryProvider);
    for (final f in photos) {
      if (isNc) {
        await repo.uploadParaNc(id, f, meta);
      } else {
        await repo.uploadParaDesvio(id, f, meta);
      }
    }
    ref.read(captureProvider.notifier).clear();
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _WizardHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final int step;
  final int total;
  final VoidCallback onBack;

  const _WizardHeader({
    required this.title,
    required this.subtitle,
    required this.step,
    required this.total,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      decoration: BoxDecoration(
          color: context.c.bgSurface,
          border: Border(bottom: BorderSide(color: context.c.borderSoft))),
      child: Column(
        children: [
          Row(
            children: [
              ProtoIconButton(icon: Icons.chevron_left_rounded, onTap: onBack),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: context.c.fg0,
                            fontSize: 14,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: TextStyle(
                            color: context.c.fg2,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              ProtoIconButton(icon: Icons.save_outlined, onTap: () {}),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(total, (i) {
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                      color: i <= step
                          ? context.c.accent
                          : context.c.bgElevated,
                      borderRadius: BorderRadius.circular(99)),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 0: Description — now receives state from parent
// ---------------------------------------------------------------------------

class _DescriptionStep extends ConsumerWidget {
  final bool isNc;
  final TextEditingController tituloCtrl;
  final TextEditingController descCtrl;
  final TextEditingController orientacaoCtrl;
  final bool reincidencia;
  final bool regraDeOuro;
  final ValueChanged<bool> onReincidencia;
  final ValueChanged<bool> onRegraDeOuro;
  final UsuarioSummary? responsavel;
  final UsuarioSummary? responsavelTratativa;
  final ValueChanged<UsuarioSummary?> onResponsavel;
  final ValueChanged<UsuarioSummary?> onResponsavelTratativa;
  final NcSummary? ncAnterior;
  final ValueChanged<NcSummary?> onNcAnterior;
  final String? localizacaoId;
  final ValueChanged<String?> onLocalizacao;

  const _DescriptionStep({
    required this.isNc,
    required this.tituloCtrl,
    required this.descCtrl,
    required this.orientacaoCtrl,
    required this.reincidencia,
    required this.regraDeOuro,
    required this.onReincidencia,
    required this.onRegraDeOuro,
    required this.responsavel,
    required this.responsavelTratativa,
    required this.onResponsavel,
    required this.onResponsavelTratativa,
    required this.ncAnterior,
    required this.onNcAnterior,
    required this.localizacaoId,
    required this.onLocalizacao,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaceId = ref.watch(workspaceProvider)?.estabelecimento.id;
    final empresaFilhaId = ref.watch(workspaceProvider)?.empresaFilha.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Label('Título'),
        _TextField(
          controller: tituloCtrl,
          hint: isNc
              ? 'Ex: Trabalho em altura sem ancoragem'
              : 'Ex: EPI inadequado em soldagem MIG',
          maxLines: 1,
        ),
        const SizedBox(height: 6),
        Text('Resumo curto que aparecerá nas listagens',
            style: TextStyle(color: context.c.fg3, fontSize: 11)),
        const SizedBox(height: 22),
        _Label(isNc ? 'Descrição Detalhada' : 'Descrição Curta'),
        _TextField(
          controller: descCtrl,
          hint: isNc
              ? 'Descreva fato, local e impacto — mínimo 20 caracteres.'
              : 'Descreva brevemente o desvio identificado',
          maxLines: isNc ? 5 : 3,
          height: isNc ? 110 : 88,
        ),
        if (isNc) ...[
          const SizedBox(height: 6),
          Text('Descreva fato, local e impacto — mínimo 20 caracteres.',
              style: TextStyle(color: context.c.fg3, fontSize: 11)),
        ],
        if (workspaceId != null) ...[
          const SizedBox(height: 18),
          const _Label('Localização'),
          const SizedBox(height: 6),
          ref.watch(localizacoesProvider(workspaceId)).when(
                loading: () => const SizedBox.shrink(),
                error: (e, st) {
                  debugPrint('localizacoesProvider($workspaceId) error: $e\n$st');
                  return const SizedBox.shrink();
                },
                data: (locs) {
                  if (locs.isEmpty) {
                    debugPrint('localizacoesProvider($workspaceId): lista vazia');
                    return const SizedBox.shrink();
                  }
                  return _LocationDropdown(
                    items: locs,
                    selected: localizacaoId,
                    onChanged: onLocalizacao,
                  );
                },
              ),
        ],
        if (isNc) ...[
          const SizedBox(height: 22),
          const _Label('Responsáveis'),
          Text('Eng. Responsável pela Tratativa',
              style: TextStyle(
                  color: context.c.fg2,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(
              'Quem irá enviar o plano de ação (geralmente EXTERNO)',
              style: TextStyle(color: context.c.fg3, fontSize: 10)),
          const SizedBox(height: 7),
          if (workspaceId != null)
            _UserPickerRow(
              workspaceId: workspaceId,
              empresaId: empresaFilhaId,
              filterPerfis: const ['EXTERNO', 'ENGENHEIRO'],
              selected: responsavelTratativa,
              icon: Icons.manage_accounts_outlined,
              hint: 'Selecionar responsável',
              onSelected: onResponsavelTratativa,
            )
          else
            const _SelectRow(
                icon: Icons.manage_accounts_outlined,
                text: 'Selecionar responsável'),
          const SizedBox(height: 14),
          Text('Eng. Responsável pela NC',
              style: TextStyle(
                  color: context.c.fg2,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text('Quem irá validar (aprovar/reprovar) a tratativa',
              style: TextStyle(color: context.c.fg3, fontSize: 10)),
          const SizedBox(height: 7),
          if (workspaceId != null)
            _UserPickerRow(
              workspaceId: workspaceId,
              filterPerfis: const ['ENGENHEIRO', 'TECNICO'],
              selected: responsavel,
              icon: Icons.engineering_outlined,
              hint: 'Selecionar engenheiro',
              onSelected: onResponsavel,
            )
          else
            const _SelectRow(
                icon: Icons.engineering_outlined,
                text: 'Selecionar engenheiro'),
          const SizedBox(height: 22),
          const _Label('Sinalizações'),
          _SignalRow(
            checked: reincidencia,
            title: 'Reincidência',
            subtitle:
                'Marque se esta NC é recorrência de uma ocorrência anterior',
            color: context.c.statusOrangeFg,
            onTap: () => onReincidencia(!reincidencia),
          ),
          if (reincidencia) ...[
            const SizedBox(height: 10),
            Text('NC Anterior',
                style: TextStyle(
                    color: context.c.fg2,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            if (workspaceId != null)
              ref.watch(ncListProvider(workspaceId)).when(
                    loading: () => SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: context.c.statusOrangeFg)),
                    error: (_, __) => Text('Erro ao carregar NCs',
                        style: TextStyle(
                            color: context.c.statusRedFg, fontSize: 12)),
                    data: (ncs) {
                      final selecionada = ncAnterior;
                      final warning = selecionada == null
                          ? null
                          : reincidenciaChainEnd(ncs, selecionada.id);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                                color: context.c.bgElevated,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: warning != null
                                        ? context.c.statusOrangeFg
                                        : context.c.statusOrangeFg.withValues(alpha: .5))),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<NcSummary?>(
                                isExpanded: true,
                                dropdownColor: context.c.bgSurface,
                                value: ncAnterior,
                                hint: Text('Selecionar NC anterior',
                                    style: TextStyle(
                                        color: context.c.fg2, fontSize: 13)),
                                style: TextStyle(
                                    color: context.c.fg0, fontSize: 13),
                                items: [
                                  DropdownMenuItem(
                                      value: null,
                                      child: Text('— Nenhuma',
                                          style: TextStyle(
                                              color: context.c.fg2,
                                              fontSize: 13))),
                                  ...ncs.map((nc) => DropdownMenuItem(
                                        value: nc,
                                        child: Text(
                                          '${nc.titulo} · ${nc.status}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )),
                                ],
                                onChanged: onNcAnterior,
                              ),
                            ),
                          ),
                          if (warning != null) ...[
                            const SizedBox(height: 8),
                            _ReincidenciaWarning(
                              ultimaNc: warning,
                              onUsarEsta: () => onNcAnterior(warning),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
            if (ncAnterior != null) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                    color: context.c.statusOrangeFg.withValues(alpha: .07),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: context.c.statusOrangeFg.withValues(alpha: .3))),
                child: Row(children: [
                  Icon(Icons.link_rounded,
                      color: context.c.statusOrangeFg, size: 13),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(ncAnterior!.titulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: context.c.statusOrangeFg,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 6),
                  Text(ncAnterior!.status,
                      style: TextStyle(
                          color: context.c.fg2,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ]),
              ),
            ],
          ],
          const SizedBox(height: 10),
          _SignalRow(
            checked: regraDeOuro,
            title: 'Regra de Ouro',
            subtitle:
                'Marque se a ocorrência viola uma regra crítica de segurança',
            color: context.c.statusRedFg,
            onTap: () => onRegraDeOuro(!regraDeOuro),
          ),
        ] else ...[
          const SizedBox(height: 22),
          const _Label('Responsáveis'),
          Text('Responsável pelo Desvio',
              style: TextStyle(
                  color: context.c.fg2,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text('Quem irá validar a tratativa',
              style: TextStyle(color: context.c.fg3, fontSize: 10)),
          const SizedBox(height: 7),
          if (workspaceId != null)
            _UserPickerRow(
              workspaceId: workspaceId,
              filterPerfis: const ['ENGENHEIRO', 'TECNICO'],
              selected: responsavel,
              icon: Icons.person_outline_rounded,
              hint: 'Selecionar responsável',
              onSelected: onResponsavel,
            )
          else
            const _SelectRow(
                icon: Icons.person_outline_rounded,
                text: 'Selecionar responsável'),
          const SizedBox(height: 14),
          Text('Responsável pela Tratativa',
              style: TextStyle(
                  color: context.c.fg2,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text('Quem irá executar a tratativa',
              style: TextStyle(color: context.c.fg3, fontSize: 10)),
          const SizedBox(height: 7),
          if (workspaceId != null)
            _UserPickerRow(
              workspaceId: workspaceId,
              filterPerfis: const ['ENGENHEIRO', 'TECNICO'],
              combinedEmpresaId: empresaFilhaId,
              combinedFilterPerfis: const ['EXTERNO', 'ENGENHEIRO'],
              selected: responsavelTratativa,
              icon: Icons.person_add_alt_outlined,
              hint: 'Selecionar responsável',
              onSelected: onResponsavelTratativa,
            )
          else
            const _SelectRow(
                icon: Icons.person_add_alt_outlined,
                text: 'Selecionar responsável'),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// User picker row — Consumer reads usuariosProvider
// ---------------------------------------------------------------------------

class _UserPickerRow extends ConsumerWidget {
  final String workspaceId;
  final UsuarioSummary? selected;
  final IconData icon;
  final String hint;
  final ValueChanged<UsuarioSummary?> onSelected;
  // Se fornecido, busca por empresaId em vez de workspaceId
  final String? empresaId;
  // Se fornecido, filtra por perfil na lista principal
  final List<String>? filterPerfis;
  // Se fornecido, combina com lista de empresa filha filtrada por estes perfis
  final String? combinedEmpresaId;
  final List<String>? combinedFilterPerfis;

  const _UserPickerRow({
    required this.workspaceId,
    required this.selected,
    required this.icon,
    required this.hint,
    required this.onSelected,
    this.empresaId,
    this.filterPerfis,
    this.combinedEmpresaId,
    this.combinedFilterPerfis,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mainAsync = empresaId != null
        ? ref.watch(usuariosPorEmpresaProvider(empresaId!))
        : ref.watch(usuariosProvider(workspaceId));
    final extraAsync = combinedEmpresaId != null
        ? ref.watch(usuariosPorEmpresaProvider(combinedEmpresaId!))
        : const AsyncData<List<UsuarioSummary>>([]);

    // Combina quando os dois providers estão prontos
    final combined = mainAsync.whenData((main) {
      final extra = extraAsync.valueOrNull ?? [];
      final mainFiltered = filterPerfis != null
          ? main.where((u) => filterPerfis!.contains(u.perfil)).toList()
          : main;
      final extraFiltered = combinedFilterPerfis != null
          ? extra.where((u) => combinedFilterPerfis!.contains(u.perfil)).toList()
          : extra;
      final ids = <String>{};
      return [...mainFiltered, ...extraFiltered]
          .where((u) => ids.add(u.id))
          .toList();
    });

    return combined.when(
      loading: () => const SizedBox(
          height: 46,
          child: Center(
              child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2)))),
      error: (_, __) => const _SelectRow(
          icon: Icons.error_outline, text: 'Erro ao carregar usuários'),
      data: (todos) {
        final usuarios = todos;
        return GestureDetector(
        onTap: () => _showPicker(context, usuarios),
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
              color: context.c.bgElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.c.borderSoft)),
          child: Row(children: [
            Icon(icon, color: context.c.fg2, size: 16),
            const SizedBox(width: 10),
            Expanded(
                child: Text(
              selected?.nome ?? hint,
              style: TextStyle(
                  color: selected != null
                      ? context.c.fg0
                      : context.c.fg2,
                  fontSize: 14,
                  fontWeight: FontWeight.w800),
            )),
            Icon(Icons.keyboard_arrow_down_rounded,
                color: context.c.fg2, size: 18),
          ]),
        ),
        );
      },
    );
  }

  void _showPicker(BuildContext context, List<UsuarioSummary> usuarios) {
    showModalBottomSheet<UsuarioSummary>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _UserPickerSheet(usuarios: usuarios, selected: selected),
    ).then((u) {
      if (u != null) onSelected(u);
    });
  }
}

class _UserPickerSheet extends StatefulWidget {
  final List<UsuarioSummary> usuarios;
  final UsuarioSummary? selected;
  const _UserPickerSheet({required this.usuarios, required this.selected});

  @override
  State<_UserPickerSheet> createState() => _UserPickerSheetState();
}

class _UserPickerSheetState extends State<_UserPickerSheet> {
  String _search = '';
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _search.isEmpty
        ? widget.usuarios
        : widget.usuarios
            .where((u) =>
                u.nome.toLowerCase().contains(_search.toLowerCase()) ||
                u.email.toLowerCase().contains(_search.toLowerCase()))
            .toList();
    return Container(
      padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: BoxDecoration(
          color: context.c.bgSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(
            child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                    color: context.c.fg2,
                    borderRadius: BorderRadius.circular(99)))),
        const SizedBox(height: 16),
        Align(
            alignment: Alignment.centerLeft,
            child: Text('Selecionar usuário',
                style: TextStyle(
                    color: context.c.fg0,
                    fontSize: 16,
                    fontWeight: FontWeight.w900))),
        const SizedBox(height: 12),
        Container(
          height: 40,
          decoration: BoxDecoration(
              color: context.c.bgElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.c.borderSoft)),
          child: Row(children: [
            const SizedBox(width: 12),
            Icon(Icons.search, color: context.c.fg2, size: 15),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _ctrl,
                onChanged: (v) => setState(() => _search = v),
                style:
                    TextStyle(color: context.c.fg0, fontSize: 13),
                decoration: InputDecoration(
                    hintText: 'Buscar usuário…',
                    hintStyle:
                        TextStyle(color: context.c.fg2, fontSize: 13),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * .4),
          child: ListView(
            shrinkWrap: true,
            children: filtered.map((u) {
              final sel = widget.selected?.id == u.id;
              return GestureDetector(
                onTap: () => Navigator.pop(context, u),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                      color: sel
                          ? context.c.accent.withValues(alpha: .10)
                          : context.c.bgElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: sel
                              ? context.c.accent
                              : context.c.borderSoft)),
                  child: Row(children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(u.nome,
                              style: TextStyle(
                                  color: sel
                                      ? context.c.accent
                                      : context.c.fg0,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800)),
                          Text(u.perfil,
                              style: TextStyle(
                                  color: context.c.fg2, fontSize: 11)),
                        ])),
                    if (sel)
                      Icon(Icons.check_circle,
                          color: context.c.accent, size: 18),
                  ]),
                ),
              );
            }).toList(),
          ),
        ),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 2: Risk
// ---------------------------------------------------------------------------

class _SignalRow extends StatelessWidget {
  final bool checked;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _SignalRow(
      {required this.checked,
      required this.title,
      required this.subtitle,
      required this.color,
      required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: checked
                ? color.withValues(alpha: .07)
                : context.c.bgSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: checked ? color : context.c.borderSoft),
          ),
          child: Row(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: checked ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                    color:
                        checked ? color : context.c.borderMain,
                    width: 1.5),
              ),
              child: checked
                  ? const Icon(Icons.check,
                      color: Colors.white, size: 13)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: TextStyle(
                          color: checked ? color : context.c.fg0,
                          fontSize: 13,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          color: context.c.fg2,
                          fontSize: 11,
                          height: 1.3)),
                ])),
          ]),
        ),
      );
}

/// Espelha o aviso do web (RegistroOcorrenciaPage) quando a NC escolhida como
/// "anterior" já tem uma sucessora: o backend rejeita a gravação nesse caso
/// (NaoConformidadeService.validarFimDaCadeia), então avisamos antes de tentar.
class _ReincidenciaWarning extends StatelessWidget {
  final NcSummary ultimaNc;
  final VoidCallback onUsarEsta;
  const _ReincidenciaWarning({required this.ultimaNc, required this.onUsarEsta});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.c.statusOrangeFg.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.c.statusOrangeFg.withValues(alpha: .4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('⚠ Esta NC já possui uma reincidência registrada',
              style: TextStyle(color: context.c.statusOrangeFg, fontSize: 12, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Para manter o rastro linear, selecione a última NC da cadeia:',
              style: TextStyle(color: context.c.fg2, fontSize: 11)),
          const SizedBox(height: 8),
          Text(ultimaNc.titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: context.c.fg0, fontSize: 12, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onUsarEsta,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.c.statusOrangeFg.withValues(alpha: .18),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: context.c.statusOrangeFg),
              ),
              child: Text('Usar esta NC',
                  style: TextStyle(color: context.c.statusOrangeFg, fontSize: 12, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
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

// Usa os tokens de severidade do design system (sevBaixo..sevCritico),
// deliberadamente quase invariantes entre temas.
Color _riskColor(int score, SafeCoreColors c) {
  if (score <= 4) return c.sevBaixo;
  if (score <= 9) return c.sevMedio;
  if (score <= 15) return c.sevAlto;
  return c.sevCritico;
}

String _riskLabel(int score) {
  if (score <= 4) return 'Risco Baixo';
  if (score <= 9) return 'Risco Moderado';
  if (score <= 15) return 'Risco Alto';
  return 'Risco Crítico';
}

class _RiskStep extends StatelessWidget {
  final int severity;
  final int probability;
  final ValueChanged<int> onSeverity;
  final ValueChanged<int> onProbability;

  const _RiskStep({
    required this.severity,
    required this.probability,
    required this.onSeverity,
    required this.onProbability,
  });

  @override
  Widget build(BuildContext context) {
    final score = severity * probability;
    final hasScore = severity > 0 && probability > 0;

    return Column(
      children: [
        ProtoCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Label('Severidade'),
              _RampPicker(
                  value: severity,
                  options: _sevOpts,
                  onPick: onSeverity),
              const SizedBox(height: 18),
              const _Label('Probabilidade'),
              _RampPicker(
                  value: probability,
                  options: _probOpts,
                  onPick: onProbability),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                      child: Text('Matriz de Risco 5×4',
                          style: TextStyle(
                              color: context.c.fg2,
                              fontSize: 13,
                              fontWeight: FontWeight.w900))),
                  Text('SEV × PROB',
                      style: TextStyle(
                          color: context.c.fg2,
                          fontSize: 10,
                          fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 12),
              const Row(children: [
                SizedBox(width: 28),
                _Axis('P1'),
                _Axis('P2'),
                _Axis('P3'),
                _Axis('P4')
              ]),
              for (int s = 5; s >= 1; s--)
                Row(
                  children: [
                    SizedBox(
                        width: 28,
                        child: Text('S$s',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: context.c.fg2,
                                fontSize: 11,
                                fontWeight: FontWeight.w800))),
                    for (int p = 1; p <= 4; p++)
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          height: 44,
                          margin: const EdgeInsets.all(2.5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _riskColor(s * p, context.c),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: severity == s && probability == p
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: severity == s && probability == p
                                ? [
                                    BoxShadow(
                                        color: Colors.white
                                            .withValues(alpha: .28),
                                        blurRadius: 0,
                                        spreadRadius: 2)
                                  ]
                                : null,
                          ),
                          child: Text('${s * p}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900)),
                        ),
                      ),
                  ],
                ),
              if (hasScore) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: context.c.bgElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: context.c.borderSoft)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('PONTUAÇÃO',
                                style: TextStyle(
                                    color: context.c.fg2,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900)),
                            const SizedBox(height: 4),
                            Text(_riskLabel(score),
                                style: TextStyle(
                                    color: _riskColor(score, context.c),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: score),
                        duration: const Duration(milliseconds: 350),
                        builder: (_, v, __) => Text('$v',
                            style: TextStyle(
                                color: _riskColor(score, context.c),
                                fontSize: 25,
                                fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        ProtoCard(
          child: Row(children: [
            Icon(Icons.calendar_month_outlined,
                color: context.c.fg2, size: 16),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Data Limite para Tratativa',
                    style: TextStyle(
                        color: context.c.fg2,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  'Definido no envio para tratativa (30 dias)',
                  style: TextStyle(
                      color: context.c.fg0.withValues(alpha: .7),
                      fontSize: 12),
                ),
              ],
            ),
          ]),
        ),
      ],
    );
  }
}

class _RampPicker extends StatelessWidget {
  final int value;
  final List<({int value, String label, Color color})> options;
  final ValueChanged<int> onPick;

  const _RampPicker(
      {required this.value, required this.options, required this.onPick});

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
                color: active
                    ? o.color.withValues(alpha: .18)
                    : context.c.bgElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: active ? o.color : context.c.borderSoft),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${o.value}',
                    style: TextStyle(
                        color: active ? o.color : context.c.fg0,
                        fontSize: 16,
                        fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    o.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: active ? o.color : context.c.fg2,
                        fontSize: 9,
                        fontWeight: FontWeight.w700),
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

// ---------------------------------------------------------------------------
// Step 3: Norms — wired to normasProvider
// ---------------------------------------------------------------------------

class _NormsStep extends ConsumerStatefulWidget {
  final Set<String> selectedIds;
  final void Function(String id, bool selected) onToggle;
  final Map<String, TrechoManualResult> trechos;
  final void Function(String normaId, TrechoManualResult? trecho) onTrechoChanged;

  const _NormsStep({
    required this.selectedIds,
    required this.onToggle,
    required this.trechos,
    required this.onTrechoChanged,
  });

  @override
  ConsumerState<_NormsStep> createState() => _NormsStepState();
}

class _NormsStepState extends ConsumerState<_NormsStep> {
  String _search = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggle(Norma norma) {
    final alreadySelected = widget.selectedIds.contains(norma.id);
    widget.onToggle(norma.id, !alreadySelected);
    if (alreadySelected) widget.onTrechoChanged(norma.id, null);
  }

  Future<void> _openManual(Norma norma) async {
    final existing = widget.trechos[norma.id];
    final result = await showTrechoManualSheet(
      context,
      code: norma.codigo,
      existingClausula: existing?.clausulaReferencia,
      existingTexto: existing?.textoEditado,
    );
    if (result != null) widget.onTrechoChanged(norma.id, result);
  }

  @override
  Widget build(BuildContext context) {
    final normasAsync = ref.watch(normasProvider);

    return normasAsync.when(
      loading: () => const Center(
          child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: CircularProgressIndicator())),
      error: (e, _) => Center(
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text('Erro ao carregar normas: $e',
                  style: TextStyle(
                      color: context.c.fg2, fontSize: 13),
                  textAlign: TextAlign.center))),
      data: (normas) {
        final q = _search.toLowerCase();
        final filtered = _search.isEmpty
            ? normas
            : normas
                .where((n) =>
                    n.codigo.toLowerCase().contains(q) ||
                    n.nome.toLowerCase().contains(q))
                .toList();

        // Codes for selected IDs (for chip display)
        final selectedNormas = normas
            .where((n) => widget.selectedIds.contains(n.id))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Label('Normas / NRs Violadas'),
            if (selectedNormas.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                decoration: BoxDecoration(
                    color: context.c.bgElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: context.c.borderSoft)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('SELECIONADAS',
                      style: TextStyle(
                          color: context.c.fg2,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .6)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: selectedNormas
                        .map((n) => _NormChip(
                            code: n.codigo,
                            onRemove: () => _toggle(n)))
                        .toList(),
                  ),
                ]),
              ),
              const SizedBox(height: 10),
            ],
            Container(
              height: 40,
              decoration: BoxDecoration(
                  color: context.c.bgElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: context.c.borderSoft)),
              child: Row(children: [
                const SizedBox(width: 12),
                Icon(Icons.search, color: context.c.fg2, size: 15),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _search = v),
                    style: TextStyle(
                        color: context.c.fg0, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Buscar entre ${normas.length} normas…',
                      hintStyle: TextStyle(
                          color: context.c.fg2, fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (_search.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchCtrl.clear();
                      setState(() => _search = '');
                    },
                    child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Icon(Icons.close,
                            color: context.c.fg2, size: 16)),
                  ),
              ]),
            ),
            const SizedBox(height: 10),
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                    child: Text(
                        'Nenhuma norma encontrada para "$_search"',
                        style: TextStyle(
                            color: context.c.fg2, fontSize: 13),
                        textAlign: TextAlign.center)),
              )
            else
              ...filtered.map((n) {
                final checked = widget.selectedIds.contains(n.id);
                final trecho = widget.trechos[n.id];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: checked
                          ? context.c.accent.withValues(alpha: .08)
                          : context.c.bgSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: checked
                              ? context.c.accent
                              : context.c.borderSoft),
                    ),
                    child: Column(children: [
                      InkWell(
                        onTap: () => _toggle(n),
                        borderRadius: checked
                            ? const BorderRadius.vertical(
                                top: Radius.circular(10))
                            : BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 13),
                          child: Row(children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: checked
                                    ? context.c.accent
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                    color: checked
                                        ? context.c.accent
                                        : context.c.borderMain,
                                    width: 1.5),
                              ),
                              child: checked
                                  ? const Icon(Icons.check,
                                      color: Colors.white, size: 13)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Text(n.codigo,
                                style: TextStyle(
                                    color: checked
                                        ? context.c.accent
                                        : context.c.fg0,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900)),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(n.nome.toUpperCase(),
                                    style: TextStyle(
                                        color: context.c.fg2,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: .3),
                                    overflow: TextOverflow.ellipsis)),
                          ]),
                        ),
                      ),
                      if (checked) ...[
                        Container(height: 1, color: context.c.borderSoft),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(12, 10, 12, 12),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            if (trecho != null) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                margin:
                                    const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                    color: context.c.bgElevated,
                                    borderRadius:
                                        BorderRadius.circular(8),
                                    border: Border.all(
                                        color: context.c.borderMain)),
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Icon(Icons.format_quote,
                                      color: context.c.accent, size: 14),
                                  const SizedBox(width: 6),
                                  Expanded(
                                      child: Text(
                                          trecho.clausulaReferencia != null
                                              ? '${trecho.clausulaReferencia} — ${trecho.textoEditado}'
                                              : trecho.textoEditado,
                                          style: TextStyle(
                                              color: context.c.fg0,
                                              fontSize: 12,
                                              height: 1.4))),
                                  GestureDetector(
                                      onTap: () =>
                                          widget.onTrechoChanged(n.id, null),
                                      child: Icon(Icons.close,
                                          color: context.c.fg2,
                                          size: 14)),
                                ]),
                              ),
                            ],
                            Row(children: [
                              _NormActionBtn(
                                  icon: Icons.edit_outlined,
                                  label: 'Escrever manual',
                                  onTap: () => _openManual(n)),
                            ]),
                          ]),
                        ),
                      ],
                    ]),
                  ),
                );
              }),
            const SizedBox(height: 4),
            Text(
              '${normas.length} normas disponíveis${selectedNormas.isNotEmpty ? ' · ${selectedNormas.length} selecionada${selectedNormas.length > 1 ? 's' : ''}' : ''}',
              style:
                  TextStyle(color: context.c.fg3, fontSize: 11),
            ),
          ],
        );
      },
    );
  }
}

class _NormChip extends StatelessWidget {
  final String code;
  final VoidCallback onRemove;
  const _NormChip({required this.code, required this.onRemove});
  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: context.c.accent.withValues(alpha: .15),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
                color: context.c.accent.withValues(alpha: .45))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(code,
              style: TextStyle(
                  color: context.c.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w900)),
          const SizedBox(width: 5),
          GestureDetector(
              onTap: onRemove,
              child: Icon(Icons.close,
                  color: context.c.accent, size: 12)),
        ]),
      );
}

class _NormActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _NormActionBtn(
      {required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
              color: context.c.bgElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.c.borderSoft)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: context.c.fg2, size: 13),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    color: context.c.fg0,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ]),
        ),
      );
}


// ---------------------------------------------------------------------------
// Step 4: Evidence
// ---------------------------------------------------------------------------
// Step 4 (NC) / Step 2 (Desvio): Review
// ---------------------------------------------------------------------------

class _ReviewStep extends ConsumerWidget {
  final bool isNc;
  final String titulo;
  final int severity;
  final int probability;
  final String? responsavelNome;
  final String? responsavelTrativaNome;
  final bool reincidencia;
  final bool regraDeOuro;
  final int normaCount;
  final int photosCount;

  const _ReviewStep({
    required this.isNc,
    required this.titulo,
    required this.severity,
    required this.probability,
    this.responsavelNome,
    this.responsavelTrativaNome,
    required this.reincidencia,
    required this.regraDeOuro,
    required this.normaCount,
    required this.photosCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(workspaceProvider);
    final hasScore = severity > 0 && probability > 0;
    final score = severity * probability;
    final nivelRisco = score >= 15 ? 'CRITICO' : score >= 9 ? 'ALTO' : score >= 4 ? 'MEDIO' : 'BAIXO';
    final nivelRed = score >= 15;

    return Column(
      children: [
        ProtoCard(
          color: context.c.bgMuted,
          border: Border.fromBorderSide(BorderSide(color: context.c.accent)),
          child: Row(children: [
            Icon(Icons.check_circle_outline_rounded,
                color: context.c.accent, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tudo pronto para publicar',
                      style: TextStyle(
                          color: context.c.fg0,
                          fontSize: 14,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text('Revise os dados abaixo antes de confirmar.',
                      style: TextStyle(
                          color: context.c.fg2.withValues(alpha: .8),
                          fontSize: 12)),
                ],
              ),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        ProtoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProtoPill(
                label: isNc ? 'Nao Conformidade' : 'Desvio',
                bg: isNc
                    ? context.c.statusRedFg.withValues(alpha: .12)
                    : context.c.statusYellowBg,
                fg: isNc ? context.c.statusRedFg : context.c.statusYellowFg,
              ),
              const SizedBox(height: 10),
              Text(
                titulo.isEmpty ? '(sem titulo)' : titulo,
                style: TextStyle(
                    color: context.c.fg0,
                    fontSize: 15,
                    height: 1.3,
                    fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              if (workspace != null)
                _ReviewLine('Estabelecimento', workspace.estabelecimento.nome),
              if (isNc) ...[
                _ReviewLine('Risco', hasScore ? '$nivelRisco · $score' : 'Não definido', red: hasScore && nivelRed),
                _ReviewLine('Resp. NC', responsavelNome ?? '—'),
                _ReviewLine('Resp. Tratativa', responsavelTrativaNome ?? '—'),
                _ReviewLine('Reincidencia', reincidencia ? 'Sim' : 'Nao'),
                _ReviewLine('Normas', '$normaCount selecionada(s)'),
                _ReviewLine('Regra de Ouro', regraDeOuro ? 'Sim' : 'Nao',
                    red: regraDeOuro),
              ] else ...[
                _ReviewLine('Resp. Desvio', responsavelNome ?? '—'),
                _ReviewLine('Resp. Tratativa', responsavelTrativaNome ?? '—'),
              ],
              _ReviewLine('Fotos', photosCount == 0 ? 'Sem foto' : '$photosCount foto(s)'),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Animated pulsing loader
// ---------------------------------------------------------------------------

class _PulsingLoader extends StatefulWidget {
  @override
  State<_PulsingLoader> createState() => _PulsingLoaderState();
}

class _PulsingLoaderState extends State<_PulsingLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _scale = Tween(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _opacity = Tween(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: _opacity.value,
        child: Transform.scale(
          scale: _scale.value,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.c.accent.withValues(alpha: .15),
              border: Border.all(
                  color: context.c.accent.withValues(alpha: .6), width: 2),
            ),
            child: Icon(Icons.send_rounded,
                color: context.c.accent, size: 28),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ConfirmPublishModal — receives onPublish callback
// ---------------------------------------------------------------------------

class _ConfirmRow {
  final String label;
  final String value;
  final bool red;
  const _ConfirmRow(this.label, this.value, {this.red = false});
}

/// Destinatário dinâmico (automático): você + responsáveis selecionados.
class _Recipient {
  final String name;
  final String email;
  final String tag;
  const _Recipient({required this.name, required this.email, required this.tag});
}

/// E-mail manual adicionado na seção Padrão (desmarcável).
class _ManualPadrao {
  final String email;
  bool checked;
  _ManualPadrao(this.email, this.checked);
}

class _ConfirmPublishModal extends ConsumerStatefulWidget {
  final bool isNc;
  final List<_ConfirmRow> rows;
  final List<_Recipient> dynamicRecipients;
  final String? estabelecimentoId;
  final String? empresaId;
  final Future<void> Function({
    required List<String> emailsManuais,
    required List<String> emailsPadraoExcluidos,
  }) onPublish;

  const _ConfirmPublishModal({
    required this.isNc,
    required this.rows,
    required this.dynamicRecipients,
    required this.estabelecimentoId,
    required this.empresaId,
    required this.onPublish,
  });

  @override
  ConsumerState<_ConfirmPublishModal> createState() =>
      _ConfirmPublishModalState();
}

class _ConfirmPublishModalState extends ConsumerState<_ConfirmPublishModal> {
  int stage = 0;
  String? errorMsg;

  // Recipients editor state
  final Set<String> _excluidos = {};
  final List<String> _manuaisDinamico = [];
  final List<_ManualPadrao> _manuaisPadrao = [];
  final List<String> _padraoPromovidos = [];
  final _manualCtrl = TextEditingController();
  String _manualTipo = 'DINAMICO'; // DINAMICO | PADRAO
  String? _manualError;

  int _lastTotalCount = 0;

  @override
  void dispose() {
    _manualCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() {
      stage = 1;
      errorMsg = null;
    });
    try {
      final emailsManuais = <String>[
        ..._manuaisDinamico,
        ..._padraoPromovidos,
        ..._manuaisPadrao.where((e) => e.checked).map((e) => e.email),
      ];
      final emailsPadraoExcluidos = <String>[..._excluidos, ..._padraoPromovidos];
      await widget.onPublish(
        emailsManuais: emailsManuais,
        emailsPadraoExcluidos: emailsPadraoExcluidos,
      );
      if (mounted) setState(() => stage = 2);
    } catch (e) {
      if (mounted) {
        setState(() {
          stage = 0;
          errorMsg = _friendlyError(e);
        });
      }
    }
  }

  String _friendlyError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        for (final k in ['message', 'error', 'mensagem', 'detail']) {
          final v = data[k];
          if (v is String && v.isNotEmpty) return v;
        }
      }
      if (e.response?.statusCode == 422) {
        return 'Dados inválidos. Verifique os campos e tente novamente.';
      }
    }
    return 'Erro ao publicar. Verifique os dados e tente novamente.';
  }

  void _addManual(List<EmailPadrao> padraoFiltrados) {
    final em = _manualCtrl.text.trim();
    if (em.isEmpty) return;
    final emDinamico = widget.dynamicRecipients.any((r) => r.email == em) ||
        _manuaisDinamico.contains(em) ||
        _padraoPromovidos.contains(em);
    final emPadrao = padraoFiltrados.any((ep) => ep.email == em) ||
        _manuaisPadrao.any((e) => e.email == em);
    if (emDinamico) {
      setState(() => _manualError = 'Este email já está vinculado nos Dinâmicos');
      return;
    }
    if (emPadrao) {
      setState(() => _manualError = 'Este email já está vinculado nos Padrão');
      return;
    }
    setState(() {
      _manualError = null;
      if (_manualTipo == 'DINAMICO') {
        _manuaisDinamico.add(em);
      } else {
        _manuaisPadrao.add(_ManualPadrao(em, true));
      }
      _manualCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final emailsPadrao =
        (widget.estabelecimentoId != null && widget.empresaId != null)
            ? (ref.watch(emailsPadraoProvider((
                  estabelecimentoId: widget.estabelecimentoId!,
                  empresaId: widget.empresaId!,
                ))).valueOrNull ??
                const <EmailPadrao>[])
            : const <EmailPadrao>[];

    final dynamicEmails = widget.dynamicRecipients.map((r) => r.email).toSet();
    final padraoFiltrados = emailsPadrao
        .where((ep) =>
            !dynamicEmails.contains(ep.email) &&
            !_padraoPromovidos.contains(ep.email))
        .toList();
    final totalCount = widget.dynamicRecipients.length +
        _manuaisDinamico.length +
        _padraoPromovidos.length +
        padraoFiltrados.where((ep) => !_excluidos.contains(ep.email)).length +
        _manuaisPadrao.where((e) => e.checked).length;
    _lastTotalCount = totalCount;

    return Stack(
      children: [
        Positioned.fill(
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                    color: context.c.bgBase.withValues(alpha: .70)))),
        Align(
          alignment: stage == 0 ? Alignment.bottomCenter : Alignment.center,
          child: Container(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.92),
            margin: stage == 0
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(horizontal: 32),
            padding: stage == 0
                ? EdgeInsets.fromLTRB(
                    20, 8, 20, 24 + MediaQuery.of(context).viewInsets.bottom)
                : const EdgeInsets.fromLTRB(24, 28, 24, 24),
            decoration: BoxDecoration(
                color: context.c.bgSurface,
                borderRadius: stage == 0
                    ? const BorderRadius.vertical(top: Radius.circular(22))
                    : BorderRadius.circular(22)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (stage == 0) ...[
                  Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                          color: context.c.fg2,
                          borderRadius: BorderRadius.circular(99))),
                  const SizedBox(height: 22),
                ],
                if (stage == 0) ...[
                  // Header com tipo
                  Row(children: [
                    ProtoPill(
                      label: widget.isNc ? 'Nao Conformidade' : 'Desvio',
                      bg: widget.isNc
                          ? context.c.statusRedFg.withValues(alpha: .15)
                          : context.c.statusYellowBg,
                      fg: widget.isNc ? context.c.statusRedFg : context.c.statusYellowFg,
                    ),
                  ]),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Confirmar publicacao?',
                        style: TextStyle(
                            color: context.c.fg0,
                            fontSize: 20,
                            fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Revise os dados antes de publicar.',
                        style: TextStyle(
                            color: context.c.fg2, fontSize: 12)),
                  ),
                  const SizedBox(height: 16),
                  // Rows + destinatários — rolável (encolhe p/ caber erro+botões)
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Resumo de dados
                          Container(
                            decoration: BoxDecoration(
                              color: context.c.bgElevated,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: context.c.borderSoft),
                            ),
                            child: Column(
                              children: [
                                for (int i = 0; i < widget.rows.length; i++) ...[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 110,
                                          child: Text(widget.rows[i].label,
                                              style: TextStyle(
                                                  color: context.c.fg2,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700)),
                                        ),
                                        Expanded(
                                          child: Text(widget.rows[i].value,
                                              style: TextStyle(
                                                  color: widget.rows[i].red
                                                      ? context.c.statusRedFg
                                                      : context.c.fg0,
                                                  fontSize: 13,
                                                  fontWeight: widget.rows[i].red
                                                      ? FontWeight.w800
                                                      : FontWeight.w600)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (i < widget.rows.length - 1)
                                    Divider(
                                        height: 1,
                                        color: context.c.borderSoft,
                                        indent: 14,
                                        endIndent: 14),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Destinatários do email de abertura
                          Row(children: [
                            Icon(Icons.mail_outline_rounded,
                                color: context.c.fg2, size: 14),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text('Destinatários do email de abertura',
                                  style: TextStyle(
                                      color: context.c.fg0,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800)),
                            ),
                            Text('$totalCount selecionados',
                                style: TextStyle(
                                    color: context.c.fg2, fontSize: 12)),
                          ]),
                          const SizedBox(height: 10),
                          // Grupo: Dinâmicos
                          _groupLabel('Dinâmicos (automáticos)'),
                          ...widget.dynamicRecipients.map((r) => _recipientLine(
                                leading: _dot(context.c.accent),
                                name: r.name,
                                email: r.email,
                                tag: r.tag,
                              )),
                          ..._manuaisDinamico.map((email) => _recipientLine(
                                leading: _dot(context.c.accent),
                                name: 'Manual',
                                email: email,
                                trailing: _iconBtn(Icons.close, () {
                                  setState(
                                      () => _manuaisDinamico.remove(email));
                                }),
                              )),
                          ..._padraoPromovidos.map((email) => _recipientLine(
                                leading: _dot(context.c.accent),
                                name: email,
                                tag: '— Promovido',
                                trailing: _iconBtn(Icons.close, () {
                                  setState(
                                      () => _padraoPromovidos.remove(email));
                                }),
                              )),
                          // Grupo: Padrão (desmarcáveis)
                          if (padraoFiltrados.isNotEmpty ||
                              _manuaisPadrao.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _groupLabel('Padrão (desmarcáveis)'),
                            ...padraoFiltrados.map((ep) {
                              final excluido = _excluidos.contains(ep.email);
                              return _recipientLine(
                                leading: _checkbox(!excluido, () {
                                  setState(() {
                                    if (excluido) {
                                      _excluidos.remove(ep.email);
                                    } else {
                                      _excluidos.add(ep.email);
                                    }
                                  });
                                }),
                                name: ep.email,
                                tag: ep.descricao != null
                                    ? '— ${ep.descricao}'
                                    : null,
                                trailing: _iconBtn(Icons.arrow_upward, () {
                                  setState(
                                      () => _padraoPromovidos.add(ep.email));
                                }),
                              );
                            }),
                            ..._manuaisPadrao.map((mp) => _recipientLine(
                                  leading: _checkbox(mp.checked, () {
                                    setState(() => mp.checked = !mp.checked);
                                  }),
                                  name: mp.email,
                                  tag: '— Manual',
                                  trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _iconBtn(Icons.arrow_upward, () {
                                          setState(() {
                                            _manuaisPadrao.remove(mp);
                                            _manuaisDinamico.add(mp.email);
                                          });
                                        }),
                                        _iconBtn(Icons.close, () {
                                          setState(
                                              () => _manuaisPadrao.remove(mp));
                                        }),
                                      ]),
                                )),
                          ],
                          // Adicionar manual
                          const SizedBox(height: 12),
                          Row(children: [
                            _tipoTab('DINAMICO', 'Dinâmico'),
                            const SizedBox(width: 6),
                            _tipoTab('PADRAO', 'Padrão'),
                          ]),
                          if (_manualError != null) ...[
                            const SizedBox(height: 6),
                            Text(_manualError!,
                                style: TextStyle(
                                    color: context.c.statusRedFg, fontSize: 11)),
                          ],
                          const SizedBox(height: 8),
                          Row(children: [
                            Expanded(
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                    color: context.c.bgElevated,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: _manualError != null
                                            ? context.c.statusRedFg
                                            : context.c.borderSoft)),
                                child: TextField(
                                  controller: _manualCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: (_) {
                                    if (_manualError != null) {
                                      setState(() => _manualError = null);
                                    }
                                  },
                                  onSubmitted: (_) =>
                                      _addManual(padraoFiltrados),
                                  style: TextStyle(
                                      color: context.c.fg0, fontSize: 13),
                                  decoration: InputDecoration(
                                      hintText: 'email@empresa.com',
                                      hintStyle: TextStyle(
                                          color: context.c.fg2,
                                          fontSize: 13),
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 12),
                                      border: InputBorder.none),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 44,
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                    backgroundColor: context.c.accent
                                        .withValues(alpha: .18),
                                    foregroundColor: context.c.accent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                                onPressed: () => _addManual(padraoFiltrados),
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('Adicionar',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13)),
                              ),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  if (errorMsg != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: context.c.statusRedFg.withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: context.c.statusRedFg.withValues(alpha: .4))),
                      child: Row(children: [
                        Icon(Icons.error_outline,
                            color: context.c.statusRedFg, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(errorMsg!,
                                style: TextStyle(
                                    color: context.c.statusRedFg, fontSize: 12))),
                      ]),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(
                        child: _FooterButton(
                            label: 'Voltar',
                            onTap: () => Navigator.pop(context),
                            primary: false)),
                    const SizedBox(width: 10),
                    Expanded(
                        flex: 2,
                        child: _FooterButton(
                            label: 'Registrar e notificar',
                            icon: Icons.send_outlined,
                            onTap: _send)),
                  ]),
                ] else if (stage == 1) ...[
                  const SizedBox(height: 28),
                  _PulsingLoader(),
                  const SizedBox(height: 22),
                  Text(
                    widget.isNc ? 'Publicando NC...' : 'Publicando Desvio...',
                    style: TextStyle(
                        color: context.c.fg0,
                        fontSize: 17,
                        fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Notificando $_lastTotalCount destinatário${_lastTotalCount == 1 ? '' : 's'}.',
                    style: TextStyle(
                        color: context.c.fg2, fontSize: 13),
                  ),
                  const SizedBox(height: 32),
                ] else ...[
                  const SizedBox(height: 12),
                  Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                          color: context.c.statusGreenFg.withValues(alpha: .14),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: context.c.statusGreenFg.withValues(alpha: .4),
                              width: 2)),
                      child: Icon(Icons.check_rounded,
                          color: context.c.statusGreenFg, size: 34)),
                  const SizedBox(height: 16),
                  Text(
                    widget.isNc
                        ? 'NC publicada com sucesso!'
                        : 'Desvio publicado com sucesso!',
                    style: TextStyle(
                        color: context.c.fg0,
                        fontSize: 17,
                        fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_lastTotalCount destinatário${_lastTotalCount == 1 ? '' : 's'} notificado${_lastTotalCount == 1 ? '' : 's'}.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: context.c.fg2, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  _FooterButton(label: 'OK', onTap: () => context.go('/feed')),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Recipients editor helpers ────────────────────────────────────────────
  Widget _groupLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 2, top: 2),
        child: Text(text,
            style: TextStyle(
                color: context.c.fg2,
                fontSize: 10,
                letterSpacing: .3,
                fontWeight: FontWeight.w800)),
      );

  Widget _dot(Color color) => Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle));

  Widget _checkbox(bool checked, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: checked ? context.c.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
                color: checked ? context.c.accent : context.c.borderMain,
                width: 1.5),
          ),
          child: checked
              ? const Icon(Icons.check, color: Colors.white, size: 12)
              : null,
        ),
      );

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Icon(icon, color: context.c.fg2, size: 15),
        ),
      );

  Widget _recipientLine({
    required Widget leading,
    required String name,
    String? email,
    String? tag,
    Widget? trailing,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          leading,
          const SizedBox(width: 9),
          Expanded(
            child: Row(children: [
              Flexible(
                child: Text(name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: context.c.fg0,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
              if (email != null) ...[
                const SizedBox(width: 6),
                Flexible(
                  child: Text('<$email>',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: context.c.fg2, fontSize: 11)),
                ),
              ],
            ]),
          ),
          if (tag != null) ...[
            const SizedBox(width: 6),
            Text(tag,
                style: TextStyle(
                    color: context.c.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w700)),
          ],
          if (trailing != null) trailing,
        ]),
      );

  Widget _tipoTab(String value, String label) {
    final active = _manualTipo == value;
    return GestureDetector(
      onTap: () => setState(() => _manualTipo = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: active
              ? context.c.accent.withValues(alpha: .18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: active ? context.c.accent : context.c.borderSoft),
        ),
        child: Text(label,
            style: TextStyle(
                color: active ? context.c.accent : context.c.fg2,
                fontSize: 11,
                fontWeight: FontWeight.w700)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Misc widgets
// ---------------------------------------------------------------------------


class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final double? height;

  const _TextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    Widget field = TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(
          color: context.c.fg0, fontSize: 14, height: 1.3),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: context.c.fg2, fontSize: 14),
        contentPadding: const EdgeInsets.all(15),
        border: InputBorder.none,
      ),
    );
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
          color: context.c.bgElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.c.borderSoft)),
      child: field,
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
              style: TextStyle(
                  color: context.c.fg2,
                  fontSize: 11,
                  fontWeight: FontWeight.w800))));
}

class _ReviewLine extends StatelessWidget {
  final String label;
  final String value;
  final bool red;
  const _ReviewLine(this.label, this.value, {this.red = false});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(children: [
        Expanded(
            child: Text(label,
                style: TextStyle(
                    color: context.c.fg2, fontSize: 13))),
        Text(value,
            style: TextStyle(
                color: red ? context.c.statusRedFg : context.c.fg0,
                fontSize: 13,
                fontWeight: FontWeight.w900))
      ]));
}


class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text.toUpperCase(),
          style: TextStyle(
              color: context.c.fg2,
              fontSize: 12,
              letterSpacing: .45,
              fontWeight: FontWeight.w900)));
}


class _LocationDropdown extends StatelessWidget {
  final List<Localizacao> items;
  final String? selected;
  final ValueChanged<String?> onChanged;
  const _LocationDropdown(
      {required this.items, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: context.c.bgElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.c.borderSoft),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          isExpanded: true,
          dropdownColor: context.c.bgSurface,
          value: selected,
          hint: Text('Selecionar localizacao (opcional)',
              style: TextStyle(color: context.c.fg2, fontSize: 13)),
          style: TextStyle(color: context.c.fg0, fontSize: 14),
          items: [
            DropdownMenuItem(
                value: null,
                child: Text('— Nenhuma',
                    style: TextStyle(color: context.c.fg2, fontSize: 13))),
            ...items.map((l) =>
                DropdownMenuItem(value: l.id, child: Text(l.nome))),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _SelectRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _SelectRow({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
          color: context.c.bgElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.c.borderSoft)),
      child: Row(children: [
        Icon(icon, color: context.c.fg2, size: 16),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style: TextStyle(
                    color: context.c.fg0,
                    fontSize: 14,
                    fontWeight: FontWeight.w800))),
        Icon(Icons.keyboard_arrow_down_rounded,
            color: context.c.fg2, size: 18)
      ]));
}

class _Footer extends StatelessWidget {
  final String backLabel, nextLabel;
  final IconData nextIcon;
  final VoidCallback onBack, onNext;
  const _Footer(
      {required this.backLabel,
      required this.nextLabel,
      required this.nextIcon,
      required this.onBack,
      required this.onNext});
  @override
  Widget build(BuildContext context) => Column(children: [
        Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
                color: context.c.bgSurface,
                border: Border(top: BorderSide(color: context.c.borderSoft))),
            child: Row(children: [
              Expanded(
                  child: _FooterButton(
                      label: backLabel, onTap: onBack, primary: false)),
              const SizedBox(width: 8),
              Expanded(
                  flex: 2,
                  child: _FooterButton(
                      label: nextLabel, icon: nextIcon, onTap: onNext))
            ])),
        Container(
            width: 100,
            height: 4,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(99)))
      ]);
}

class _FooterButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool primary;
  final IconData? icon;
  const _FooterButton(
      {required this.label,
      required this.onTap,
      this.primary = true,
      this.icon});
  @override
  Widget build(BuildContext context) => SizedBox(
      height: 48,
      child: FilledButton.icon(
          style: FilledButton.styleFrom(
              backgroundColor:
                  primary ? context.c.accent : context.c.bgElevated,
              foregroundColor:
                  primary ? Colors.white : context.c.fg0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          onPressed: onTap,
          icon: primary
              ? Icon(icon ?? Icons.arrow_forward_rounded, size: 16)
              : const SizedBox.shrink(),
          label: Text(label,
              maxLines: 1,
              style:
                  const TextStyle(fontWeight: FontWeight.w900))));
}
