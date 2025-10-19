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

  // Фильтры
  final RxBool filterImages = false.obs;
  final RxBool filterDocuments = false.obs;
  final RxBool filterVideos = false.obs;
  final RxBool filterRecent = false.obs;
  
  // Сортировка
  final RxString sortBy = 'name'.obs;

  // Геттеры для активных состояний
  bool get hasActiveFilters => filterImages.value || filterDocuments.value || filterVideos.value || filterRecent.value;
  bool get hasActiveSort => sortBy.value != 'name';

  // Сброс фильтров
  void resetFilters() {
    filterImages.value = false;
    filterDocuments.value = false;
    filterVideos.value = false;
    filterRecent.value = false;
  }

  // Сброс сортировки
  void resetSort() {
    sortBy.value = 'name';
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
        title: 'Фильтры файлов',
        onClose: () {
          resetFilters();
          _closePopover();
        },
        child: Obx(() => Column(
          children: [
            CheckboxListTile(
              title: const Text('Изображения'),
              value: filterImages.value,
              onChanged: (value) => filterImages.value = value ?? false,
            ),
            CheckboxListTile(
              title: const Text('Документы'),
              value: filterDocuments.value,
              onChanged: (value) => filterDocuments.value = value ?? false,
            ),
            CheckboxListTile(
              title: const Text('Видео'),
              value: filterVideos.value,
              onChanged: (value) => filterVideos.value = value ?? false,
            ),
            CheckboxListTile(
              title: const Text('Недавние'),
              value: filterRecent.value,
              onChanged: (value) => filterRecent.value = value ?? false,
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
              title: const Text('По дате'),
              value: 'date',
              groupValue: sortBy.value,
              onChanged: (value) => sortBy.value = value ?? 'name',
            ),
            RadioListTile<String>(
              title: const Text('По размеру'),
              value: 'size',
              groupValue: sortBy.value,
              onChanged: (value) => sortBy.value = value ?? 'name',
            ),
            RadioListTile<String>(
              title: const Text('По типу'),
              value: 'type',
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

  // Popover
  final LayerLink addButtonLink = LayerLink();
  final LayerLink filterButtonLink = LayerLink();
  final LayerLink sortButtonLink = LayerLink();
  OverlayEntry? _popoverEntry;

  // Загрузить новый файл
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
      height: 200,
      onDismiss: () => _popoverEntry = null,
      builder: (context) => GlassPopover(
        title: 'Загрузить файл',
        onClose: () {
          _closePopover();
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Перетащите файлы сюда или нажмите для выбора',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Выбрать файлы
                    },
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Выбрать файлы'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Создать папку
                    },
                    icon: const Icon(Icons.create_new_folder),
                    label: const Text('Новая папка'),
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
