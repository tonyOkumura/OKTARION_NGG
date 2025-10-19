import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/widgets.dart';

class FilesController extends GetxController {
  // Поиск
  final searchController = TextEditingController();
  
  // Режимы представления
  final currentViewMode = 0.obs;
  final viewModes = const <ViewMode>[
    ViewMode(
      tooltip: 'Сетка',
      icon: Icons.grid_view,
    ),
    ViewMode(
      tooltip: 'Список',
      icon: Icons.view_list,
    ),
    ViewMode(
      tooltip: 'Папки',
      icon: Icons.folder_outlined,
    ),
    ViewMode(
      tooltip: 'Облако',
      icon: Icons.cloud_outlined,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Обработка поиска
  void onSearchChanged(String value) {
    // Обработка поиска
  }

  // Открыть фильтры
  void onFilterPressed() {
    // Открыть фильтры
  }

  // Открыть сортировку
  void onSortPressed() {
    // Открыть сортировку
  }

  // Загрузить новый файл
  void onAddPressed() {
    // Загрузить новый файл
  }

  // Изменить режим представления
  void onViewModeChanged(int index) {
    currentViewMode.value = index;
  }
}
