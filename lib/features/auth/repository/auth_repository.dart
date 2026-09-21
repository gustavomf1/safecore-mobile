import '../model/login_response.dart';
import '../model/workspace_state.dart';

abstract class AuthRepository {
  Future<LoginResponse> login(String email, String senha);
  Future<void> logout();
  Future<LoginResponse?> getSession();
  Future<void> solicitarReset(String email);
  Future<String> verificarOtp(String email, String otp);
  Future<void> redefinirSenha(String resetToken, String novaSenha);
  Future<void> salvarWorkspace(WorkspaceState workspace);
  Future<WorkspaceState?> obterWorkspace();
}
