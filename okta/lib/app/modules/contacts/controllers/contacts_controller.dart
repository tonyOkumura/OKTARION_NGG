import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:okta/app/modules/contacts/widgets/contacts_filters.dart';
import 'package:okta/app/modules/contacts/widgets/contacts_sorting.dart';
import 'dart:async';
import '../../../../shared/widgets/widgets.dart';
import '../../../../core/config/work_types.dart';
import '../../../../core/core.dart';

class ContactsController extends GetxController {
  // Репозиторий для работы с контактами
  final ContactsRepository _contactsRepository = Get.find<ContactsRepository>();
  
  // Поиск
  final searchController = TextEditingController();
  Timer? _searchDebounceTimer;
  
  // Состояние загрузки
  final isLoading = false.obs;
  final contacts = <Contact>[].obs;
  final hasMore = false.obs;
  final nextCursor = Rxn<String>();
  
  // Режимы представления - только список
  final currentViewMode = 0.obs;
  final viewModes = const <ViewMode>[
    ViewMode(
      tooltip: 'Список',
      icon: Icons.view_list,
    ),
  ];

  // Фильтры
  final RxBool filterEmployees = false.obs;
  final RxBool filterWithAvatars = false.obs;
  final RxBool filterActive = false.obs;
  // Новые enum-фильтры
  final Rxn<DepartmentType> filterDepartment = Rxn<DepartmentType>();
  final Rxn<CompanyType> filterCompany = Rxn<CompanyType>();
  final Rxn<PositionType> filterPosition = Rxn<PositionType>();
  final Rxn<RankType> filterRank = Rxn<RankType>();
  final Rxn<StatusType> filterStatus = Rxn<StatusType>();
  
  // Сортировка
  final RxString sortBy = 'username'.obs;
  final RxString sortOrder = 'ASC'.obs;
  
  // Таймер для debounce фильтров
  Timer? _filterDebounceTimer;

  // Геттеры для активных состояний
  bool get hasActiveFilters => filterEmployees.value || filterWithAvatars.value || filterActive.value ||
      filterDepartment.value != null || filterCompany.value != null || filterPosition.value != null ||
      filterRank.value != null || filterStatus.value != null;
  bool get hasActiveSort => sortBy.value != 'username' || sortOrder.value != 'ASC';
  
  // Определяем нужно ли показывать категоризированный вид
  bool get shouldShowCategorized => hasActiveFilters || hasActiveSort;

  // Многоуровневая группировка контактов по категориям
  Map<String, dynamic> get groupedContacts {
    if (!shouldShowCategorized) return {};
    
    final Map<String, dynamic> tree = {};
    
    LogService.d('Building tree for ${contacts.length} contacts');
    for (final contact in contacts) {
      LogService.d('Processing contact: ${contact.displayNameOrUsername}, company: ${contact.company}, department: ${contact.department}, position: ${contact.position}, rank: ${contact.rank}');
      _addContactToTree(tree, contact);
    }
    
    LogService.d('Final tree structure: $tree');
    return tree;
  }
  
  // Добавляем контакт в дерево категорий
  void _addContactToTree(Map<String, dynamic> tree, Contact contact) {
    // Создаем путь категорий: Управление -> Отдел -> Должность (убираем звание)
    final List<String> categoryPath = [];
    
    // Проверяем каждое поле и добавляем "Не указано" если пустое
    if (contact.company != null && contact.company!.isNotEmpty) {
      categoryPath.add('company:${contact.company!}');
    } else {
      categoryPath.add('company:Не указано');
    }
    
    if (contact.department != null && contact.department!.isNotEmpty) {
      categoryPath.add('department:${contact.department!}');
    } else {
      categoryPath.add('department:Не указано');
    }
    
    if (contact.position != null && contact.position!.isNotEmpty) {
      categoryPath.add('position:${contact.position!}');
    } else {
      categoryPath.add('position:Не указано');
    }
    

    LogService.d('Category path for ${contact.displayNameOrUsername}: $categoryPath');
    
    // Создаем вложенную структуру
    Map<String, dynamic> currentLevel = tree;
    for (int i = 0; i < categoryPath.length; i++) {
      final categoryKey = categoryPath[i];
      
      // Создаем категорию если её нет
      if (!currentLevel.containsKey(categoryKey)) {
        currentLevel[categoryKey] = <String, dynamic>{
          'contacts': <Contact>[],
          'subcategories': <String, dynamic>{},
        };
      }
      
      // Получаем данные категории
      final categoryData = currentLevel[categoryKey] as Map<String, dynamic>;
      
      // Добавляем контакт только на последнем уровне (должность)
      if (i == categoryPath.length - 1) {
        (categoryData['contacts'] as List<Contact>).add(contact);
        LogService.d('Added contact ${contact.displayNameOrUsername} to final level $i with key $categoryKey');
      } else {
        LogService.d('Skipped adding contact to intermediate level $i with key $categoryKey');
      }
      
      // Переходим к следующему уровню
      currentLevel = categoryData['subcategories'] as Map<String, dynamic>;
    }
  }
  

  // Реактивное обновление фильтров с debounce
  void _onFilterChanged() {
    _filterDebounceTimer?.cancel();
    _filterDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      refreshContacts();
    });
  }

  // Сброс фильтров
  void resetFilters() {
    filterEmployees.value = false;
    filterWithAvatars.value = false;
    filterActive.value = false;
    filterDepartment.value = null;
    filterCompany.value = null;
    filterPosition.value = null;
    filterRank.value = null;
    filterStatus.value = null;
    // Автоматически обновляем контакты после сброса фильтров
    refreshContacts();
  }

  // Сброс сортировки
  void resetSort() {
    sortBy.value = 'username';
    sortOrder.value = 'ASC';
    // Автоматически обновляем контакты после сброса сортировки
    refreshContacts();
  }

  @override
  void onInit() {
    super.onInit();
    loadContacts();
  }

  // Загрузить контакты
  Future<void> loadContacts({bool refresh = false}) async {
    if (isLoading.value) return;
    
    try {
      isLoading.value = true;
      
      if (refresh) {
        contacts.clear();
        nextCursor.value = null;
      }
      
      final response = await _contactsRepository.getContacts(
        search: searchController.text.isNotEmpty ? searchController.text : null,
        cursor: nextCursor.value,
        limit: 15, // Установлен лимит в 15 контактов
        sortBy: sortBy.value,
        sortOrder: sortOrder.value,
        // Фильтрация по enum-полям
        department: filterDepartment.value != null ? WorkTypesLabels.department(filterDepartment.value!) : null,
        company: filterCompany.value != null ? WorkTypesLabels.company(filterCompany.value!) : null,
        position: filterPosition.value != null ? WorkTypesLabels.position(filterPosition.value!) : null,
        rank: filterRank.value != null ? WorkTypesLabels.rank(filterRank.value!) : null,
        statusMessage: filterStatus.value != null ? WorkTypesLabels.status(filterStatus.value!) : null,
        // Фильтрация по boolean-полям
        isOnline: filterActive.value ? true : null,
      );
      
      if (response.success && response.data != null) {
        final contactsResponse = response.data!;
        
        LogService.d('Server response: hasMore=${contactsResponse.hasMore}, nextCursor=${contactsResponse.nextCursor}, totalCount=${contactsResponse.totalCount}');
        LogService.d('Received ${contactsResponse.contacts.length} contacts from server');
        
        if (refresh) {
          contacts.value = contactsResponse.contacts;
          LogService.d('Refreshed contacts list, new length: ${contacts.length}');
        } else {
          contacts.addAll(contactsResponse.contacts);
          LogService.d('Added contacts to list, new length: ${contacts.length}');
        }
        
        hasMore.value = contactsResponse.hasMore && contactsResponse.nextCursor != null;
        nextCursor.value = contactsResponse.nextCursor;
        
        LogService.i('Loaded ${contactsResponse.contacts.length} contacts, hasMore: ${hasMore.value}, nextCursor: ${nextCursor.value}');
      } else {
        LogService.e('Failed to load contacts: ${response.message}');
      }
    } catch (e) {
      LogService.e('Error loading contacts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Обновить контакты
  Future<void> refreshContacts() async {
    await loadContacts(refresh: true);
  }

  // Загрузить больше контактов (пагинация)
  Future<void> loadMoreContacts() async {
    // Если сервер сказал что больше нет контактов, не пытаемся загружать
    if (!hasMore.value || isLoading.value) {
      return;
    }
    
    await loadContacts(refresh: false);
  }

  // Popover
  final LayerLink filterButtonLink = LayerLink();
  final LayerLink sortButtonLink = LayerLink();
  OverlayEntry? _popoverEntry;

  @override
  void onClose() {
    searchController.dispose();
    _searchDebounceTimer?.cancel();
    _filterDebounceTimer?.cancel();
    _closePopover();
    super.onClose();
  }

  // Обработка поиска с debounce
  void onSearchChanged(String value) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      refreshContacts();
    });
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
      width: 320,
      height: 400, // Уменьшена высота, так как убрали кнопки
      onDismiss: () => _popoverEntry = null,
      builder: (context) => GlassPopover(
        title: 'Фильтры контактов',
        onClose: () {
          resetFilters();
          _closePopover();
        },
        child: Obx(() => ContactsFiltersWidget(
          department: filterDepartment.value,
          onDepartmentChanged: (v) {
            filterDepartment.value = v;
            _onFilterChanged();
          },
          company: filterCompany.value,
          onCompanyChanged: (v) {
            filterCompany.value = v;
            _onFilterChanged();
          },
          position: filterPosition.value,
          onPositionChanged: (v) {
            filterPosition.value = v;
            _onFilterChanged();
          },
          rank: filterRank.value,
          onRankChanged: (v) {
            filterRank.value = v;
            _onFilterChanged();
          },
          status: filterStatus.value,
          onStatusChanged: (v) {
            filterStatus.value = v;
            _onFilterChanged();
          },
          onApply: () {
            _closePopover();
          },
          onClear: () {
            _closePopover();
          },
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
      width: 320,
      height: 280, // Увеличена высота для лучшего отображения
      onDismiss: () => _popoverEntry = null,
      builder: (context) => GlassPopover(
        title: 'Сортировка',
        onClose: () {
          resetSort();
          _closePopover();
        },
        child: Obx(() => ContactsSortingWidget(
          sortBy: sortBy.value,
          onSortByChanged: (v) {
            sortBy.value = v ?? 'username';
            refreshContacts(); // Сортировка применяется сразу
          },
          sortOrder: sortOrder.value,
          onSortOrderChanged: (v) {
            sortOrder.value = v ?? 'ASC';
            refreshContacts(); // Сортировка применяется сразу
          },
          onApply: () {
            _closePopover();
          },
          onClear: () {
            _closePopover();
          },
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
