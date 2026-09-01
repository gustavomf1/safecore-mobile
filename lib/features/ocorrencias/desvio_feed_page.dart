import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_config.dart';
import '../../shared/theme/tokens.dart';
import '../../shared/widgets/eng_cover_card.dart';
import '../../shared/widgets/eng_pill.dart';
import '../../shared/widgets/eng_skeleton.dart';
import '../../shared/widgets/motion_helpers.dart';
import '../../shared/widgets/ocorrencia_filter_sheet.dart';
import '../../shared/widgets/ocorrencia_search_bar.dart';
import '../../shared/widgets/status_color_helper.dart';
import '../auth/provider/auth_provider.dart';
import 'model/ocorrencia_summary.dart';
import 'ocorrencia_filtering.dart';
import 'repository/ocorrencias_repository_impl.dart';

class DesvioFeedPage extends ConsumerStatefulWidget {
  const DesvioFeedPage({super.key});

  @override
  ConsumerState<DesvioFeedPage> createState() => _DesvioFeedPageState();
}

class _DesvioFeedPageState extends ConsumerState<DesvioFeedPage> {
  final _searchController = TextEditingController();
  String _busca = '';
  String _status = kTodosBucket;
  String? _papel;
  DateTime? _dataInicio;
  DateTime? _dataFim;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _activeFilterCount =>
      (_status != kTodosBucket ? 1 : 0) +
      (_papel != null ? 1 : 0) +
      ((_dataInicio != null || _dataFim != null) ? 1 : 0);

  Future<void> _openFilterSheet(Map<String, int> counts) async {
    final result = await showOcorrenciaFilterSheet(
      context,
      statusOptions: desvioStatusOptions,
      statusCounts: counts,
      selectedStatus: _status,
      papelOptions: desvioPapelOptions,
      selectedPapel: _papel,
      dataInicio: _dataInicio,
      dataFim: _dataFim,
    );
    if (result != null) {
      setState(() {
        _status = result.status;
        _papel = result.papel;
        _dataInicio = result.dataInicio;
        _dataFim = result.dataFim;
      });
    }
  }

  List<OcorrenciaSummary> _applyFilter(List<OcorrenciaSummary> list) {
    return list.where((d) {
      final matchStatus = _status == kTodosBucket || bucketForDesvio(d) == _status;
      final matchBusca = matchBuscaEData(
        d,
        busca: _busca,
        dataInicio: _dataInicio,
        dataFim: _dataFim,
      );
      return matchStatus && matchBusca;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authProvider).valueOrNull;
    final isExterno = session?.perfil == 'EXTERNO';
    final workspace = ref.watch(workspaceProvider);
    final workspaceId = workspace?.estabelecimento.id;

    final (String?, String?) providerKey = (isExterno ? null : workspaceId, _papel);

    final desviosAsync = (isExterno || workspaceId != null)
        ? ref.watch(ocorrenciasProvider(providerKey)).whenData(
              (list) => list.where((o) => o.isDesvio).toList(),
            )
        : const AsyncData<List<OcorrenciaSummary>>([]);

    return Scaffold(
      backgroundColor: EngSegColors.dark.bgBase,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: EngSegColors.dark.accent,
          backgroundColor: EngSegColors.dark.bgElevated,
          onRefresh: () async {
            ref.invalidate(ocorrenciasProvider(providerKey));
            await ref
                .read(ocorrenciasProvider(providerKey).future)
                .catchError((_) => <OcorrenciaSummary>[]);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 104),
            children: [
              OcorrenciaSearchBar(
                controller: _searchController,
                onChanged: (v) => setState(() => _busca = v),
                activeFilterCount: _activeFilterCount,
                onFilterTap: () {
                  final list = desviosAsync.valueOrNull ?? const <OcorrenciaSummary>[];
                  final counts = {
                    for (final opt in desvioStatusOptions)
                      opt.key: opt.key == kTodosBucket
                          ? list.length
                          : list.where((d) => bucketForDesvio(d) == opt.key).length,
                  };
                  _openFilterSheet(counts);
                },
              ),
              const SizedBox(height: 12),
              desviosAsync.when(
                loading: () => Column(
                  children: List.generate(3, (_) => const CoverCardSkeleton()),
                ),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline,
                            size: 48, color: EngSegColors.dark.statusRedFg),
                        const SizedBox(height: 12),
                        Text('Erro ao carregar',
                            style: TextStyle(
                                color: EngSegColors.dark.statusRedFg,
                                fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('$e',
                            style: TextStyle(
                                color: EngSegColors.dark.fg3, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                data: (list) {
                  final filtered = _applyFilter(list);
                  if (filtered.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 68),
                      child: Column(
                        children: [
                          Icon(Icons.inbox_outlined,
                              size: 48, color: EngSegColors.dark.fg3),
                          const SizedBox(height: 12),
                          Text('Nenhum desvio encontrado',
                              style: TextStyle(
                                  color: EngSegColors.dark.fg2, fontSize: 14)),
                        ],
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (var i = 0; i < filtered.length; i++)
                        _buildCard(filtered[i]).staggered(i),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(OcorrenciaSummary dv) {
    final dvColors = StatusColorHelper.desvioColors(dv.status);
    final coverUrl = dv.primeiraEvidenciaId != null
        ? '${AppConfig.apiBaseUrl}/api/evidencias/${dv.primeiraEvidenciaId}/download'
        : null;
    return EngCoverCard(
      id: dv.id,
      codigo: dv.codigo,
      titulo: dv.titulo,
      coverUrl: coverUrl,
      hasImageCover: dv.hasImageCover,
      hasAnyCover: dv.hasAnyCover,
      pills: [
        EngPill(
          label: 'Desvio',
          bg: EngSegColors.dark.statusYellowBg,
          fg: EngSegColors.dark.statusYellowFg,
        ),
        EngPill(
          label: StatusColorHelper.desvioLabel(dv.status),
          bg: dvColors.bg,
          fg: dvColors.fg,
        ),
      ],
      meta: '${dv.estabelecimentoNome} · ${dv.dataRegistro}',
      onTap: () => context.push('/desvio/${dv.id}'),
    );
  }
}
