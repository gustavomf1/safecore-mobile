import 'package:dio/dio.dart';

const _semConexao = 'Sem conexão com a internet. Verifique sua conexão e tente novamente.';
const _generico = 'Não foi possível carregar. Tente novamente em instantes.';

/// Mensagem amigável pra exibir em telas de erro, no lugar do texto cru da
/// exceção (ex: "DioException [connection error]: Failed host lookup...").
String friendlyErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return _semConexao;
      default:
        return _generico;
    }
  }
  return _generico;
}
