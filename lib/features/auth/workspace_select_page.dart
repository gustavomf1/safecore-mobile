import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../ocorrencias/model/empresa.dart';
import '../ocorrencias/model/estabelecimento.dart';
import '../ocorrencias/repository/support_repository_impl.dart';
import '../auth/model/workspace_state.dart';
import 'provider/auth_provider.dart';
import 'repository/auth_repository_impl.dart';
import '../../shared/theme/tokens.dart';

enum _Step { empresa, estabelecimento, empresaFilha }

class WorkspaceSelectPage extends ConsumerStatefulWidget {
  const WorkspaceSelectPage({super.key});

  @override
  ConsumerState<WorkspaceSelectPage> createState() => _WorkspaceSelectPageState();
}

class _WorkspaceSelectPageState extends ConsumerState<WorkspaceSelectPage> {
  _Step step = _Step.empresa;
  Empresa? empresaSelecionada;
  Estabelecimento? estabelecimentoSelecionado;

  void _selecionarEmpresa(Empresa emp) {
    setState(() {
      empresaSelecionada = emp;
      step = _Step.estabelecimento;
    });
  }

  void _selecionarEstabelecimento(Estabelecimento est) {
    setState(() {
      estabelecimentoSelecionado = est;
      step = _Step.empresaFilha;
    });
  }

  void _selecionarEmpresaFilha(Empresa filha) {
    final workspace = WorkspaceState(
      empresa: empresaSelecionada!,
      estabelecimento: estabelecimentoSelecionado!,
      empresaFilha: filha,
    );
    ref.read(workspaceProvider.notifier).state = workspace;
    // Persistido localmente pra sobreviver a um cold start offline (sem essa
    // gravação, fechar o app sem internet trava o usuário nesta tela — ela
    // sempre precisa de rede pra listar empresas/estabelecimentos).
    ref.read(authRepositoryProvider).salvarWorkspace(workspace);
    context.go('/feed');
  }

  void _voltar() {
    setState(() {
      if (step == _Step.empresaFilha) {
        step = _Step.estabelecimento;
      } else if (step == _Step.estabelecimento) {
        step = _Step.empresa;
        empresaSelecionada = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      backgroundColor: c.bgBase,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  if (step != _Step.empresa)
                    IconButton(
                      icon: Icon(Icons.arrow_back_rounded, color: c.fg0),
                      onPressed: _voltar,
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step == _Step.empresa
                              ? 'Selecionar empresa'
                              : step == _Step.estabelecimento
                                  ? 'Selecionar estabelecimento'
                                  : 'Empresa contratada',
                          style: SafeCoreType.headline.copyWith(color: c.fg0),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          step == _Step.empresa
                              ? 'Escolha a empresa para esta sessão'
                              : step == _Step.estabelecimento
                                  ? empresaSelecionada?.nome ?? ''
                                  : estabelecimentoSelecionado?.nome ?? '',
                          style: SafeCoreType.bodyRegular.copyWith(color: c.fg2, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _StepIndicator(step: step),
            const SizedBox(height: 8),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (step) {
      case _Step.empresa:
        return _ListaEmpresas(onSelect: _selecionarEmpresa);
      case _Step.estabelecimento:
        return _ListaEstabelecimentos(
          empresaId: empresaSelecionada!.id,
          onSelect: _selecionarEstabelecimento,
        );
      case _Step.empresaFilha:
        return _ListaEmpresasFilhas(
          estabelecimentoId: estabelecimentoSelecionado!.id,
          onSelect: _selecionarEmpresaFilha,
        );
    }
  }
}

class _StepIndicator extends StatelessWidget {
  final _Step step;
  const _StepIndicator({required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          const _Dot(active: true, label: '1'),
          _Line(active: step != _Step.empresa),
          _Dot(active: step != _Step.empresa, label: '2'),
          _Line(active: step == _Step.empresaFilha),
          _Dot(active: step == _Step.empresaFilha, label: '3'),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  final String label;
  const _Dot({required this.active, required this.label});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? c.accent : c.bgSurface,
        shape: BoxShape.circle,
        border: Border.all(color: active ? c.accent : c.borderSoft),
      ),
      child: Text(label, style: SafeCoreType.label.copyWith(color: active ? Colors.white : c.fg2, fontSize: 12)),
    );
  }
}

class _Line extends StatelessWidget {
  final bool active;
  const _Line({required this.active});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Expanded(
      child: Container(
        height: 2,
        color: active ? c.accent : c.borderSoft,
      ),
    );
  }
}

class _ListaEmpresas extends ConsumerWidget {
  final void Function(Empresa) onSelect;
  const _ListaEmpresas({required this.onSelect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final async = ref.watch(empresasMaeProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erro: $e', style: TextStyle(color: c.statusRedFg))),
      data: (list) => _Lista(
        items: list.map((e) => _Item(id: e.id, nome: e.nome, onTap: () => onSelect(e))).toList(),
      ),
    );
  }
}

class _ListaEstabelecimentos extends ConsumerWidget {
  final String empresaId;
  final void Function(Estabelecimento) onSelect;
  const _ListaEstabelecimentos({required this.empresaId, required this.onSelect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final async = ref.watch(estabelecimentosProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erro: $e', style: TextStyle(color: c.statusRedFg))),
      data: (list) {
        final filtrados = list.where((e) => e.empresaId == empresaId).toList();
        if (filtrados.isEmpty) {
          return Center(child: Text('Nenhum estabelecimento encontrado.', style: SafeCoreType.body.copyWith(color: c.fg2)));
        }
        return _Lista(
          items: filtrados.map((e) => _Item(id: e.id, nome: e.nome, onTap: () => onSelect(e))).toList(),
        );
      },
    );
  }
}

class _ListaEmpresasFilhas extends ConsumerWidget {
  final String estabelecimentoId;
  final void Function(Empresa) onSelect;
  const _ListaEmpresasFilhas({required this.estabelecimentoId, required this.onSelect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final async = ref.watch(empresasDoEstabelecimentoProvider(estabelecimentoId));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erro: $e', style: TextStyle(color: c.statusRedFg))),
      data: (list) {
        if (list.isEmpty) {
          return Center(child: Text('Nenhuma empresa contratada encontrada.', style: SafeCoreType.body.copyWith(color: c.fg2)));
        }
        return _Lista(
          items: list.map((e) => _Item(id: e.id, nome: e.nome, onTap: () => onSelect(e))).toList(),
        );
      },
    );
  }
}

class _Lista extends StatelessWidget {
  final List<_Item> items;
  const _Lista({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => items[i],
    );
  }
}

class _Item extends StatelessWidget {
  final String id;
  final String nome;
  final VoidCallback onTap;
  const _Item({required this.id, required this.nome, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return InkWell(
      borderRadius: BorderRadius.circular(SafeCoreRadius.md),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: c.bgSurface,
          borderRadius: BorderRadius.circular(SafeCoreRadius.md),
          border: Border.all(color: c.borderSoft),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(nome, style: SafeCoreType.bodyStrong.copyWith(color: c.fg0, fontSize: 14)),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: c.fg2, size: 14),
          ],
        ),
      ),
    );
  }
}
