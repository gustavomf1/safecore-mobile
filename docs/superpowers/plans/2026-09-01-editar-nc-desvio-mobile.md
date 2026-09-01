# Editar NC/Desvio no mobile — Plano de Implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Permitir editar uma NC/Desvio já criada no app mobile (hoje não existe nenhuma forma de editar), com paridade de campos com o formulário web `RegistroOcorrenciaPage`, exceto vínculo de trecho de norma, reincidência e exclusão (fora de escopo).

**Architecture:** Tela nova self-contained (`edit_ocorrencia_page.dart`) que reaproveita os models/providers públicos já existentes (`ncRepositoryProvider`, `desvioRepositoryProvider`, `usuariosProvider`, `usuariosPorEmpresaProvider`, `localizacoesProvider`, `normasProvider`), sem tocar no `wizard_page.dart` (3213 linhas, acoplado à captura de câmera). Dois pontos de entrada (menu "⋮" em `detail_page.dart`, ícone novo no `AppBar` de `desvio_detail_page.dart`) mais o botão "Editar" no dialog de campos obrigatórios de ambas as páginas, todos atrás do mesmo gate de permissão (criador ou admin, apenas com a ocorrência aberta).

**Tech Stack:** Flutter, Riverpod (`flutter_riverpod`), `go_router`, `dio`.

**Spec:** `docs/superpowers/specs/2026-09-01-editar-nc-desvio-mobile-design.md`

## Global Constraints

- Nunca enviar `severidade`/`probabilidade` como `0` no payload — o backend valida `@Min(1)`. Enviar `null` quando não selecionado (`valor > 0 ? valor : null`).
- `normaIds` no PUT precisa vir sempre populado com os vínculos atuais da NC (mesmo que o usuário não mexa na seção de normas) — se vier como lista vazia não-nula, o backend desvincula todas as normas (`NaoConformidadeService.update`, linha ~261).
- Não modificar `lib/features/wizard/wizard_page.dart`.
- Tema visual da tela nova: paleta escura própria (mesmos valores de `_NcDetailColors` em `detail_page.dart`), não o `ProtoColors` legado usado por `wizard_page.dart`/`desvio_detail_page.dart`.
- Gate de permissão em todo ponto de entrada: `isAberto(a) ? (isCriador || isAdmin) : isAdmin`.
- Verificação de cada task: `flutter analyze` sem apontamentos. Task final: verificação manual no dispositivo físico já conectado (Redmi Note 7, `f868b62`) via `adb exec-out screencap`.

---

## Task 1: Expor IDs no `NcDetail`

**Files:**
- Modify: `lib/features/ocorrencias/model/nc_detail.dart`

**Interfaces:**
- Produces: `NcDetail.localizacaoId` (`String?`), `NcDetail.empresaContratadaId` (`String?`), `NcDetail.responsavelTrativaId` (`String?`), `NcDetail.responsavelNcId` (`String?`) — todos já vêm em `NaoConformidadeResponse` (backend), só não eram parseados.

- [ ] **Step 1: Adicionar os campos e o parse no `fromJson`**

Em `lib/features/ocorrencias/model/nc_detail.dart`, adicionar os quatro campos à classe, ao construtor e ao `fromJson`:

```dart
class NcDetail {
  final String id;
  final String titulo;
  final String? descricao;
  final String status;
  final String nivelRisco;
  final int? severidade;
  final int? probabilidade;
  final bool regraDeOuro;
  final bool reincidencia;
  final String? ncAnteriorId;
  final String? ncAnteriorTitulo;
  final String estabelecimentoId;
  final String estabelecimentoNome;
  final String usuarioCriacaoNome;
  final String? usuarioCriacaoEmail;
  final String? usuarioCriacaoId;
  final String? localizacaoId;
  final String? localizacaoNome;
  final String? empresaContratadaId;
  final String? responsavelTrativaId;
  final String? responsavelNcId;
  final String? dataLimiteResolucao;
  final String dataRegistro;
  final bool vencida;
  final String? responsavelTrativaNome;
  final String? responsavelTrativaEmail;
  final String? responsavelTrativaPerfil;
  final String? responsavelNcNome;
  final String? responsavelNcEmail;
  final String? responsavelNcPerfil;
  final List<Map<String, dynamic>> atividades;
  final List<Map<String, dynamic>> historico;
  final List<Map<String, dynamic>> normas;
  final String? causaRaiz;
  final String? descricaoExecucao;
  final List<Map<String, dynamic>> porques;
  final List<Map<String, dynamic>> investigacaoSnapshots;
  final List<Map<String, dynamic>> execucaoSnapshots;

  const NcDetail({
    required this.id,
    required this.titulo,
    this.descricao,
    required this.status,
    required this.nivelRisco,
    this.severidade,
    this.probabilidade,
    required this.regraDeOuro,
    required this.reincidencia,
    this.ncAnteriorId,
    this.ncAnteriorTitulo,
    required this.estabelecimentoId,
    required this.estabelecimentoNome,
    required this.usuarioCriacaoNome,
    this.usuarioCriacaoEmail,
    this.usuarioCriacaoId,
    this.localizacaoId,
    this.localizacaoNome,
    this.empresaContratadaId,
    this.responsavelTrativaId,
    this.responsavelNcId,
    this.dataLimiteResolucao,
    required this.dataRegistro,
    this.vencida = false,
    this.responsavelTrativaNome,
    this.responsavelTrativaEmail,
    this.responsavelTrativaPerfil,
    this.responsavelNcNome,
    this.responsavelNcEmail,
    this.responsavelNcPerfil,
    this.atividades = const [],
    this.historico = const [],
    this.normas = const [],
    this.causaRaiz,
    this.descricaoExecucao,
    this.porques = const [],
    this.investigacaoSnapshots = const [],
    this.execucaoSnapshots = const [],
  });

  factory NcDetail.fromJson(Map<String, dynamic> json) => NcDetail(
        id: json['id'] as String,
        titulo: json['titulo'] as String,
        descricao: json['descricao'] as String?,
        status: json['status'] as String,
        nivelRisco: json['nivelRisco'] as String? ?? 'MEDIO',
        severidade: json['severidade'] as int?,
        probabilidade: json['probabilidade'] as int?,
        regraDeOuro: json['regraDeOuro'] as bool? ?? false,
        reincidencia: json['reincidencia'] as bool? ?? false,
        ncAnteriorId: json['ncAnteriorId'] as String?,
        ncAnteriorTitulo: json['ncAnteriorTitulo'] as String?,
        estabelecimentoId: json['estabelecimentoId'] as String? ?? '',
        estabelecimentoNome: json['estabelecimentoNome'] as String? ?? '',
        usuarioCriacaoNome: json['usuarioCriacaoNome'] as String? ?? '',
        usuarioCriacaoEmail: json['usuarioCriacaoEmail'] as String?,
        usuarioCriacaoId: json['usuarioCriacaoId'] as String?,
        localizacaoId: json['localizacaoId'] as String?,
        localizacaoNome: json['localizacaoNome'] as String?,
        empresaContratadaId: json['empresaContratadaId'] as String?,
        responsavelTrativaId: json['responsavelTrativaId'] as String?,
        responsavelNcId: json['responsavelNcId'] as String?,
        dataLimiteResolucao: json['dataLimiteResolucao'] as String?,
        dataRegistro: json['dataRegistro'] as String? ?? '',
        vencida: _calcVencida(json),
        responsavelTrativaNome: json['responsavelTrativaNome'] as String?,
        responsavelTrativaEmail: json['responsavelTrativaEmail'] as String?,
        responsavelTrativaPerfil: json['responsavelTrativaPerfil'] as String?,
        responsavelNcNome: json['responsavelNcNome'] as String?,
        responsavelNcEmail: json['responsavelNcEmail'] as String?,
        responsavelNcPerfil: json['responsavelNcPerfil'] as String?,
        atividades: (json['atividades'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>(),
        historico: (json['historico'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>(),
        normas: (json['normas'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>(),
        causaRaiz: json['causaRaiz'] as String?,
        descricaoExecucao: json['descricaoExecucao'] as String?,
        porques: _buildPorques(json),
        investigacaoSnapshots: (json['investigacaoSnapshots'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>(),
        execucaoSnapshots: (json['execucaoSnapshots'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>(),
      );
}
```

(As funções `_buildPorques` e `_calcVencida` no fim do arquivo não mudam.)

- [ ] **Step 2: Verificar**

Run: `cd /home/mag/Documents/mobile/engseg-mobile && flutter analyze lib/features/ocorrencias/model/nc_detail.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
cd /home/mag/Documents/mobile/engseg-mobile
git add lib/features/ocorrencias/model/nc_detail.dart
git commit -m "feat: expõe localizacaoId/empresaContratadaId/responsaveis em NcDetail"
```

---

## Task 2: Expor IDs no `DesvioDetail`

**Files:**
- Modify: `lib/features/ocorrencias/model/desvio_detail.dart`

**Interfaces:**
- Produces: `DesvioDetail.localizacaoId` (`String?`), `DesvioDetail.empresaContratadaId` (`String?`) — `responsavelDesvioId`/`responsavelTratativaId` já existiam.

- [ ] **Step 1: Adicionar os dois campos**

Substituir o conteúdo de `lib/features/ocorrencias/model/desvio_detail.dart` por:

```dart
import 'trativa_desvio.dart';

class DesvioDetail {
  final String id;
  final String titulo;
  final String status; // ABERTO | AGUARDANDO_TRATATIVA | AGUARDANDO_APROVACAO | CONCLUIDO
  final String estabelecimentoId;
  final String estabelecimentoNome;
  final String? localizacaoId;
  final String? localizacaoNome;
  final String? empresaContratadaId;
  final String? descricao;
  final String? orientacaoRealizada;
  final bool regraDeOuro;
  final String dataRegistro;
  final String? responsavelDesvioId;
  final String? responsavelDesvioNome;
  final String? responsavelTratativaId;
  final String? responsavelTratativaNome;
  final String? usuarioCriacaoNome;
  final String? usuarioCriacaoEmail;
  final List<TrativaDesvio> tratativas;
  final List<Map<String, dynamic>> historico;

  const DesvioDetail({
    required this.id,
    required this.titulo,
    required this.status,
    this.estabelecimentoId = '',
    this.estabelecimentoNome = '',
    this.localizacaoId,
    this.localizacaoNome,
    this.empresaContratadaId,
    this.descricao,
    this.orientacaoRealizada,
    this.regraDeOuro = false,
    this.dataRegistro = '',
    this.responsavelDesvioId,
    this.responsavelDesvioNome,
    this.responsavelTratativaId,
    this.responsavelTratativaNome,
    this.usuarioCriacaoNome,
    this.usuarioCriacaoEmail,
    this.tratativas = const [],
    this.historico = const [],
  });

  factory DesvioDetail.fromJson(Map<String, dynamic> j) => DesvioDetail(
        id: j['id'] as String,
        titulo: j['titulo'] as String? ?? '',
        status: j['status'] as String? ?? 'ABERTO',
        estabelecimentoId: j['estabelecimentoId'] as String? ?? '',
        estabelecimentoNome: j['estabelecimentoNome'] as String? ?? '',
        localizacaoId: j['localizacaoId'] as String?,
        localizacaoNome: j['localizacaoNome'] as String?,
        empresaContratadaId: j['empresaContratadaId'] as String?,
        descricao: j['descricao'] as String?,
        orientacaoRealizada: j['orientacaoRealizada'] as String?,
        regraDeOuro: j['regraDeOuro'] as bool? ?? false,
        dataRegistro: j['dataRegistro'] as String? ?? '',
        responsavelDesvioId: j['responsavelDesvioId'] as String?,
        responsavelDesvioNome: j['responsavelDesvioNome'] as String?,
        responsavelTratativaId: j['responsavelTratativaId'] as String?,
        // chave backend tem typo "Trativa" (DesvioResponse.responsavelTrativaNome)
        responsavelTratativaNome: j['responsavelTrativaNome'] as String?,
        usuarioCriacaoNome: j['usuarioCriacaoNome'] as String?,
        usuarioCriacaoEmail: j['usuarioCriacaoEmail'] as String?,
        tratativas: (j['tratativas'] as List<dynamic>? ?? [])
            .map((e) => TrativaDesvio.fromJson(e as Map<String, dynamic>))
            .toList(),
        historico: (j['historico'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>(),
      );

  int get rodadaAtual {
    final rodadas = tratativas.map((t) => t.rodada).whereType<int>();
    return rodadas.isEmpty ? 0 : rodadas.reduce((a, b) => a > b ? a : b);
  }

  bool get temTratativasPendentesNaoSubmetidas =>
      tratativas.any((t) => t.rodada == null && t.status == 'PENDENTE');
}
```

- [ ] **Step 2: Verificar**

Run: `cd /home/mag/Documents/mobile/engseg-mobile && flutter analyze lib/features/ocorrencias/model/desvio_detail.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
cd /home/mag/Documents/mobile/engseg-mobile
git add lib/features/ocorrencias/model/desvio_detail.dart
git commit -m "feat: expõe localizacaoId/empresaContratadaId em DesvioDetail"
```

---

## Task 3: `atualizar()` em `NcRepository`

**Files:**
- Modify: `lib/features/ocorrencias/repository/nc_repository.dart`
- Modify: `lib/features/ocorrencias/repository/nc_repository_impl.dart`

**Interfaces:**
- Consumes: `CriarNcRequest.toJson()` (já existe).
- Produces: `NcRepository.atualizar(String id, CriarNcRequest request)` → `Future<NcDetail>`.

- [ ] **Step 1: Adicionar o método à interface**

Em `lib/features/ocorrencias/repository/nc_repository.dart`:

```dart
import '../model/nc_summary.dart';
import '../model/nc_detail.dart';
import '../model/criar_nc_request.dart';
import '../model/rascunho_local.dart';

abstract class NcRepository {
  Future<List<NcSummary>> listar({String? estabelecimentoId, String? status});
  Future<NcDetail> buscarPorId(String id);
  Future<NcDetail> criar(CriarNcRequest request);
  Future<NcDetail> atualizar(String id, CriarNcRequest request);
  Future<void> salvarRascunho(RascunhoLocal rascunho);
}
```

- [ ] **Step 2: Implementar em `NcRepositoryImpl`**

Em `lib/features/ocorrencias/repository/nc_repository_impl.dart`, logo abaixo do método `criar` (linha ~152-158):

```dart
  @override
  Future<NcDetail> criar(CriarNcRequest request) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/api/nao-conformidades',
      data: request.toJson(),
    );
    return NcDetail.fromJson(response.data!);
  }

  @override
  Future<NcDetail> atualizar(String id, CriarNcRequest request) async {
    final response = await dio.put<Map<String, dynamic>>(
      '/api/nao-conformidades/$id',
      data: request.toJson(),
    );
    return NcDetail.fromJson(response.data!);
  }
```

- [ ] **Step 3: Verificar**

Run: `cd /home/mag/Documents/mobile/engseg-mobile && flutter analyze lib/features/ocorrencias/repository/nc_repository.dart lib/features/ocorrencias/repository/nc_repository_impl.dart`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
cd /home/mag/Documents/mobile/engseg-mobile
git add lib/features/ocorrencias/repository/nc_repository.dart lib/features/ocorrencias/repository/nc_repository_impl.dart
git commit -m "feat: NcRepository.atualizar() via PUT /api/nao-conformidades/:id"
```

---

## Task 4: `atualizar()` em `DesvioRepository`

**Files:**
- Modify: `lib/features/ocorrencias/repository/desvio_repository.dart`
- Modify: `lib/features/ocorrencias/repository/desvio_repository_impl.dart`

**Interfaces:**
- Consumes: `CriarDesvioRequest.toJson()` (já existe).
- Produces: `DesvioRepository.atualizar(String id, CriarDesvioRequest request)` → `Future<DesvioDetail>`.

- [ ] **Step 1: Adicionar o método à interface**

Em `lib/features/ocorrencias/repository/desvio_repository.dart`:

```dart
import '../model/desvio_summary.dart';
import '../model/desvio_detail.dart';
import '../model/criar_desvio_request.dart';
import '../model/desvio_action_requests.dart';

abstract class DesvioRepository {
  Future<List<DesvioSummary>> listar({String? estabelecimentoId});
  Future<DesvioDetail> buscarDetalhe(String id);
  Future<Map<String, dynamic>> criar(CriarDesvioRequest request);
  Future<DesvioDetail> atualizar(String id, CriarDesvioRequest request);
  Future<void> abrirTratativa(String id);
  Future<void> adicionarTratativa(String id, AdicionarTrativaRequest request);
  Future<void> removerTratativa(String id, String trativaId);
  Future<void> submeterTratativa(String id, SubmeterTrativaDesvioRequest request);
  Future<void> aprovar(String id, AprovarDesvioRequest request);
  Future<void> reprovar(String id, ReprovarTrativasDesvioRequest request);
}
```

- [ ] **Step 2: Implementar em `DesvioRepositoryImpl`**

Em `lib/features/ocorrencias/repository/desvio_repository_impl.dart`, logo abaixo do método `criar` (linha ~77-83):

```dart
  @override
  Future<Map<String, dynamic>> criar(CriarDesvioRequest request) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/api/desvios',
      data: request.toJson(),
    );
    return response.data!;
  }

  @override
  Future<DesvioDetail> atualizar(String id, CriarDesvioRequest request) async {
    final response = await dio.put<Map<String, dynamic>>(
      '/api/desvios/$id',
      data: request.toJson(),
    );
    return DesvioDetail.fromJson(response.data!);
  }
```

Se `DesvioDetail` não estiver importado nesse arquivo, adicionar `import '../model/desvio_detail.dart';` ao topo.

- [ ] **Step 3: Verificar**

Run: `cd /home/mag/Documents/mobile/engseg-mobile && flutter analyze lib/features/ocorrencias/repository/desvio_repository.dart lib/features/ocorrencias/repository/desvio_repository_impl.dart`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
cd /home/mag/Documents/mobile/engseg-mobile
git add lib/features/ocorrencias/repository/desvio_repository.dart lib/features/ocorrencias/repository/desvio_repository_impl.dart
git commit -m "feat: DesvioRepository.atualizar() via PUT /api/desvios/:id"
```

---

## Task 5: Tornar público o provider de detalhe da NC

**Files:**
- Modify: `lib/features/ocorrencias/detail_page.dart`

**Interfaces:**
- Produces: `ncDetailProvider` (renomeado de `_ncDetailProvider`, mesmo tipo `FutureProvider.family<NcDetail, String>`) — precisa ser público para a tela de edição (arquivo diferente) conseguir dar `ref.invalidate(ncDetailProvider(id))` depois de salvar.

O provider é privado hoje (prefixo `_`) porque só era usado dentro do próprio arquivo. `desvioDetailProvider` (equivalente para Desvio) já é público, definido em `desvio_repository_impl.dart` — este rename só alinha a NC ao mesmo padrão.

- [ ] **Step 1: Renomear a definição do provider**

Em `lib/features/ocorrencias/detail_page.dart`, linha 63:

```dart
final ncDetailProvider = FutureProvider.family<NcDetail, String>((ref, id) {
  return ref.read(ncRepositoryProvider).buscarPorId(id);
```

- [ ] **Step 2: Renomear os 8 usos restantes no mesmo arquivo**

Run:
```bash
cd /home/mag/Documents/mobile/engseg-mobile
sed -i 's/_ncDetailProvider/ncDetailProvider/g' lib/features/ocorrencias/detail_page.dart
```

- [ ] **Step 3: Confirmar que não sobrou nenhuma referência ao nome antigo**

Run: `cd /home/mag/Documents/mobile/engseg-mobile && grep -n "_ncDetailProvider" lib/features/ocorrencias/detail_page.dart`
Expected: nenhuma saída (sem matches).

- [ ] **Step 4: Verificar**

Run: `cd /home/mag/Documents/mobile/engseg-mobile && flutter analyze lib/features/ocorrencias/detail_page.dart`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
cd /home/mag/Documents/mobile/engseg-mobile
git add lib/features/ocorrencias/detail_page.dart
git commit -m "refactor: torna ncDetailProvider público (paridade com desvioDetailProvider)"
```

---

## Task 6: Tela `EditOcorrenciaPage`

**Files:**
- Create: `lib/features/ocorrencias/edit_ocorrencia_page.dart`

**Interfaces:**
- Consumes: `ncDetailProvider(id)` / `desvioDetailProvider(id)` (Task 5, já existente), `ncRepositoryProvider.atualizar()` (Task 3), `desvioRepositoryProvider.atualizar()` (Task 4), `NcDetail`/`DesvioDetail` com os campos das Tasks 1-2, `CriarNcRequest`/`CriarDesvioRequest`, `usuariosProvider(estabelecimentoId)`, `usuariosPorEmpresaProvider(empresaId)`, `localizacoesProvider(estabelecimentoId)`, `normasProvider`, `UsuarioSummary`, `Localizacao`, `Norma`.
- Produces: `EditOcorrenciaPage({required String tipo, required String id})` — `tipo` é `'nc'` ou `'desvio'`. Consumida pelas rotas da Task 7.

- [ ] **Step 1: Criar o arquivo completo**

```dart
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
```

- [ ] **Step 2: Verificar**

Run: `cd /home/mag/Documents/mobile/engseg-mobile && flutter analyze lib/features/ocorrencias/edit_ocorrencia_page.dart`
Expected: nenhum erro. O projeto tem `prefer_const_constructors: true` habilitado
(`analysis_options.yaml`) — se o `analyze` apontar sugestões `info` desse tipo em
construtores que ficaram sem `const`, adicionar o `const` indicado; são avisos
mecânicos, não bloqueiam a task, só precisam ser corrigidos antes do commit.

Se aparecer erro sobre `firstOrNull` não encontrado, adicionar `import 'package:collection/collection.dart';` ao topo do arquivo (o pacote `collection` já é dependência transitiva do Flutter SDK/Riverpod; se `flutter analyze` reclamar de pacote ausente, adicionar `collection: ^1.18.0` em `pubspec.yaml` e rodar `flutter pub get`).

- [ ] **Step 3: Commit**

```bash
cd /home/mag/Documents/mobile/engseg-mobile
git add lib/features/ocorrencias/edit_ocorrencia_page.dart pubspec.yaml pubspec.lock 2>/dev/null
git commit -m "feat: tela de edição de NC/Desvio (edit_ocorrencia_page.dart)"
```

---

## Task 7: Rotas de edição

**Files:**
- Modify: `lib/core/router/app_router.dart`

**Interfaces:**
- Consumes: `EditOcorrenciaPage` (Task 6).
- Produces: rotas `/oc/:id/editar` e `/desvio/:id/editar`.

- [ ] **Step 1: Importar a tela nova**

Em `lib/core/router/app_router.dart`, adicionar ao bloco de imports (depois da linha 15, `desvio_detail_page.dart`):

```dart
import '../../features/ocorrencias/edit_ocorrencia_page.dart';
```

- [ ] **Step 2: Adicionar as duas rotas**

Logo após o `GoRoute` de `/desvio/:id` (linhas 95-101), antes de `/drafts`:

```dart
      GoRoute(
        path: '/oc/:id/editar',
        builder: (_, state) => EditOcorrenciaPage(tipo: 'nc', id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/desvio/:id/editar',
        builder: (_, state) => EditOcorrenciaPage(tipo: 'desvio', id: state.pathParameters['id']!),
      ),
```

- [ ] **Step 3: Verificar**

Run: `cd /home/mag/Documents/mobile/engseg-mobile && flutter analyze lib/core/router/app_router.dart`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
cd /home/mag/Documents/mobile/engseg-mobile
git add lib/core/router/app_router.dart
git commit -m "feat: rotas /oc/:id/editar e /desvio/:id/editar"
```

---

## Task 8: Wiring em `detail_page.dart` (NC)

**Files:**
- Modify: `lib/features/ocorrencias/detail_page.dart`

**Interfaces:**
- Consumes: rota `/oc/:id/editar` (Task 7).
- Produces: `_DetailHero` passa a receber `podeEditar` (`bool`) e `onEditar` (`VoidCallback`); menu "⋮" abre bottom sheet com opção "Editar"; dialog de campos faltantes ganha botão "Editar".

- [ ] **Step 1: Calcular `podeEditar` em `DetailPage.build` e repassar para `_DetailHero`**

Em `lib/features/ocorrencias/detail_page.dart`, dentro de `DetailPage.build`, no branch `data: (nc) { ... }` (linha ~105-147), adicionar o cálculo logo após `final concluida = ...;` e passar para `_DetailHero`:

```dart
      data: (nc) {
        final risco = nc.nivelRisco.toUpperCase();
        final tone = risco == 'CRITICO'
            ? 'red'
            : risco == 'ALTO'
                ? 'red'
                : risco == 'MEDIO'
                    ? 'yellow'
                    : 'blue';
        final concluida = nc.status == 'CONCLUIDA' || nc.status == 'FECHADA';
        final user = ref.watch(authProvider).valueOrNull;
        final isAberta = nc.status.toUpperCase() == 'ABERTA';
        final isCriador = user != null &&
            (user.id == nc.usuarioCriacaoId || user.email == nc.usuarioCriacaoEmail);
        final podeEditar = user != null && (isAberta ? (isCriador || user.isAdmin) : user.isAdmin);

        return DefaultTabController(
          length: 5,
          child: Scaffold(
            backgroundColor: _NcDetailColors.bg,
            body: SafeArea(
              top: true,
              bottom: false,
              child: Column(
                children: [
                  Hero(
                    tag: 'cover-${nc.id}',
                    child: _DetailHero(
                      nc: nc,
                      tone: tone,
                      podeEditar: podeEditar,
                      onEditar: () => context.push('/oc/${nc.id}/editar'),
                    ),
                  ),
                  _DetailTabs(),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _GeralTab(nc: nc),
                        _EvidenciasTab(ncId: nc.id),
                        _PlanoTab(nc: nc, concluida: concluida),
                        _ExecucaoTab(nc: nc),
                        _HistoricoTab(nc: nc),
                      ],
                    ),
                  ),
                  _DetailActions(nc: nc, user: ref.watch(authProvider).valueOrNull),
                ],
              ),
            ),
          ),
        );
      },
```

- [ ] **Step 2: Atualizar `_DetailHero` para receber os novos parâmetros e abrir o menu**

Substituir a classe `_DetailHero` inteira (linhas ~152-211) por:

```dart
class _DetailHero extends StatelessWidget {
  final NcDetail nc;
  final String tone;
  final bool podeEditar;
  final VoidCallback onEditar;

  const _DetailHero({
    required this.nc,
    required this.tone,
    required this.podeEditar,
    required this.onEditar,
  });

  void _showMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _NcDetailColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (podeEditar)
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: _NcDetailColors.blue),
                title: const Text('Editar', style: TextStyle(color: _NcDetailColors.text, fontWeight: FontWeight.w700)),
                onTap: () {
                  Navigator.pop(context);
                  onEditar();
                },
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('Nenhuma ação disponível', style: TextStyle(color: _NcDetailColors.muted, fontSize: 13)),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 22),
      decoration: const BoxDecoration(
        color: _NcDetailColors.hero,
        border: Border(bottom: BorderSide(color: _NcDetailColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _HeroIconButton(icon: Icons.chevron_left_rounded, onTap: () => context.pop()),
              const Spacer(),
              _HeroIconButton(icon: Icons.share_rounded, onTap: () {}),
              const SizedBox(width: 8),
              _HeroIconButton(icon: Icons.more_vert_rounded, onTap: () => _showMenu(context)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              const StatusPill(label: 'NC', tone: 'red', mini: true),
              StatusPill(label: nc.status, tone: tone, mini: true),
              if (nc.vencida) const StatusPill(label: 'Vencida', tone: 'red', mini: true),
              if (nc.regraDeOuro) const StatusPill(label: 'Regra de Ouro', tone: 'red', mini: true),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            nc.titulo,
            style: const TextStyle(color: _NcDetailColors.text, fontSize: 22, fontWeight: FontWeight.w900, height: 1.08),
            // ignore: deprecated_member_use
            textScaler: TextScaler.noScaling,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _HeroMeta(icon: Icons.tag_rounded, label: nc.id),
              _HeroMeta(icon: Icons.place_outlined, label: nc.estabelecimentoNome),
              if (nc.localizacaoNome != null)
                _HeroMeta(icon: Icons.map_outlined, label: nc.localizacaoNome!),
            ],
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Adicionar botão "Editar" ao dialog de campos faltantes**

Em `_DetailActions._onEnviarPlano` (linhas 1947-1966), trocar:

```dart
    final faltantes = camposFaltantesNc(nc);
    if (faltantes.isNotEmpty) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF151A21),
          title: const Text('Faltam campos obrigatórios', style: TextStyle(color: _NcDetailColors.text)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: faltantes
                .map((codigo) => Text('• ${camposObrigatoriosLabels[codigo] ?? codigo}', style: const TextStyle(color: _NcDetailColors.muted, fontSize: 13, height: 1.5)))
                .toList(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar', style: TextStyle(color: _NcDetailColors.muted))),
          ],
        ),
      );
```

por:

```dart
    final faltantes = camposFaltantesNc(nc);
    if (faltantes.isNotEmpty) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: const Color(0xFF151A21),
          title: const Text('Faltam campos obrigatórios', style: TextStyle(color: _NcDetailColors.text)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: faltantes
                .map((codigo) => Text('• ${camposObrigatoriosLabels[codigo] ?? codigo}', style: const TextStyle(color: _NcDetailColors.muted, fontSize: 13, height: 1.5)))
                .toList(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Fechar', style: TextStyle(color: _NcDetailColors.muted))),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                dialogContext.push('/oc/${nc.id}/editar');
              },
              child: const Text('Editar'),
            ),
          ],
        ),
      );
```

(`nc` continua acessível como campo de `_DetailActions`; só o parâmetro do `builder` do dialog foi renomeado de `_` para `dialogContext` para poder chamar `.push`.)

- [ ] **Step 4: Verificar**

Run: `cd /home/mag/Documents/mobile/engseg-mobile && flutter analyze lib/features/ocorrencias/detail_page.dart`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
cd /home/mag/Documents/mobile/engseg-mobile
git add lib/features/ocorrencias/detail_page.dart
git commit -m "feat: liga menu de editar e botão Editar do dialog na tela de detalhe da NC"
```

---

## Task 9: Wiring em `desvio_detail_page.dart`

**Files:**
- Modify: `lib/features/ocorrencias/desvio_detail_page.dart`

**Interfaces:**
- Consumes: rota `/desvio/:id/editar` (Task 7).
- Produces: `AppBar` com ícone de editar (gated), botão "Editar" no dialog de campos faltantes.

- [ ] **Step 1: Adicionar `IconButton` de editar ao `AppBar`**

Em `DesvioDetailPage.build` (linhas 157-183), computar o gate e adicionar `actions`:

```dart
class DesvioDetailPage extends ConsumerWidget {
  final String id;
  const DesvioDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(desvioDetailProvider(id));
    final session = ref.watch(authProvider).valueOrNull;
    return Scaffold(
      backgroundColor: ProtoColors.bg,
      appBar: AppBar(
        backgroundColor: ProtoColors.bg,
        foregroundColor: ProtoColors.text,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/desvios'),
        ),
        title: const Text('Desvio'),
        actions: [
          async.maybeWhen(
            data: (d) {
              final isAberto = d.status.toUpperCase() == 'ABERTO';
              final isCriador = session != null && session.email == d.usuarioCriacaoEmail;
              final podeEditar = session != null && (isAberto ? (isCriador || session.isAdmin) : session.isAdmin);
              if (!podeEditar) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push('/desvio/${d.id}/editar'),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Erro: $e', style: const TextStyle(color: ProtoColors.red)),
        ),
        data: (d) => _Body(d: d),
      ),
    );
  }
}
```

- [ ] **Step 2: Adicionar botão "Editar" ao dialog de campos faltantes**

Em `_BodyState._confirmarOuAvisarFaltantes` (linhas 523-545), trocar:

```dart
  Future<void> _confirmarOuAvisarFaltantes(BuildContext context) async {
    final faltantes = camposFaltantesDesvio(d);
    if (faltantes.isNotEmpty) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Faltam campos obrigatórios'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: faltantes
                .map((codigo) => Text('• ${camposObrigatoriosLabels[codigo] ?? codigo}'))
                .toList(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
          ],
        ),
      );
      return;
    }
    await _run(() => ref.read(desvioRepositoryProvider).abrirTratativa(d.id));
  }
```

por:

```dart
  Future<void> _confirmarOuAvisarFaltantes(BuildContext context) async {
    final faltantes = camposFaltantesDesvio(d);
    if (faltantes.isNotEmpty) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Faltam campos obrigatórios'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: faltantes
                .map((codigo) => Text('• ${camposObrigatoriosLabels[codigo] ?? codigo}'))
                .toList(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Fechar')),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                dialogContext.push('/desvio/${d.id}/editar');
              },
              child: const Text('Editar'),
            ),
          ],
        ),
      );
      return;
    }
    await _run(() => ref.read(desvioRepositoryProvider).abrirTratativa(d.id));
  }
```

(`dialogContext.push` funciona porque `context` faz parte da árvore de widgets montada — `GoRouter`/`go_router` resolve o `push` a partir de qualquer `BuildContext` descendente do `MaterialApp.router`, não precisa ser especificamente o `context` do `build` externo.)

- [ ] **Step 3: Verificar**

Run: `cd /home/mag/Documents/mobile/engseg-mobile && flutter analyze lib/features/ocorrencias/desvio_detail_page.dart`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
cd /home/mag/Documents/mobile/engseg-mobile
git add lib/features/ocorrencias/desvio_detail_page.dart
git commit -m "feat: liga ícone de editar e botão Editar do dialog na tela de detalhe do Desvio"
```

---

## Task 10: Verificação manual no dispositivo

**Files:** nenhum (só verificação).

- [ ] **Step 1: Analyze completo do projeto**

Run: `cd /home/mag/Documents/mobile/engseg-mobile && flutter analyze`
Expected: `No issues found!` (ou apenas apontamentos pré-existentes não relacionados a este plano — conferir contra `git stash` se aparecer algo suspeito).

- [ ] **Step 2: Rodar no Redmi Note 7**

Run: `cd /home/mag/Documents/mobile/engseg-mobile && flutter run -d f868b62` (background; ver saída até `Flutter run key commands.` aparecer, indicando app instalado e rodando).

- [ ] **Step 3: Capturar tela do detalhe de uma NC aberta**

Run: `adb exec-out screencap -p > /tmp/claude-1000/-home-mag-Documents-Obsidian-EngSeg/38849c1d-64a8-4bc5-b290-34d539c7942d/scratchpad/edit-nc-detail.png`
Ler o PNG (`Read`) e confirmar visualmente: ícone "⋮" abre bottom sheet com "Editar" (se a NC pertencer ao usuário logado e estiver ABERTA).

- [ ] **Step 4: Testar o fluxo de edição completo**

Tocar em "Editar", alterar um campo (ex.: descrição), tocar em "Salvar". Capturar nova screencap do detalhe após o `pop()` automático e confirmar visualmente que o campo alterado aparece atualizado **sem precisar de refresh manual** — este é o mesmo bug de cache que foi corrigido no web (`ncDetailProvider`/`desvioDetailProvider` precisam estar invalidados corretamente, Task 6 já faz isso).

- [ ] **Step 5: Repetir rapidamente para um Desvio**

Abrir um Desvio aberto, confirmar o ícone de editar no `AppBar`, editar e salvar, confirmar atualização sem refresh.

- [ ] **Step 6: Testar o dialog de campos faltantes**

Abrir uma NC/Desvio com campos obrigatórios faltando, tocar em "Enviar para Plano de Ação"/"Enviar para Tratativa", confirmar que o dialog mostra o botão "Editar" e que ele navega para a tela de edição.

Nenhum commit nesta task — é só verificação. Se algo falhar, voltar à task correspondente, corrigir, e repetir a verificação.
