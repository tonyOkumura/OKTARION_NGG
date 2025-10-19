import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/widgets.dart';

class MessagesController extends GetxController {
  // Поиск
  final searchController = TextEditingController();
  
  // Режимы представления
  final currentViewMode = 0.obs;
  final viewModes = const <ViewMode>[
    ViewMode(
      tooltip: 'Чаты',
      icon: Icons.chat_bubble_outline,
    ),
    ViewMode(
      tooltip: 'Входящие',
      icon: Icons.inbox_outlined,
    ),
    ViewMode(
      tooltip: 'Исходящие',
      icon: Icons.send_outlined,
    ),
    ViewMode(
      tooltip: 'Избранные',
      icon: Icons.star_outline,
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

  // Создать новое сообщение
  void onAddPressed() {
    // Создать новое сообщение
  }

  // Изменить режим представления
  void onViewModeChanged(int index) {
    currentViewMode.value = index;
  }
}
