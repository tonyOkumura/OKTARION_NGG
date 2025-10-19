import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/widgets.dart';

class EventsController extends GetxController {
  // Поиск
  final searchController = TextEditingController();
  
  // Режимы представления
  final currentViewMode = 0.obs;
  final viewModes = const <ViewMode>[
    ViewMode(
      tooltip: 'Календарь',
      icon: Icons.calendar_today_outlined,
    ),
    ViewMode(
      tooltip: 'Список',
      icon: Icons.view_list,
    ),
    ViewMode(
      tooltip: 'Временная шкала',
      icon: Icons.timeline_outlined,
    ),
    ViewMode(
      tooltip: 'Карта',
      icon: Icons.map_outlined,
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

  // Создать новое событие
  void onAddPressed() {
    // Создать новое событие
  }

  // Изменить режим представления
  void onViewModeChanged(int index) {
    currentViewMode.value = index;
  }
}
