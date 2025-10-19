import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/widgets.dart';

class ContactsController extends GetxController {
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
      tooltip: 'Сетка',
      icon: Icons.grid_view,
    ),
    ViewMode(
      tooltip: 'Организационная схема',
      icon: Icons.account_tree_outlined,
    ),
  ];

  // Фильтры
  final RxBool filterEmployees = false.obs;
  final RxBool filterWithAvatars = false.obs;
  final RxBool filterActive = false.obs;
  final RxBool filterByDepartment = false.obs;
  
  // Сортировка
  final RxString sortBy = 'name'.obs;

  // Геттеры для активных состояний
  bool get hasActiveFilters => filterEmployees.value || filterWithAvatars.value || filterActive.value || filterByDepartment.value;
  bool get hasActiveSort => sortBy.value != 'name';

  // Сброс фильтров
  void resetFilters() {
    filterEmployees.value = false;
    filterWithAvatars.value = false;
    filterActive.value = false;
    filterByDepartment.value = false;
  }

  // Сброс сортировки
  void resetSort() {
    sortBy.value = 'name';
  }

  @override
  void onInit() {
    super.onInit();
  }

  // Popover
  final LayerLink filterButtonLink = LayerLink();
  final LayerLink sortButtonLink = LayerLink();
  OverlayEntry? _popoverEntry;

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
        title: 'Фильтры контактов',
        onClose: () {
          resetFilters();
          _closePopover();
        },
        child: Obx(() => Column(
          children: [
            CheckboxListTile(
              title: const Text('Только сотрудники'),
              value: filterEmployees.value,
              onChanged: (value) => filterEmployees.value = value ?? false,
            ),
            CheckboxListTile(
              title: const Text('С аватарами'),
              value: filterWithAvatars.value,
              onChanged: (value) => filterWithAvatars.value = value ?? false,
            ),
            CheckboxListTile(
              title: const Text('Активные'),
              value: filterActive.value,
              onChanged: (value) => filterActive.value = value ?? false,
            ),
            CheckboxListTile(
              title: const Text('По отделам'),
              value: filterByDepartment.value,
              onChanged: (value) => filterByDepartment.value = value ?? false,
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
              title: const Text('По имени'),
              value: 'name',
              groupValue: sortBy.value,
              onChanged: (value) => sortBy.value = value ?? 'name',
            ),
            RadioListTile<String>(
              title: const Text('По должности'),
              value: 'position',
              groupValue: sortBy.value,
              onChanged: (value) => sortBy.value = value ?? 'name',
            ),
            RadioListTile<String>(
              title: const Text('По отделу'),
              value: 'department',
              groupValue: sortBy.value,
              onChanged: (value) => sortBy.value = value ?? 'name',
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

  void _closePopover() {
    _popoverEntry?.remove();
    _popoverEntry = null;
  }

  // Изменить режим представления
  void onViewModeChanged(int index) {
    currentViewMode.value = index;
  }
}
