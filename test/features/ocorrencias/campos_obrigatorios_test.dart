import 'package:flutter_test/flutter_test.dart';
import 'package:safecore_mobile/features/ocorrencias/campos_obrigatorios.dart';
import 'package:safecore_mobile/features/ocorrencias/model/nc_detail.dart';
import 'package:safecore_mobile/features/ocorrencias/model/desvio_detail.dart';

void main() {
  test('camposFaltantesNc retorna todos os codigos quando nada preenchido', () {
    final nc = const NcDetail(
      id: '1',
      titulo: 'T',
      status: 'ABERTA',
      nivelRisco: 'BAIXO',
      regraDeOuro: false,
      reincidencia: false,
      estabelecimentoId: 'e1',
      estabelecimentoNome: 'Est',
      usuarioCriacaoNome: 'U',
      dataRegistro: '2026-01-01',
    );

    expect(
      camposFaltantesNc(nc),
      containsAll(['MATRIZ_RISCO', 'RESPONSAVEL_TRATATIVA', 'RESPONSAVEL_NC', 'NORMA_VINCULADA', 'DESCRICAO']),
    );
  });

  test('camposFaltantesNc retorna lista vazia quando tudo preenchido', () {
    final nc = const NcDetail(
      id: '1',
      titulo: 'T',
      descricao: 'D',
      status: 'ABERTA',
      nivelRisco: 'BAIXO',
      severidade: 2,
      probabilidade: 2,
      regraDeOuro: false,
      reincidencia: false,
      estabelecimentoId: 'e1',
      estabelecimentoNome: 'Est',
      usuarioCriacaoNome: 'U',
      dataRegistro: '2026-01-01',
      responsavelTrativaNome: 'R1',
      responsavelNcNome: 'R2',
      normas: [
        {'id': 'n1'},
      ],
    );

    expect(camposFaltantesNc(nc), isEmpty);
  });

  test('camposFaltantesDesvio retorna todos os codigos quando nada preenchido', () {
    final d = const DesvioDetail(
      id: '1',
      titulo: 'T',
      status: 'ABERTO',
      estabelecimentoId: 'e1',
      estabelecimentoNome: 'Est',
      regraDeOuro: false,
      dataRegistro: '2026-01-01',
      tratativas: [],
      historico: [],
    );

    expect(
      camposFaltantesDesvio(d),
      containsAll(['DESCRICAO', 'ORIENTACAO_REALIZADA', 'RESPONSAVEL_DESVIO', 'RESPONSAVEL_TRATATIVA']),
    );
  });

  test('camposFaltantesDesvio retorna lista vazia quando tudo preenchido', () {
    final d = const DesvioDetail(
      id: '1',
      titulo: 'T',
      status: 'ABERTO',
      estabelecimentoId: 'e1',
      estabelecimentoNome: 'Est',
      descricao: 'D',
      orientacaoRealizada: 'O',
      responsavelDesvioId: 'r1',
      responsavelTratativaId: 'r2',
      regraDeOuro: false,
      dataRegistro: '2026-01-01',
      tratativas: [],
      historico: [],
    );

    expect(camposFaltantesDesvio(d), isEmpty);
  });
}
