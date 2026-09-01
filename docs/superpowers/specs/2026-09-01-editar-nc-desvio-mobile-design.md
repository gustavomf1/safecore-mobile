# Editar NC/Desvio no mobile

## Contexto

O web já tem edição completa de NC/Desvio (`RegistroOcorrenciaPage`, criar e editar no
mesmo formulário). No mobile não existe nenhuma forma de editar uma NC/Desvio já criada:

- `NcRepository`/`DesvioRepository` só têm `criar()` — não há `atualizar()`.
- Em `detail_page.dart` (NC), o ícone "⋮" no topo (`Icons.more_vert_rounded`, linha ~175)
  tem `onTap: () {}` — nunca foi implementado.
- O dialog "Faltam campos obrigatórios" (NC: `_DetailActions._onEnviarPlano`, linha ~1947;
  Desvio: `_Body`, linha ~524) só tem botão "Fechar" — no web o mesmo dialog tem "Editar".
- `desvio_detail_page.dart` não tem nenhum ícone/menu no `AppBar`.
- `WizardPage` (3213 linhas) é só criação e acoplado ao fluxo de câmera
  (`extra: fotoPath, latitude, longitude, capturedAt`) — não é reaproveitável para edição.

## Descoberta que muda o design: IDs ausentes nos models

`NcDetail`/`DesvioDetail` hoje só guardam nomes de exibição (`localizacaoNome`,
`responsavelTrativaNome`...), não os IDs necessários para reenviar no PUT. Verificado que
o backend **já envia** esses IDs na resposta (`NaoConformidadeResponse`/`DesvioResponse`:
`localizacaoId`, `empresaContratadaId`, `responsavelTrativaId`, `responsavelNcId` /
`responsavelDesvioId`, `responsavelTratativaId`) — só não são parseados no `fromJson`.
Sem isso, o formulário de edição não teria como reconstruir o payload do PUT
(`localizacaoId` e `empresaContratadaId` são `@NotNull` no backend → 400 garantido).

Também confirmado em `NaoConformidadeService.update` (linha ~261): se `normaIds` vier
como lista vazia (não nulo) no PUT, **desvincula todas as normas**. O formulário de
edição precisa pré-popular `normaIds` a partir de `nc.normas` sempre, mesmo que o
usuário não mexa nessa seção.

## Mudanças

### 1. Models — expor os IDs que já vêm da API

- `lib/features/ocorrencias/model/nc_detail.dart`: adicionar `localizacaoId`,
  `empresaContratadaId`, `responsavelTrativaId`, `responsavelNcId` ao `fromJson`.
- `lib/features/ocorrencias/model/desvio_detail.dart`: adicionar `localizacaoId`,
  `empresaContratadaId` ao `fromJson` (`responsavelDesvioId`/`responsavelTratativaId`
  já existem).

### 2. Repositórios — `atualizar()`

- `NcRepository`/`NcRepositoryImpl`: `Future<NcDetail> atualizar(String id, CriarNcRequest request)`
  → `PUT /api/nao-conformidades/$id` (mesmo shape de `criar`, reaproveita `CriarNcRequest.toJson()`).
- `DesvioRepository`/`DesvioRepositoryImpl`: `Future<DesvioDetail> atualizar(String id, CriarDesvioRequest request)`
  → `PUT /api/desvios/$id`.
- Severidade/probabilidade: enviar `null` quando não definidas (nunca `0` — o wizard usa
  `0` como sentinela de "não selecionado" na UI, mas o backend valida `@Min(1)`).

### 3. Tela nova `lib/features/ocorrencias/edit_ocorrencia_page.dart`

Self-contained, não mexe no `wizard_page.dart`. Recebe `tipo` (`'nc'`/`'desvio'`) e `id`,
busca o detalhe existente (reaproveita os providers já usados pelo detail), pré-popula:

- Comuns: título, descrição, localização (dropdown do estabelecimento já conhecido).
- NC: matriz de risco (severidade/probabilidade — recriar o picker localmente na tela
  nova em vez de extrair do `WizardPage`; é um widget pequeno, não vale o blast radius
  de mexer no arquivo de 3213 linhas), seleção de normas (checkboxes, pré-marcadas a
  partir de `nc.normas`), responsável pela tratativa, responsável pela NC.
- Desvio: orientação realizada, responsável pelo desvio, responsável pela tratativa.
- Regra de ouro (ambos).

Ao salvar: chama `atualizar()`, invalida o provider Riverpod do detail
(`_ncDetailProvider(id)` / `desvioDetailProvider(id)`) e faz `context.pop()`.

Estilo: usar o tema escuro do `detail_page.dart`/`wizard_page.dart` (mais atual), não o
`ProtoColors` legado do `desvio_detail_page.dart`.

### 4. Wiring de navegação + permissão

Gate idêntico ao `_isCriador` já existente (`user!.id == nc.usuarioCriacaoId ||
user!.email == nc.usuarioCriacaoEmail`) combinado com `isAdmin` e status aberto — mesma
regra do web (`podeEditarExcluir = isAberto ? (isCriador || isAdmin) : isAdmin`).

- **NC** (`detail_page.dart`): `_DetailHero` passa a receber `podeEditar` (calculado em
  `DetailPage.build`, que já tem `user` via `ref.watch(authProvider)`); o ícone "⋮" abre
  um bottom sheet simples com a opção "Editar" quando `podeEditar` é true (sem opção
  quando false — não existe exclusão no mobile hoje, fora de escopo).
- **NC** dialog de campos faltantes: adicionar botão "Editar" ao lado de "Fechar",
  navegando para a tela de edição.
- **Desvio** (`desvio_detail_page.dart`): adicionar `actions: [IconButton(Icons.edit_outlined, ...)]`
  no `AppBar`, mesmo gate de permissão. Dialog de campos faltantes ganha o mesmo botão
  "Editar".
- Rota nova em `app_router.dart`: `/oc/:id/editar` e `/desvio/:id/editar`.

## Fora do escopo

- **Vínculo de trecho de norma continua sem funcionar.** `_TrechoSheet` no wizard nunca
  persistiu nada (não existe campo de trecho em `CriarNcRequest`, não existe chamada de
  API tipo `vincularTrechoNorma`, e a "busca por IA" ali é mockada). Isso é um bug
  pré-existente no fluxo de criação, não algo que a tela de edição precisa resolver.
  Selecionar/desselecionar normas inteiras funciona normalmente.
- **Reincidência (NC anterior) não entra na edição.** Não existe no mobile uma busca de
  NC anterior equivalente à do web (`buscarNcParaReincidencia`); construir isso agora
  expande o escopo desnecessariamente.
- **Exclusão de NC/Desvio** não existe no mobile hoje e não está sendo adicionada.
- Nenhuma mudança no backend (os endpoints PUT já existem e já são usados pelo web).
