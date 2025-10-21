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

  // Геттеры для активных состояний
  bool get hasActiveFilters => filterEmployees.value || filterWithAvatars.value || filterActive.value ||
      filterDepartment.value != null || filterCompany.value != null || filterPosition.value != null ||
      filterRank.value != null || filterStatus.value != null;
  bool get hasActiveSort => sortBy.value != 'username' || sortOrder.value != 'ASC';

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
  }

  // Сброс сортировки
  void resetSort() {
    sortBy.value = 'username';
    sortOrder.value = 'ASC';
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
        limit: 20,
        sortBy: sortBy.value,
        sortOrder: sortOrder.value,
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
      height: 490,
      onDismiss: () => _popoverEntry = null,
      builder: (context) => GlassPopover(
        title: 'Фильтры контактов',
        onClose: () {
          resetFilters();
          _closePopover();
        },
        child: Obx(() => ContactsFiltersWidget(
          department: filterDepartment.value,
          onDepartmentChanged: (v) => filterDepartment.value = v,
          company: filterCompany.value,
          onCompanyChanged: (v) => filterCompany.value = v,
          position: filterPosition.value,
          onPositionChanged: (v) => filterPosition.value = v,
          rank: filterRank.value,
          onRankChanged: (v) => filterRank.value = v,
          status: filterStatus.value,
          onStatusChanged: (v) => filterStatus.value = v,
          onApply: () {
            refreshContacts();
            _closePopover();
          },
          onClear: () {
            resetFilters();
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
      height: 250,
      onDismiss: () => _popoverEntry = null,
      builder: (context) => GlassPopover(
        title: 'Сортировка',
        onClose: () {
          resetSort();
          _closePopover();
        },
        child: Obx(() => ContactsSortingWidget(
          sortBy: sortBy.value,
          onSortByChanged: (v) => sortBy.value = v ?? 'username',
          sortOrder: sortOrder.value,
          onSortOrderChanged: (v) => sortOrder.value = v ?? 'ASC',
          onApply: () {
            refreshContacts();
            _closePopover();
          },
          onClear: () {
            resetSort();
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
