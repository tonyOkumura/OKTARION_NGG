import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/files_controller.dart';

class FilesView extends GetView<FilesController> {
  const FilesView({super.key});

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
          hintText: 'Поиск файлов...',
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
      case 0: // Сетка
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.grid_view, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Сетка файлов', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Плиточное представление', style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        );
      case 1: // Список
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.view_list, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Список файлов', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Линейное представление', style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        );
      case 2: // Папки
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Папки', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Структура папок', style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        );
      case 3: // Облако
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Облачное хранилище', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Синхронизация с облаком', style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        );
      default:
        return const Center(child: Text('Неизвестный режим'));
    }
  }
}