import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/login_response.dart';
import '../model/workspace_state.dart';
import '../repository/auth_repository_impl.dart';
import '../../../core/notifications/fcm_provider.dart';
import '../../../core/network/auth_reset.dart';
import '../../../core/database/app_database.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, LoginResponse?>(
  AuthNotifier.new,
);

final workspaceProvider = StateProvider<WorkspaceState?>((ref) => null);

class AuthNotifier extends AsyncNotifier<LoginResponse?> {
  @override
  Future<LoginResponse?> build() async {
    registerForceLogoutCallback(() => state = const AsyncData(null));
    final session = await ref.read(authRepositoryProvider).getSession();
    if (session != null && ref.read(workspaceProvider) == null) {
      final workspace = await ref.read(authRepositoryProvider).obterWorkspace();
      if (workspace != null) {
        ref.read(workspaceProvider.notifier).state = workspace;
      }
    }
    return session;
  }

  Future<void> login(String email, String senha) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).login(email, senha),
    );
    if (state.hasValue && state.value != null) {
      await ref.read(fcmServiceProvider).init(state.value!.id);
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    await ref.read(appDatabaseProvider).ocorrenciasCacheDao.limparTudo();
    ref.read(workspaceProvider.notifier).state = null;
    state = const AsyncData(null);
  }
}
