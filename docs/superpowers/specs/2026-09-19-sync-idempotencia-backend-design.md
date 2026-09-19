# Idempotência do sync de NC/Desvio (backend)

Spec 1 de 2 do projeto "modo offline no mobile" (ver também
`2026-09-19-offline-mobile-design.md`, que depende desta). Esta spec não
depende da outra e pode ser implementada e entregue sozinha.

## Contexto

Cadeia atual de sincronização em lote, já existente e funcional, mas nunca
exercitada em produção porque nada no app mobile grava rascunhos hoje:

`safecore-mobile` (app) → `POST /sync` (`SyncBatchController`, porta do
mobile-backend) → `SyncForwardingService.encaminhar` (repassa via
`RestTemplate`, mesmo header `Authorization`) → `safecore-api`
`POST /api/sync/ocorrencias` (`SyncController`) → `SyncService.processar`.

```java
// safecore-api: SyncService.java
public SyncBatchResponse processar(SyncBatchRequest batch) {
    List<SyncItemResult> results = new ArrayList<>();
    for (SyncItemRequest item : batch.items()) {
        results.add(processarItem(item));
    }
    return new SyncBatchResponse(results);
}

private SyncItemResult processarItem(SyncItemRequest item) {
    try {
        UUID serverId = switch (item.tipo()) {
            case "NC" -> ncService.create(item.nc()).id();
            case "DESVIO" -> desvioService.create(item.desvio()).id();
            default -> throw new IllegalArgumentException(...);
        };
        return new SyncItemResult(item.localId(), serverId, "CRIADO", null);
    } catch (Exception e) {
        return new SyncItemResult(item.localId(), null, "ERRO", e.getMessage());
    }
}
```

**Problema:** não há checagem de `localId` já processado. Reenviar o mesmo
batch — timeout de rede na resposta, app fechado no meio, usuário tocando
"sincronizar tudo" duas vezes — cria uma NC/Desvio duplicada a cada reenvio.
Isso deixa de ser um risco teórico quando a Spec 2 liga a fila real de
sincronização no mobile.

O formato de erro por item (`SyncItemResult(localId, serverId, status,
erro)`) já é suficiente para a Spec 2 tratar erro granular — não precisa de
mudança aqui.

## Mudanças

### 1. Migration V59 — tabela de idempotência

Última migration hoje é `V58__rename_seed_to_safecore.sql`.

```sql
-- V59__criar_sync_idempotencia.sql
CREATE TABLE sync_idempotencia (
    local_id   VARCHAR(64) PRIMARY KEY,  -- SyncItemRequest.localId() já é String, não UUID
    tipo       VARCHAR(10) NOT NULL,     -- 'NC' ou 'DESVIO'
    server_id  UUID NOT NULL,
    criado_em  TIMESTAMP NOT NULL DEFAULT now()
);
```

Confirmado em `SyncItemRequest`/`SyncItemResult` (`dto/request`, `dto/response`):
`localId` já é `String` no contrato atual — a coluna acompanha esse tipo em
vez de forçar um cast para `UUID` no meio do processamento. A Spec 2 ainda
deve gerar um UUID de verdade do lado mobile (boa prática, evita colisão),
mas o backend não precisa validar/parsear isso — trata como string opaca.

Tabela separada em vez de coluna `local_id` em `nao_conformidade`/`desvio`:
evita alterar duas tabelas de domínio por causa de um detalhe de
transporte, e a consulta de idempotência é sempre por `local_id` sozinho.

### 2. `SyncService` — checar antes de criar, tudo na mesma transação

```java
@Transactional  // move para o nível do item, não do batch
private SyncItemResult processarItem(SyncItemRequest item) {
    try {
        var existente = syncIdempotenciaRepository.findById(item.localId());
        if (existente.isPresent()) {
            return new SyncItemResult(item.localId(), existente.get().getServerId(), "CRIADO", null);
        }

        UUID serverId = switch (item.tipo()) {
            case "NC" -> ncService.create(item.nc()).id();
            case "DESVIO" -> desvioService.create(item.desvio()).id();
            default -> throw new IllegalArgumentException("tipo desconhecido: " + item.tipo());
        };

        syncIdempotenciaRepository.save(new SyncIdempotencia(item.localId(), item.tipo(), serverId));
        return new SyncItemResult(item.localId(), serverId, "CRIADO", null);
    } catch (Exception e) {
        log.warn(...);
        return new SyncItemResult(item.localId(), null, "ERRO", e.getMessage());
    }
}
```

Ponto que importa: `@Transactional` precisa estar no método que faz o
check-then-create-then-insert (`processarItem`, não `processar`), senão um
crash entre `create()` e o insert em `sync_idempotencia` reintroduz
exatamente a duplicata que esta spec resolve. `NaoConformidadeService.create`
já é `@Transactional` (propagação `REQUIRED` por padrão) — ao ser chamado de
dentro de `processarItem` também transacional, ele só entra na mesma
transação, não abre uma nova. Isso também preserva o isolamento por item que
já existe hoje (um item com erro não derruba os outros do batch).

### 3. Pré-requisito do lado mobile

`item.localId()` deve ser um UUID real gerado pelo app (não um id
sequencial) — vira chave primária de `sync_idempotencia`, e um UUID evita
colisão entre rascunhos de dispositivos diferentes. O backend não valida o
formato (coluna é `VARCHAR`, aceita qualquer string não-nula), mas o
contrato esperado é UUID. Gerar isso é responsabilidade da Spec 2
(dependência `uuid` no `pubspec.yaml`), citado aqui só para deixar o
contrato explícito entre as duas specs.

### 4. `@Valid` faltando na cascata de `SyncItemRequest`

Achado ao planejar a Spec 2: `SyncItemRequest.nc`/`.desvio` não têm `@Valid`,
então os `@NotNull` de `NaoConformidadeRequest`/`DesvioRequest`
(`localizacaoId`, `empresaContratadaId` etc.) não são validados quando o
payload chega via `/sync/batch` — só são validados no
`POST /api/nao-conformidades` direto. Hoje isso é inofensivo (nada grava
rascunho). Com a Spec 2, o sync vira o caminho primário de criação offline,
e um payload nulo nesse ponto não cai mais num 400 limpo — cai dentro de
`NaoConformidadeService.create()` (ex: `empresaRepository.findById(null)`),
e a exceção crua vira `SyncItemResult.erro`, exibida na tela do usuário.

```java
// SyncItemRequest.java
public record SyncItemRequest(
        String localId,
        String tipo,
        @Valid NaoConformidadeRequest nc,
        @Valid DesvioRequest desvio
) {}
```

## Fora do escopo

- Nenhuma mudança nos DTOs de criação de NC/Desvio (`NaoConformidadeRequest`,
  `DesvioRequest`) nem na validação de `create()`/`ativar()`.
- Nenhuma mudança no fluxo de criação online do app mobile — a Spec 2 mantém
  esse caminho intocado.
- Limpeza/expiração de linhas antigas em `sync_idempotencia` — a tabela é
  pequena (uma linha por NC/Desvio já sincronizada) e não há necessidade de
  TTL agora.
