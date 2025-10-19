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

  // Фильтры
  final RxBool filterToday = false.obs;
  final RxBool filterThisWeek = false.obs;
  final RxBool filterImportant = false.obs;
  final RxBool filterMyEvents = false.obs;
  
  // Сортировка
  final RxString sortBy = 'date'.obs;

  // Геттеры для активных состояний
  bool get hasActiveFilters => filterToday.value || filterThisWeek.value || filterImportant.value || filterMyEvents.value;
  bool get hasActiveSort => sortBy.value != 'date';

  // Сброс фильтров
  void resetFilters() {
    filterToday.value = false;
    filterThisWeek.value = false;
    filterImportant.value = false;
    filterMyEvents.value = false;
  }

  // Сброс сортировки
  void resetSort() {
    sortBy.value = 'date';
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
      height: 200,
      onDismiss: () => _popoverEntry = null,
      builder: (context) => GlassPopover(
        title: 'Фильтры событий',
        onClose: () {
          resetFilters();
          _closePopover();
        },
        child: Obx(() => Column(
          children: [
            CheckboxListTile(
              title: const Text('Сегодня'),
              value: filterToday.value,
              onChanged: (value) => filterToday.value = value ?? false,
            ),
            CheckboxListTile(
              title: const Text('На этой неделе'),
              value: filterThisWeek.value,
              onChanged: (value) => filterThisWeek.value = value ?? false,
            ),
            CheckboxListTile(
              title: const Text('Важные'),
              value: filterImportant.value,
              onChanged: (value) => filterImportant.value = value ?? false,
            ),
            CheckboxListTile(
              title: const Text('Мои события'),
              value: filterMyEvents.value,
              onChanged: (value) => filterMyEvents.value = value ?? false,
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
      height: 180,
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
              title: const Text('По дате'),
              value: 'date',
              groupValue: sortBy.value,
              onChanged: (value) => sortBy.value = value ?? 'date',
            ),
            RadioListTile<String>(
              title: const Text('По названию'),
              value: 'name',
              groupValue: sortBy.value,
              onChanged: (value) => sortBy.value = value ?? 'date',
            ),
            RadioListTile<String>(
              title: const Text('По типу'),
              value: 'type',
              groupValue: sortBy.value,
              onChanged: (value) => sortBy.value = value ?? 'date',
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

  // Создать новое событие
  void onAddPressed(BuildContext buttonContext) {
    if (_popoverEntry != null) {
      _closePopover();
      return;
    }

    _popoverEntry = GlassPopoverUtils.showAtLink(
      context: buttonContext,
      targetContext: buttonContext,
      link: addButtonLink,
      width: 320,
      height: 280,
      onDismiss: () => _popoverEntry = null,
      builder: (context) => GlassPopover(
        title: 'Новое событие',
        onClose: () {
          _closePopover();
        },
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Название события',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Описание',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Дата начала',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () {
                      // Показать date picker
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Время',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () {
                      // Показать time picker
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Создать событие
                  _closePopover();
                },
                child: const Text('Создать событие'),
              ),
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
