import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/messages_controller.dart';

class MessagesView extends GetView<MessagesController> {
  const MessagesView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return Column(
      children: [
        // Поисковая строка
        Obx(() => GlassSearchBar(
          searchController: controller.searchController,
          onSearchChanged: controller.onSearchChanged,
          onFilterPressed: (context) => controller.onFilterPressed(context),
          onSortPressed: (context) => controller.onSortPressed(context),
          onAddPressed: (context) => controller.onAddPressed(context),
          addButtonLink: controller.addButtonLink,
          filterButtonLink: controller.filterButtonLink,
          sortButtonLink: controller.sortButtonLink,
          viewModes: controller.viewModes,
          currentViewMode: controller.currentViewMode.value,
          onViewModeChanged: controller.onViewModeChanged,
          hintText: 'Поиск сообщений...',
          showAddButton: true,
          isFilterActive: controller.hasActiveFilters,
          isSortActive: controller.hasActiveSort,
        )),
        
        const SizedBox(height: 16),
        
        // Основной контент
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surface.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
                ),
                padding: const EdgeInsets.all(16),
                child: Obx(() => _buildContent()),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    switch (controller.currentViewMode.value) {
      case 0: // Чаты
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Чаты', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Список активных чатов', style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        );
      case 1: // Входящие
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Входящие', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Полученные сообщения', style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        );
      case 2: // Исходящие
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.send_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Исходящие', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Отправленные сообщения', style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        );
      case 3: // Избранные
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Избранные', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Важные сообщения', style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        );
      default:
        return const Center(child: Text('Неизвестный режим'));
    }
  }
}