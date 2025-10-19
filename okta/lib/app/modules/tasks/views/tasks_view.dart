import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/tasks_controller.dart';

class TasksView extends GetView<TasksController> {
  const TasksView({super.key});

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
          hintText: 'Поиск задач...',
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
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
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
      case 0: // Список
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.view_list, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Список задач', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Линейное представление задач', style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        );
      case 1: // Канбан
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.dashboard_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Канбан', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Доски с колонками', style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        );
      case 2: // Календарь
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Календарь', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Задачи по датам', style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        );
      case 3: // Временная шкала
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timeline_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Временная шкала', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Хронология выполнения', style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        );
      default:
        return const Center(child: Text('Неизвестный режим'));
    }
  }
}