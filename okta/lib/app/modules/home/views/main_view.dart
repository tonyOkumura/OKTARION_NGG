import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import removed: sidebarx no longer used
import 'dart:ui';

import '../../contacts/views/contacts_view.dart';
import '../../settings/views/settings_view.dart';
import '../../messages/views/messages_view.dart';
import '../../tasks/views/tasks_view.dart';
import '../../events/views/events_view.dart';
import '../../files/views/files_view.dart';
import 'home_view.dart';
import '../controllers/main_controller.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _AppSidebar(controller: controller),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 8.0),
              child: Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: controller.pageController,
                      onPageChanged: controller.onPageChanged,
                      children: [
                        HomeView(),
                        ContactsView(),
                        MessagesView(),
                        TasksView(),
                        EventsView(),
                        FilesView(),
                        SettingsView(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppSidebar extends StatelessWidget {
  const _AppSidebar({required this.controller});

  final MainController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final double w = MediaQuery.of(context).size.width;
    final bool extended = w >= 1200;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Obx(() {
            final selected = controller.selectedIndex.value;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubic,
              width: extended ? 220 : 72,
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 8),
                        if (extended)
                          Flexible(
                            child: Text(
                              'OKTARION',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Items
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      children: [
                        _Item(
                          icon: Icons.home_outlined,
                          label: 'Главная',
                          extended: extended,
                          selected: selected == 0,
                          onTap: () => controller.onSidebarTapped(0),
                        ),
                        _Item(
                          icon: Icons.people_alt_outlined,
                          label: 'Контакты',
                          extended: extended,
                          selected: selected == 1,
                          onTap: () => controller.onSidebarTapped(1),
                          badge: Obx(
                            () => controller.pendingContacts.value > 0
                                ? Text('${controller.pendingContacts.value}')
                                : const SizedBox.shrink(),
                          ),
                        ),
                        _Item(
                          icon: Icons.chat_bubble_outline,
                          label: 'Сообщения',
                          extended: extended,
                          selected: selected == 2,
                          onTap: () => controller.onSidebarTapped(2),
                          badge: Obx(
                            () => controller.unreadMessages.value > 0
                                ? Text('${controller.unreadMessages.value}')
                                : const SizedBox.shrink(),
                          ),
                        ),
                        _Item(
                          icon: Icons.check_circle_outline,
                          label: 'Задачи',
                          extended: extended,
                          selected: selected == 3,
                          onTap: () => controller.onSidebarTapped(3),
                          badge: Obx(
                            () => controller.tasksOpen.value > 0
                                ? Text('${controller.tasksOpen.value}')
                                : const SizedBox.shrink(),
                          ),
                        ),
                        _Item(
                          icon: Icons.event_outlined,
                          label: 'События',
                          extended: extended,
                          selected: selected == 4,
                          onTap: () => controller.onSidebarTapped(4),
                          badge: Obx(
                            () => controller.eventsToday.value > 0
                                ? Text('${controller.eventsToday.value}')
                                : const SizedBox.shrink(),
                          ),
                        ),
                        _Item(
                          icon: Icons.folder_open_outlined,
                          label: 'Файлы',
                          extended: extended,
                          selected: selected == 5,
                          onTap: () => controller.onSidebarTapped(5),
                        ),
                        _Item(
                          icon: Icons.settings_outlined,
                          label: 'Настройки',
                          extended: extended,
                          selected: selected == 6,
                          onTap: () => controller.onSidebarTapped(6),
                        ),
                      ],
                    ),
                  ),
                  // Footer
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _Item(
                          icon: Icons.logout,
                          label: 'Выход',
                          extended: extended,
                          selected: false,
                          onTap: () => controller.signOut(),
                        ),
                        const SizedBox(height: 8),
                        _FooterBadge(extended: extended),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.icon,
    required this.label,
    required this.extended,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final bool extended;
  final bool selected;
  final VoidCallback onTap;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: _Hoverable(
        builder: (hovered) {
          final Color borderColor = hovered
              ? colorScheme.primary.withValues(alpha: 0.35)
              : (selected
                    ? colorScheme.primary.withValues(alpha: 0.35)
                    : colorScheme.outline.withValues(alpha: 0.12));
          return InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(
                horizontal: extended ? 12 : 0,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? colorScheme.primary.withValues(alpha: 0.12)
                    : (hovered
                          ? colorScheme.surfaceContainerHighest.withValues(
                              alpha: 0.5,
                            )
                          : Colors.transparent),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: extended
                  ? Row(
                      children: [
                        const SizedBox(width: 10),
                        Icon(
                          icon,
                          size: 20,
                          color: selected
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: selected
                                  ? colorScheme.onSurface
                                  : colorScheme.onSurfaceVariant,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          _Badge(child: badge!),
                        ],
                      ],
                    )
                  : Center(
                      child: Icon(
                        icon,
                        size: 22,
                        color: selected
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _Hoverable extends StatefulWidget {
  const _Hoverable({required this.builder});
  final Widget Function(bool hovered) builder;

  @override
  State<_Hoverable> createState() => _HoverableState();
}

class _HoverableState extends State<_Hoverable> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: widget.builder(_hovered),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.child}) : small = false;
  const _Badge.small({required this.child}) : small = true;
  final Widget child;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.35)),
      ),
      child: DefaultTextStyle.merge(
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: colorScheme.onPrimaryContainer,
        ),
        child: child,
      ),
    );
  }
}

class _FooterBadge extends StatelessWidget {
  const _FooterBadge({required this.extended});
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final c = Get.find<MainController>();
    return Obx(() {
      final total = c.totalNotifications.value;
      if (total <= 0) return const SizedBox.shrink();
      if (!extended) {
        return _Badge.small(child: Text('$total'));
      }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.secondary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 18,
              color: colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 8),
            Text(
              'Уведомления',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            _Badge(child: Text('$total')),
          ],
        ),
      );
    });
  }
}
