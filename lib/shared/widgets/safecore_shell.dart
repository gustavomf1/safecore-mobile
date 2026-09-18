import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/provider/auth_provider.dart';
import '../../features/notifications/notif_page.dart';
import '../../features/ocorrencias/desvio_feed_page.dart';
import '../../features/ocorrencias/feed_page.dart';
import '../../features/profile/profile_page.dart';
import '../theme/tokens.dart';
import 'prototype_ui.dart';

const _tabPaths = ['/feed', '/desvios', '/notif', '/profile'];

class SafeCoreShell extends ConsumerStatefulWidget {
  final Widget child;

  const SafeCoreShell({super.key, required this.child});

  @override
  ConsumerState<SafeCoreShell> createState() => _SafeCoreShellState();
}

class _SafeCoreShellState extends ConsumerState<SafeCoreShell> {
  final _tabs = const [FeedPage(), DesvioFeedPage(), NotifPage(), ProfilePage()];

  PageController? _pageController;
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).uri.path;
    final tabIndex = _tabPaths.indexOf(location);
    if (tabIndex == -1 || tabIndex == _currentIndex) return;
    _currentIndex = tabIndex;
    final controller = _pageController;
    if (controller != null && controller.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && controller.hasClients) controller.jumpToPage(tabIndex);
      });
    }
  }

  void _onTabTapped(int index) {
    final controller = _pageController;
    if (controller != null && controller.hasClients) {
      controller.animateToPage(
        index,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    } else {
      context.go(_tabPaths[index]);
    }
  }

  void _onPageChanged(int index) {
    _currentIndex = index;
    final target = _tabPaths[index];
    if (GoRouterState.of(context).uri.path != target) context.go(target);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final perfil = ref.watch(authProvider).valueOrNull?.perfil;
    final isExterno = perfil == 'EXTERNO';
    final location = GoRouterState.of(context).uri.path;
    final isTabRoute = _tabPaths.contains(location);

    final body = isTabRoute
        ? PageView(
            controller: _pageController ??= PageController(initialPage: _currentIndex),
            onPageChanged: _onPageChanged,
            children: _tabs,
          )
        : widget.child;

    return Scaffold(
      backgroundColor: c.bgBase,
      body: body,
      floatingActionButtonLocation: isExterno ? null : FloatingActionButtonLocation.centerDocked,
      floatingActionButton: isExterno
          ? null
          : Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.accent,
                border: Border.all(color: c.bgBase, width: 3),
                boxShadow: [BoxShadow(color: c.accent.withValues(alpha: .35), blurRadius: 16, spreadRadius: 2)],
              ),
              child: IconButton(
                onPressed: () => _showChooseTipo(context),
                icon: const Icon(Icons.add_rounded, color: Colors.white, size: 31),
              ),
            ),
      bottomNavigationBar: Container(
        height: 84,
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 18),
        decoration: BoxDecoration(color: c.bgSurface, border: Border(top: BorderSide(color: c.borderSoft))),
        child: Row(
          children: [
            _NavItem(index: 0, path: '/feed', icon: Icons.shield_outlined, label: 'NCs', onTap: _onTabTapped),
            _NavItem(index: 1, path: '/desvios', icon: Icons.local_fire_department_outlined, label: 'Desvios', onTap: _onTabTapped),
            const Expanded(child: SizedBox()),
            _NavItem(index: 2, path: '/notif', icon: Icons.notifications_none_rounded, label: 'Avisos', onTap: _onTabTapped),
            _NavItem(index: 3, path: '/profile', icon: Icons.person_outline_rounded, label: 'Perfil', onTap: _onTabTapped),
          ],
        ),
      ),
    );
  }

  void _showChooseTipo(BuildContext context) {
    final c = context.c;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: c.bgSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ProtoSectionTitle('Registrar ocorrencia'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _TipoCard(
                    title: 'NC',
                    subtitle: 'Nao conformidade',
                    color: c.statusRedFg,
                    icon: Icons.shield_outlined,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      context.go('/camera?tipo=nc');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TipoCard(
                    title: 'Desvio',
                    subtitle: 'Condicao insegura',
                    color: c.statusYellowFg,
                    icon: Icons.local_fire_department_outlined,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      context.go('/camera?tipo=desvio');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final String path;
  final IconData icon;
  final String label;
  final ValueChanged<int> onTap;

  const _NavItem({required this.index, required this.path, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final selected = GoRouterState.of(context).uri.path == path;
    final color = selected ? c.accent : c.fg2;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: SafeCoreMotion.fast,
              width: selected ? 26 : 0,
              height: 3,
              decoration: BoxDecoration(color: c.accent, borderRadius: BorderRadius.circular(999)),
            ),
            const SizedBox(height: 12),
            Icon(icon, size: 21, color: color),
            const SizedBox(height: 2),
            Text(label, maxLines: 1, style: SafeCoreType.micro.copyWith(color: color, fontSize: 10.5)),
          ],
        ),
      ),
    );
  }
}

class _TipoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _TipoCard({required this.title, required this.subtitle, required this.color, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: ProtoCard(
        color: color.withValues(alpha: .10),
        child: SizedBox(
          height: 122,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 40, color: color),
              const Spacer(),
              Text(title, style: SafeCoreType.headline.copyWith(color: c.fg0, fontSize: 20)),
              const SizedBox(height: 4),
              Text(subtitle, style: SafeCoreType.body.copyWith(color: c.fg2)),
            ],
          ),
        ),
      ),
    );
  }
}
