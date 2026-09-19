# Modo offline no mobile (registro + visualização)

Spec 2 de 2 do projeto "modo offline no mobile" (ver também
`2026-09-19-sync-idempotencia-backend-design.md`). Esta spec depende da
Spec 1 estar implementada (precisa de `sync_idempotencia` para o botão
"sincronizar" não duplicar NC/Desvio em caso de reenvio).

## Contexto

O app já tem uma base parcial pra isso, mas **totalmente desconectada da
UI** — nada nela é exercitado hoje:

- `lib/core/database/app_database.dart`: Drift, `schemaVersion => 1`, tabelas
  `Rascunhos` (id, tipo, titulo, descricao, severidade, fotoPath *singular*,
  latitude, longitude, capturedAt, dadosJson, criadoEm, sincronizado,
  serverId) e `OcorrenciasCache` (id, tipo, dadosJson, usuarioId, cachedEm).
- `DraftRepositoryImpl._toModel` (draft_repository_impl.dart:63) devolve
  **`dadosJson: const {}` fixo** — o valor gravado nunca é lido de volta.
  Bug pré-existente, precisa ser corrigido como base de tudo o resto.
- `SyncService.syncPendentes()` já sabe montar o batch e chamar
  `POST /sync` (bffDio → mobile-backend → `safecore-api`), mas nunca é
  chamado (só have um listener morto em `main.dart:63-72`) e só cobre a
  criação — não vincula normas nem sobe fotos depois.
- `DraftsPage` (tela em Perfil, hoje "Rascunhos") é protótipo visual: botão
  "Forçar" sem `onTap`, `syncStatusProvider` nunca atualizado.
- O wizard (`wizard_page.dart`, 2847 linhas) não referencia nada disso.
  `_submit()` chama `ncRepositoryProvider.criar()`/`desvioRepositoryProvider.criar()`
  direto via Dio (`dioProvider`, aponta pro `safecore-api`), sem fallback.
- Dados de referência do wizard (`support_repository.dart`): usuários (por
  estabelecimento), localizações, normas, estabelecimentos, empresas —
  todos buscados via `FutureProvider` sem cache, toda vez.
- Leitura offline hoje existe só parcialmente: `NcRepositoryImpl.listar()`
  cai num `catch (DioException)` que lê `OcorrenciasCache`, mas grava (e
  lê) só `{titulo, status}` — o resto dos campos (`nivelRisco: 'MEDIO'`,
  `dataRegistro: ''`, `vencida: false`) é **inventado** na hora, não vem do
  cache. Além disso `usuarioId` é sempre gravado como `''`.

## Decisões (o que fica de fora e por quê)

- **Ações de workflow em NC/Desvio existentes (aprovar/rejeitar plano,
  submeter execução etc.) continuam exigindo internet.** Só a criação de
  NC/Desvio novo e a leitura de itens já existentes ficam offline.
- **Responsável (NC, tratativa, desvio) não é selecionável offline.**
  Verificado em `NaoConformidadeService`: `create()` sempre grava status
  `ABERTA`, com ou sem responsável — quem valida campo obrigatório é
  `ativar()` (chamado depois, manualmente, na tela de detalhe), que já
  bloqueia até os campos serem preenchidos. Ou seja: um rascunho sincronizado
  sem responsável vira uma NC/Desvio `ABERTA` comum, idêntica a uma criada
  incompleta hoje — **não precisa de nenhuma lógica nova** para esse caso,
  o fluxo de completar depois já existe.
- **`empresaContratadaId` precisa estar sempre resolvido offline** — ao
  contrário do que o DTO sugere (campo nullable), `NaoConformidadeService.create()`
  chama `empresaRepository.findById(request.empresaContratadaId())` sem
  checar null primeiro; é obrigatório de fato.
- **O caminho de criação online não é alterado em nenhuma linha.** A única
  adição é uma checagem de conectividade no início de `_submit()`; se
  online, o código existente roda exatamente como hoje (mesmo em caso de
  erro no meio do fluxo — isso continua sem tratamento novo, por decisão
  explícita, para não mexer em nada que já funciona).
- **Falha de sync não é resolvida automaticamente.** Ao reconectar, nada
  sincroniza sozinho — só aparece um aviso; sincronizar é sempre uma ação
  manual do usuário.

## Mudanças

### 1. Schema Drift — `schemaVersion` 1 → 2, com migration real

`engseg.sqlite` já existe em instalações que abriram o app (mesmo sem
nenhuma linha gravada em `Rascunhos`/`OcorrenciasCache` — o arquivo e as
tabelas v1 existem). Precisa de `MigrationStrategy.onUpgrade`, não dá pra
só mudar as classes de tabela.

```dart
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(rascunhos, rascunhos.usuarioId);
        await m.addColumn(rascunhos, rascunhos.status);
        await m.addColumn(rascunhos, rascunhos.erroMensagem);
        await m.addColumn(rascunhos, rascunhos.cidade);
        await m.createTable(rascunhoNormas);
        await m.createTable(rascunhoFotos);
        await m.createTable(referenceCache);
        await m.addColumn(ocorrenciasCache, ocorrenciasCache.nivel);
        // sincronizado (int) migra pra status ('sincronizado'/'pendente')
        // num passo de dados, não só de schema — ver nota abaixo.
      }
    },
  );
}
```

`sincronizado` (int 0/1) é substituído por `status` (text:
`pendente`/`sincronizando`/`erro`/`sincronizado`). Como nenhuma instalação
real tem linha gravada em `Rascunhos` até hoje (a UI nunca escreveu nela),
não existe dado de usuário para migrar — a coluna antiga pode ser
descartada (`m.dropColumn`) em vez de convertida. Confirmar isso é o
primeiro passo da implementação (checar se existe alguma build já publicada
que tenha, por acidente, gravado algo ali; se não, dropar sem medo).

Tabelas novas:

```dart
class RascunhoNormas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get rascunhoId => text().references(Rascunhos, #id)();
  TextColumn get normaId => text()();
  TextColumn get clausulaReferencia => text().nullable()();
  TextColumn get textoEditado => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('pendente'))(); // pendente|vinculado|erro
}

class RascunhoFotos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get rascunhoId => text().references(Rascunhos, #id)();
  TextColumn get path => text()();        // já copiado pro diretório persistente, ver seção 5
  IntColumn get ordem => integer()();
  TextColumn get status => text().withDefault(const Constant('pendente'))(); // pendente|enviado|erro
  TextColumn get evidenciaServerId => text().nullable()();
  TextColumn get erroMensagem => text().nullable()();
}

class ReferenceCache extends Table {
  TextColumn get chave => text()();  // 'normas' | 'localizacoes:<estabId>' | 'empresasContratadas:<estabId>'
  TextColumn get dadosJson => text()();
  IntColumn get atualizadoEm => integer()();

  @override
  Set<Column> get primaryKey => {chave};
}
```

`OcorrenciasCache` ganha coluna `nivel` (`'SUMMARY'` | `'DETAIL'`) e passa a
guardar o JSON completo da resposta (não um subconjunto de campos).

Nada é apagado no logout, **exceto `OcorrenciasCache`** (descartável, é só
espelho de leitura). `Rascunhos`/`RascunhoNormas`/`RascunhoFotos` continuam
no disco — é trabalho não sincronizado do usuário — mas toda leitura filtra
por `usuarioId` do usuário logado, então um segundo usuário no mesmo
aparelho não vê rascunho de outra conta (volta a aparecer se aquele usuário
logar de novo).

### 2. Corrigir a leitura de rascunho (bug-base)

`DraftRepositoryImpl._toModel` para de descartar `dadosJson`:

```dart
RascunhoLocal _toModel(Rascunho row) => RascunhoLocal(
      ...
      dadosJson: jsonDecode(row.dadosJson ?? '{}') as Map<String, dynamic>,
      ...
    );
```

E o campo correspondente em `RascunhoLocal`/`dadosJsonEncoded` precisa ficar
consistente (hoje há uma assimetria Map vs String entre o que é lido e o
que é escrito) — resolver como parte da mesma mudança.

### 3. Cache de dados de referência

Novo provider genérico por cima de `ReferenceCache`, usado pelos providers
existentes em `support_repository_impl.dart` (localizações, normas,
empresas contratadas — **não** usuários/responsável, que continuam sem
cache por decisão de escopo):

```dart
Future<List<T>> comCache<T>({
  required String chave,
  required Future<List<T>> Function() buscarOnline,
  required T Function(Map<String, dynamic>) fromJson,
  required bool online,
}) async {
  if (online) {
    try {
      final lista = await buscarOnline();
      await referenceCacheDao.salvar(chave, jsonEncode(lista.map((e) => e.toJson()).toList()));
      return lista;
    } on DioException {
      // cai pro cache abaixo
    }
  }
  final cached = await referenceCacheDao.buscar(chave);
  if (cached == null) return [];
  return (jsonDecode(cached.dadosJson) as List).map((e) => fromJson(e)).toList();
}
```

`online` vem de `connectivityProvider` — lido antes de decidir buscar da
rede ou ir direto pro cache, em vez de esperar o `DioException` (evita
segurar a tela pelo tempo de `connectTimeout` toda vez que o usuário abre o
wizard offline). Estabelecimento/empresa mãe **não precisam desse cache** —
já vêm fixos do workspace selecionado no login, que já está salvo local.

### 4. Cache de leitura para NC/Desvio (listas + detalhe)

- `NcRepositoryImpl.listar()`/`buscarPorId()` e os equivalentes de
  `DesvioRepositoryImpl`: mesma estratégia "online tenta e atualiza cache;
  offline lê cache direto" da seção 3, usando `OcorrenciasCache` com
  `nivel: 'SUMMARY'` (lista) e `nivel: 'DETAIL'` (detalhe), guardando o JSON
  completo, com `usuarioId` real (não mais `''`).
- Isso também vira a fonte da lista de "NC anterior" pro campo de
  reincidência do wizard — hoje precisaria buscar uma lista separada do
  servidor; reaproveitando o cache de `SUMMARY` já cobre isso sem tabela
  nova.
- Evidências (fotos) na tela de detalhe: nenhum cache próprio — usa
  `cached_network_image`, que já é dependência e já cacheia em disco
  automaticamente qualquer imagem que já tenha sido carregada uma vez
  online.

### 5. Wizard — só uma guarda no início de `_submit()`

```dart
Future<void> _submit() async {
  final online = ref.read(connectivityProvider).value ?? true;
  if (!online) {
    await _salvarRascunhoOffline(); // função nova, isolada
    if (mounted) context.go('/sincronizacao');
    return;
  }

  // --- tudo abaixo é o código que já existe hoje, sem alteração ---
  final nc = await ref.read(ncRepositoryProvider).criar(request);
  ...
}
```

`_salvarRascunhoOffline()`:

- Gera `id` local com `uuid` (pacote novo, ver seção 8) — precisa ser um
  UUID de verdade porque vira `local_id` (chave primária) em
  `sync_idempotencia` no backend (Spec 1).
- Grava o `CriarNcRequest`/`CriarDesvioRequest` inteiro como `dadosJson`.
- Persiste `latitude`/`longitude`/`capturedAt` (já existem na tabela) e
  **não** resolve `cidade` agora — fica `null`; é resolvida na hora da
  sincronização (precisa de rede, `geocoding` não funciona offline).
  `EvidenciaMetadata` hoje vem de `widget.extra`, argumento de rota efêmero;
  passa a ser reconstruída a partir dessas colunas na hora do upload.
- Copia cada foto de `captureProvider` do diretório de cache do
  `image_picker` (evictável pelo SO) pro diretório de documentos da app
  (`path_provider`, já é dependência): `<appDocs>/rascunhos/<rascunhoId>/foto_N.jpg`.
  Grava uma linha em `RascunhoFotos` por foto, com esse path novo.
- Grava uma linha em `RascunhoNormas` por trecho de norma selecionado
  (`_normaTrechos`), status `pendente`.
- `Rascunhos.status = 'pendente'`, sem `serverId`.

### 6. Motor de sincronização manual

`SyncService` (hoje só chama `/sync` e para) passa a, por item:

1. Se `serverId == null`: chama `/sync` com o item (como já faz), grava
   `serverId` retornado e `status = 'sincronizado'` **provisório** (ajustado
   no passo seguinte se sobrar pendência).
2. Resolve `cidade` via `geocoding` se ainda `null` e atualiza a NC/Desvio
   (reaproveita o mesmo endpoint de `atualizar()` que a edição já usa) —
   melhor esforço, não bloqueia o resto se falhar.
3. Para cada `RascunhoNormas` com `status = 'pendente'` daquele rascunho:
   chama `trechoRepo.vincular()` (mesma chamada que o caminho online já
   usa); sucesso marca `vinculado`, falha marca `erro` mas não interrompe
   os outros.
4. Para cada `RascunhoFotos` com `status = 'pendente'`: chama
   `uploadParaNc`/`uploadParaDesvio` (mesmo repositório existente); sucesso
   grava `evidenciaServerId` e marca `enviado`.
5. `Rascunhos.status` final: `'sincronizado'` só se **todas** as normas e
   fotos daquele rascunho terminaram `vinculado`/`enviado`; senão `'erro'`,
   com `erroMensagem` resumindo o que faltou (ex: "NC criada, 1 de 2 fotos
   não subiu"). `serverId` já preenchido nesse ponto, então tocar
   "sincronizar" de novo **não recria a NC** — só repete os passos 2-4 para
   o que ainda está `pendente`/`erro`.

Chamado por: botão "Sincronizar" (por item) e "Sincronizar tudo" na tela da
seção 7. Nunca é chamado automaticamente ao reconectar.

### 7. Tela "Sincronização" (era "Rascunhos")

Reaproveita `drafts_page.dart` (renomeado), trocando o texto/ícone da aba em
Perfil de "Rascunhos" para "Sincronização". Lista tudo com
`status != 'sincronizado'`, ordenado por `criadoEm`:

- Pill de tipo (NC/Desvio) + status (`Pendente`/`Sincronizando`/`Erro`,
  cores já usadas em `_DraftCard`).
- Se `status == 'erro'`: mostra `erroMensagem`.
- Ações por item: **Sincronizar** (desabilitado se offline) e **Excluir**
  (reaproveita `ConfirmActionModal`, mesmo padrão já usado em outras 6
  telas) — excluir remove `Rascunhos`+`RascunhoNormas`+`RascunhoFotos`
  (incluindo os arquivos de foto em disco) sem chamar o servidor; se já
  tinha `serverId` parcial, a NC/Desvio já criada no servidor **não** é
  apagada (fora de escopo — não existe exclusão de NC/Desvio no mobile
  hoje, confirmado na spec de edição de 2026-09-01).
- Botão "Sincronizar tudo" no topo, desabilitado se offline.

### 8. Notificação global de itens pendentes

Widget novo (`PendingSyncBanner`), montado no shell que envolve as abas
inferiores (NCs/Desvios/Avisos/Perfil) — **não** na tela de seleção de
workspace nem na de login, que ficam fora desse shell.

- Provider: combina `connectivityProvider` (online) com uma contagem de
  `Rascunhos` com `status IN ('pendente', 'erro')` para o `usuarioId` atual.
- Mostra quando `online && count > 0`: "Você tem N itens para sincronizar" +
  botão "Ver" → `context.go('/sincronizacao')`.
- Reaparece a cada transição offline→online enquanto existir pendência
  (estado vive no shell, então persiste ao trocar de aba sem re-disparar a
  cada navegação).

### 9. Dependências novas

`pubspec.yaml`: `uuid: ^4.5.1` (gerar `local_id` real para os rascunhos —
hoje não existe nenhum gerador de UUID no projeto).

## Fora do escopo

- Seleção de responsável offline (fica sempre para o fluxo online normal,
  via `ativar()`/edição).
- Ações de workflow (aprovar/rejeitar plano, submeter execução, revisar
  atividades/execução) em NC/Desvio existentes — continuam exigindo
  internet, nenhuma mudança nelas.
- Qualquer alteração no caminho de criação online (`_submit` quando
  `online == true`, `criar()`, `vincular()`, `_uploadPhotos()`) — decisão
  explícita do usuário, tratado só como uma guarda no início da função.
- Recuperação automática de falha parcial quando a conexão cai *durante* o
  fluxo online (NC criada mas normas/fotos não subiram) — continua se
  comportando como hoje, sem tratamento novo.
- Sincronização automática ao reconectar — sempre manual, só a notificação
  é automática.
- Resolução de conflito multi-dispositivo (mesmo usuário logado em dois
  aparelhos) — fora de escopo, não é um cenário tratado hoje em nenhuma
  outra parte do app.
