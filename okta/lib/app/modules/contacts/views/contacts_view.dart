import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/contacts_controller.dart';

class ContactsView extends GetView<ContactsController> {
  const ContactsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return Column(
      children: [
        // Поисковая строка
        Obx(() => GlassSearchBar(
          searchController: controller.searchController,
          onSearchChanged: controller.onSearchChanged,
          onFilterPressed: (context) => controller.onFilterPressed(context),
          onSortPressed: (context) => controller.onSortPressed(context),
          filterButtonLink: controller.filterButtonLink,
          sortButtonLink: controller.sortButtonLink,
          isFilterActive: controller.hasActiveFilters,
          isSortActive: controller.hasActiveSort,
        )),
        
        const SizedBox(height: 16),
        
        // Основной контент
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surface.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
                ),
                padding: const EdgeInsets.all(16),
                child: Obx(() => _buildContent()),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (controller.isLoading.value && controller.contacts.isEmpty) {
      return _buildSkeletonList();
    }

    if (controller.contacts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.contacts_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Контакты не найдены', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Попробуйте изменить фильтры или обновить список', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    // Только список
    return _buildListView();
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      itemCount: 8, // Показываем 8 скелетонов
      itemBuilder: (context, index) {
        return const ContactTileSkeleton();
      },
    );
  }

  Widget _buildListView() {
    return RefreshIndicator(
      onRefresh: controller.refreshContacts,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          // Автоматически загружаем больше контактов при достижении конца
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
              controller.hasMore.value && 
              !controller.isLoading.value) {
            controller.loadMoreContacts();
          }
          return false;
        },
        child: ListView.builder(
          itemCount: controller.contacts.length,
          itemBuilder: (context, index) {
            final contact = controller.contacts[index];
            return ContactTile(
              contact: contact,
              onTap: () => _onContactTap(contact),
              onMessagePressed: () => _onMessagePressed(contact),
              showOnlineStatus: true,
              showRole: true,
              showHoverHighlight: true, // Включаем выделение при наведении
            );
          },
        ),
      ),
    );
  }



  void _onContactTap(contact) {
    // TODO: Открыть детальную информацию о контакте
    Get.snackbar(
      'Контакт',
      'Открыт контакт: ${contact.displayNameOrUsername}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _onMessagePressed(contact) {
    // TODO: Открыть чат с контактом
    Get.snackbar(
      'Сообщение',
      'Открыт чат с: ${contact.displayNameOrUsername}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primary.withValues(alpha: 0.1),
      colorText: Get.theme.colorScheme.primary,
    );
  }
}