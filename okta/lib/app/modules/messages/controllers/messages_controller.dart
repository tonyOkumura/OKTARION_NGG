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

  // Фильтры
  final RxBool filterUnread = false.obs;
  final RxBool filterImportant = false.obs;
  final RxBool filterWithAttachments = false.obs;
  
  // Сортировка
  final RxString sortBy = 'date'.obs;

  // Геттеры для активных состояний
  bool get hasActiveFilters => filterUnread.value || filterImportant.value || filterWithAttachments.value;
  bool get hasActiveSort => sortBy.value != 'date';

  // Сброс фильтров
  void resetFilters() {
    filterUnread.value = false;
    filterImportant.value = false;
    filterWithAttachments.value = false;
  }

  // Сброс сортировки
  void resetSort() {
    sortBy.value = 'date';
  }

  // Popover
  final LayerLink addButtonLink = LayerLink();
  final LayerLink filterButtonLink = LayerLink();
  final LayerLink sortButtonLink = LayerLink();
  OverlayEntry? _popoverEntry;

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
        title: 'Фильтры сообщений',
        onClose: () {
          resetFilters();
          _closePopover();
        },
        child: Obx(() => Column(
          children: [
            CheckboxListTile(
              title: const Text('Непрочитанные'),
              value: filterUnread.value,
              onChanged: (value) => filterUnread.value = value ?? false,
            ),
            CheckboxListTile(
              title: const Text('Важные'),
              value: filterImportant.value,
              onChanged: (value) => filterImportant.value = value ?? false,
            ),
            CheckboxListTile(
              title: const Text('С вложениями'),
              value: filterWithAttachments.value,
              onChanged: (value) => filterWithAttachments.value = value ?? false,
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
              title: const Text('По отправителю'),
              value: 'sender',
              groupValue: sortBy.value,
              onChanged: (value) => sortBy.value = value ?? 'date',
            ),
            RadioListTile<String>(
              title: const Text('По теме'),
              value: 'subject',
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

  // Создать новое сообщение
  void onAddPressed(BuildContext buttonContext) {
    if (_popoverEntry != null) {
      _closePopover();
      return;
    }

    _popoverEntry = GlassPopoverUtils.showAtLink(
      context: buttonContext,
      targetContext: buttonContext,
      link: addButtonLink,
      width: 280,
      height: 200,
      onDismiss: () => _popoverEntry = null,
      builder: (context) => GlassPopover(
        title: 'Новое сообщение',
        onClose: () {
          _closePopover();
        },
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Получатель',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Тема',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Создать сообщение
                  _closePopover();
                },
                child: const Text('Отправить'),
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
