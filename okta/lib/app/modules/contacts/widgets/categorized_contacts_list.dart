import 'package:flutter/material.dart';
import '../../../../core/models/contact_model.dart';
import '../../../../shared/widgets/widgets.dart';

class CategorizedContactsList extends StatefulWidget {
  const CategorizedContactsList({
    super.key,
    required this.groupedContacts,
    this.onContactTap,
    this.onMessagePressed,
  });

  final Map<String, dynamic> groupedContacts;
  final Function(Contact)? onContactTap;
  final Function(Contact)? onMessagePressed;

  @override
  State<CategorizedContactsList> createState() => _CategorizedContactsListState();
}

class _CategorizedContactsListState extends State<CategorizedContactsList> {
  // Карта для отслеживания состояния сворачивания категорий
  final Map<String, bool> _expandedCategories = {};

  @override
  Widget build(BuildContext context) {
    if (widget.groupedContacts.isEmpty) {
      return const Center(
        child: Text('Нет контактов для отображения'),
      );
    }

    print('CategorizedContactsList: Building with ${widget.groupedContacts.length} top-level categories');
    print('CategorizedContactsList: Keys: ${widget.groupedContacts.keys.toList()}');

    // Фильтруем только категории (исключаем 'contacts')
    final categoryEntries = widget.groupedContacts.entries
        .where((entry) => entry.key != 'contacts')
        .toList();

    if (categoryEntries.isEmpty) {
      // Если нет категорий, показываем только контакты
      final contacts = widget.groupedContacts['contacts'] as List<Contact>? ?? [];
      return ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return ContactTile(
            contact: contact,
            onTap: () => widget.onContactTap?.call(contact),
            onMessagePressed: () => widget.onMessagePressed?.call(contact),
            showOnlineStatus: true,
            showRole: true,
            showHoverHighlight: true,
          );
        },
      );
    }

    return ListView.builder(
      itemCount: categoryEntries.length,
      itemBuilder: (context, index) {
        final categoryEntry = categoryEntries[index];
        final categoryKey = categoryEntry.key;
        final categoryData = categoryEntry.value as Map<String, dynamic>;

        print('CategorizedContactsList: Building category $index: $categoryKey');
        print('CategorizedContactsList: Category data: $categoryData');

        return _buildCategoryNode(
          context,
          categoryKey,
          categoryData,
          0, // уровень вложенности
        );
      },
    );
  }

  Widget _buildCategoryNode(
    BuildContext context,
    String categoryKey,
    Map<String, dynamic> categoryData,
    int level,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    // Парсим категорию для получения типа и названия
    final categoryParts = categoryKey.split(':');
    final categoryType = categoryParts[0];
    final categoryTitle = categoryParts.length > 1 ? categoryParts[1] : categoryKey;
    
    // Определяем иконку по типу категории
    IconData categoryIcon = _getCategoryIcon(categoryType);
    
    // Получаем контакты и подкатегории
    final contacts = categoryData['contacts'] as List<Contact>? ?? [];
    final subcategories = categoryData['subcategories'] as Map<String, dynamic>? ?? {};
    
    // Вычисляем общее количество контактов (включая подкатегории)
    int totalContacts = contacts.length;
    for (final subcategory in subcategories.values) {
      totalContacts += _countContactsInNode(subcategory as Map<String, dynamic>);
    }

    // Проверяем, развернута ли категория (по умолчанию развернута)
    final isExpanded = _expandedCategories[categoryKey] ?? true;
    final hasSubcategories = subcategories.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок категории
        GestureDetector(
          onTap: hasSubcategories ? () {
            setState(() {
              _expandedCategories[categoryKey] = !isExpanded;
            });
          } : null,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 16 + (level * 16), // отступ в зависимости от уровня
              vertical: 12,
            ),
            margin: EdgeInsets.only(
              top: level == 0 ? 16 : 8,
              bottom: 8,
              left: level * 16, // отступ слева для вложенности
            ),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1 - (level * 0.02)), // уменьшаем прозрачность для вложенных
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: cs.primary.withValues(alpha: 0.2 - (level * 0.05)),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Стрелочка для сворачивания (только если есть подкатегории)
                if (hasSubcategories) ...[
                  AnimatedRotation(
                    turns: isExpanded ? 0.25 : 0.0, // Поворачиваем стрелочку
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: cs.primary,
                      size: 16 - (level * 1),
                    ),
                  ),
                  const SizedBox(width: 8),
                ] else ...[
                  const SizedBox(width: 24), // Отступ для выравнивания
                ],
                Icon(
                  categoryIcon,
                  color: cs.primary,
                  size: 20 - (level * 2), // уменьшаем размер иконки для вложенных
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    categoryTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: (theme.textTheme.titleMedium?.fontSize ?? 16) - (level * 1),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$totalContacts',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Контакты и подкатегории (показываем только если развернуто)
        if (isExpanded) ...[
          // Контакты в этой категории
          ...contacts.map((contact) => Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16 + (level * 16),
              vertical: 2,
            ),
            child: ContactTile(
              contact: contact,
              onTap: () => widget.onContactTap?.call(contact),
              onMessagePressed: () => widget.onMessagePressed?.call(contact),
              showOnlineStatus: true,
              showRole: true,
              showHoverHighlight: true,
            ),
          )),

          // Подкатегории (рекурсивно)
          ...subcategories.entries.map((subcategoryEntry) {
            return _buildCategoryNode(
              context,
              subcategoryEntry.key,
              subcategoryEntry.value as Map<String, dynamic>,
              level + 1,
            );
          }),
        ],
      ],
    );
  }
  
  // Подсчитываем общее количество контактов в узле дерева
  int _countContactsInNode(Map<String, dynamic> node) {
    int count = 0;
    
    // Добавляем контакты текущего узла
    final contacts = node['contacts'] as List<Contact>? ?? [];
    count += contacts.length;
    
    // Рекурсивно добавляем контакты из подкатегорий
    final subcategories = node['subcategories'] as Map<String, dynamic>? ?? {};
    for (final subcategory in subcategories.values) {
      count += _countContactsInNode(subcategory as Map<String, dynamic>);
    }
    
    return count;
  }
  
  // Определяем иконку по типу категории
  IconData _getCategoryIcon(String categoryType) {
    switch (categoryType) {
      case 'company':
        return Icons.business;
      case 'department':
        return Icons.business_center;
      case 'position':
        return Icons.work;
      case 'rank':
        return Icons.military_tech;
      case 'uncategorized':
        return Icons.category;
      default:
        return Icons.folder;
    }
  }
}
