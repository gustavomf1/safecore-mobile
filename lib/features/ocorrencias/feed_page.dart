import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_config.dart';
import '../../shared/theme/tokens.dart';
import '../../shared/widgets/safecore_cover_card.dart';
import '../../shared/widgets/safecore_pill.dart';
import '../../shared/widgets/safecore_skeleton.dart';
import '../../shared/widgets/motion_helpers.dart';
import '../../shared/widgets/ocorrencia_filter_sheet.dart';
import '../../shared/widgets/ocorrencia_search_bar.dart';
import '../../shared/widgets/status_color_helper.dart';
import '../auth/provider/auth_provider.dart';
import 'model/ocorrencia_summary.dart';
import 'ocorrencia_filtering.dart';
import 'repository/ocorrencias_repository_impl.dart';

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

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
      statusOptions: ncStatusOptions,
      statusCounts: counts,
      selectedStatus: _status,
      papelOptions: ncPapelOptions,
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final c = context.c;
    final session = ref.watch(authProvider).valueOrNull;
    final isExterno = session?.perfil == 'EXTERNO';
    final workspace = ref.watch(workspaceProvider);
    final workspaceId = workspace?.estabelecimento.id;

    final (String?, String?) providerKey = (isExterno ? null : workspaceId, _papel);

    final ncsAsync = (isExterno || workspaceId != null)
        ? ref.watch(ocorrenciasProvider(providerKey)).whenData(
              (list) => list.where((o) => o.isNc).toList(),
            )
        : const AsyncData<List<OcorrenciaSummary>>([]);

    return Scaffold(
      backgroundColor: c.bgBase,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: c.accent,
          backgroundColor: c.bgElevated,
          onRefresh: () async {
            ref.invalidate(ocorrenciasProvider(providerKey));
            await ref
                .read(ocorrenciasProvider(providerKey).future)
                .catchError((_) => <OcorrenciaSummary>[]);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 104),
            children: [
              OcorrenciaSearchBar(
                controller: _searchController,
                onChanged: (v) => setState(() => _busca = v),
                activeFilterCount: _activeFilterCount,
                onFilterTap: () {
                  final ncs = ncsAsync.valueOrNull ?? const <OcorrenciaSummary>[];
                  final counts = {
                    for (final opt in ncStatusOptions)
                      opt.key: opt.key == kTodosBucket
                          ? ncs.length
                          : ncs.where((n) => bucketForNc(n) == opt.key).length,
                  };
                  _openFilterSheet(counts);
                },
              ),
              const SizedBox(height: 12),
              ncsAsync.when(
                loading: () => Column(
                  children:
                      List.generate(3, (_) => const CoverCardSkeleton()),
                ),
                error: (e, _) => _ErrorState(message: '$e'),
                data: (ncs) {
                  final filtered = _applyFilter(ncs);
                  if (filtered.isEmpty) {
                    return const _EmptyState(message: 'Nenhuma NC encontrada');
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

  List<OcorrenciaSummary> _applyFilter(List<OcorrenciaSummary> ncs) {
    return ncs.where((n) {
      final matchStatus = _status == kTodosBucket || bucketForNc(n) == _status;
      final matchBusca = matchBuscaEData(
        n,
        busca: _busca,
        dataInicio: _dataInicio,
        dataFim: _dataFim,
      );
      return matchStatus && matchBusca;
    }).toList();
  }

  Widget _buildCard(OcorrenciaSummary nc) {
    final c = context.c;
    final ncColors = StatusColorHelper.ncColors(c, nc.status, vencida: nc.vencida);
    final coverUrl = nc.primeiraEvidenciaId != null
        ? '${AppConfig.apiBaseUrl}/api/evidencias/${nc.primeiraEvidenciaId}/download'
        : null;

    return SafeCoreCoverCard(
      id: nc.id,
      codigo: nc.codigo,
      titulo: nc.titulo,
      coverUrl: coverUrl,
      hasImageCover: nc.hasImageCover,
      hasAnyCover: nc.hasAnyCover,
      pills: [
        SafeCorePill(
          label: 'NC',
          bg: c.statusRedBg,
          fg: c.statusRedFg,
        ),
        SafeCorePill(
          label: StatusColorHelper.ncLabel(nc.status),
          bg: ncColors.bg,
          fg: ncColors.fg,
        ),
        if (nc.vencida)
          SafeCorePill(
            label: 'Vencida',
            bg: c.statusRedBg,
            fg: c.statusRedFg,
          ),
      ],
      meta: '${nc.estabelecimentoNome} · ${nc.nivelRisco ?? ''}',
      onTap: () => context.push('/oc/${nc.id}'),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: c.fg3),
          const SizedBox(height: 12),
          Text(message, style: SafeCoreType.subtitle.copyWith(color: c.fg2)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: c.statusRedFg),
          const SizedBox(height: 12),
          Text('Erro ao carregar', style: SafeCoreType.subtitle.copyWith(color: c.statusRedFg)),
          const SizedBox(height: 4),
          Text(message, style: SafeCoreType.body.copyWith(color: c.fg3)),
        ],
      ),
    );
  }
}
