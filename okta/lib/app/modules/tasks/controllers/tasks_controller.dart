import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/widgets.dart';

class TasksController extends GetxController {
  // Поиск
  final searchController = TextEditingController();
  
  // Режимы представления
  final currentViewMode = 0.obs;
  final viewModes = const <ViewMode>[
    ViewMode(
      tooltip: 'Список',
      icon: Icons.view_list,
    ),
    ViewMode(
      tooltip: 'Канбан',
      icon: Icons.dashboard_outlined,
    ),
    ViewMode(
      tooltip: 'Календарь',
      icon: Icons.calendar_today_outlined,
    ),
    ViewMode(
      tooltip: 'Временная шкала',
      icon: Icons.timeline_outlined,
    ),
  ];

  // Фильтры
  final RxBool filterHighPriority = false.obs;
  final RxBool filterOverdue = false.obs;
  final RxBool filterCompleted = false.obs;
  final RxBool filterMyTasks = false.obs;
  
  // Сортировка
  final RxString sortBy = 'created'.obs;

  // Геттеры для активных состояний
  bool get hasActiveFilters => filterHighPriority.value || filterOverdue.value || filterCompleted.value || filterMyTasks.value;
  bool get hasActiveSort => sortBy.value != 'created';

  // Сброс фильтров
  void resetFilters() {
    filterHighPriority.value = false;
    filterOverdue.value = false;
    filterCompleted.value = false;
    filterMyTasks.value = false;
  }

  // Сброс сортировки
  void resetSort() {
    sortBy.value = 'created';
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    searchController.dispose();
    _closePopover();
    super.onClose();
  }

  // Обработка поиска
  void onSearchChanged(String value) {
    // Обработка поиска
  }

  // Открыть фильтры
  void onFilterPressed(BuildContext buttonContext) {
    if (_popoverEntry != null) {
      _closePopover();
      return;
    }

    _popoverEntry = GlassPopoverUtils.showAtLink(
      context: buttonContext,
      targetContext: buttonContext,
      link: filterButtonLink,
      width: 280,
      height: 220,
      onDismiss: () => _popoverEntry = null,
      builder: (context) => GlassPopover(
        title: 'Фильтры задач',
        onClose: () {
          resetFilters();
          _closePopover();
        },
        child: Obx(() => Column(
          children: [
            CheckboxListTile(
              title: const Text('Высокий приоритет'),
              value: filterHighPriority.value,
              onChanged: (value) => filterHighPriority.value = value ?? false,
            ),
            CheckboxListTile(
              title: const Text('Просроченные'),
              value: filterOverdue.value,
              onChanged: (value) => filterOverdue.value = value ?? false,
            ),
            CheckboxListTile(
              title: const Text('Выполненные'),
              value: filterCompleted.value,
              onChanged: (value) => filterCompleted.value = value ?? false,
            ),
            CheckboxListTile(
              title: const Text('Мои задачи'),
              value: filterMyTasks.value,
              onChanged: (value) => filterMyTasks.value = value ?? false,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Применить фильтры
                  _closePopover();
                },
                child: const Text('Применить'),
              ),
            ),
          ],
        )),
      ),
    );
  }

  // Открыть сортировку
  void onSortPressed(BuildContext buttonContext) {
    if (_popoverEntry != null) {
      _closePopover();
      return;
    }

    _popoverEntry = GlassPopoverUtils.showAtLink(
      context: buttonContext,
      targetContext: buttonContext,
      link: sortButtonLink,
      width: 250,
      height: 200,
      onDismiss: () => _popoverEntry = null,
      builder: (context) => GlassPopover(
        title: 'Сортировка',
        onClose: () {
          resetSort();
          _closePopover();
        },
        child: Obx(() => Column(
          children: [
            RadioListTile<String>(
              title: const Text('По дате создания'),
              value: 'created',
              groupValue: sortBy.value,
              onChanged: (value) => sortBy.value = value ?? 'created',
            ),
            RadioListTile<String>(
              title: const Text('По сроку'),
              value: 'deadline',
              groupValue: sortBy.value,
              onChanged: (value) => sortBy.value = value ?? 'created',
            ),
            RadioListTile<String>(
              title: const Text('По приоритету'),
              value: 'priority',
              groupValue: sortBy.value,
              onChanged: (value) => sortBy.value = value ?? 'created',
            ),
            RadioListTile<String>(
              title: const Text('По исполнителю'),
              value: 'assignee',
              groupValue: sortBy.value,
              onChanged: (value) => sortBy.value = value ?? 'created',
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Применить сортировку
                  _closePopover();
                },
                child: const Text('Применить'),
              ),
            ),
          ],
        )),
      ),
    );
  }

  // Popover
  final LayerLink addButtonLink = LayerLink();
  final LayerLink filterButtonLink = LayerLink();
  final LayerLink sortButtonLink = LayerLink();
  OverlayEntry? _popoverEntry;

  // Создать новую задачу
  void onAddPressed(BuildContext buttonContext) {
    if (_popoverEntry != null) {
      _closePopover();
      return;
    }

    _popoverEntry = GlassPopoverUtils.showAtLink(
      context: buttonContext,
      targetContext: buttonContext,
      link: addButtonLink,
      width: 300,
      height: 250,
      onDismiss: () => _popoverEntry = null,
      builder: (context) => GlassPopover(
        title: 'Новая задача',
        onClose: () {
          _closePopover();
        },
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Название задачи',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Описание',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Приоритет',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'low', child: Text('Низкий')),
                      DropdownMenuItem(value: 'medium', child: Text('Средний')),
                      DropdownMenuItem(value: 'high', child: Text('Высокий')),
                    ],
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Создать задачу
                      _closePopover();
                    },
                    child: const Text('Создать'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _closePopover() {
    _popoverEntry?.remove();
    _popoverEntry = null;
  }

  // Изменить режим представления
  void onViewModeChanged(int index) {
    currentViewMode.value = index;
  }
}
