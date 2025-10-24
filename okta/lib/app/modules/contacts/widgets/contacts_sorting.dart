import 'package:flutter/material.dart';

import '../../../../shared/widgets/glass_dropdown.dart';


class ContactsSortingWidget extends StatelessWidget {
  const ContactsSortingWidget({
    super.key,
    required this.sortBy,
    required this.onSortByChanged,
    required this.sortOrder,
    required this.onSortOrderChanged,
    this.onApply,
    this.onClear,
  });

  final String sortBy;
  final ValueChanged<String?> onSortByChanged;
  final String sortOrder; // 'ASC' | 'DESC'
  final ValueChanged<String?> onSortOrderChanged;
  final VoidCallback? onApply;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final items = const [
      DropdownMenuItem(value: 'created_at', child: Text('Дата создания')),
      DropdownMenuItem(value: 'updated_at', child: Text('Дата обновления')),
      DropdownMenuItem(value: 'username', child: Text('Username')),
      DropdownMenuItem(value: 'firstName', child: Text('Имя')),
      DropdownMenuItem(value: 'lastName', child: Text('Фамилия')),
      DropdownMenuItem(value: 'email', child: Text('Email')),
      DropdownMenuItem(value: 'role', child: Text('Роль')),
      DropdownMenuItem(value: 'company', child: Text('Управление')),
      DropdownMenuItem(value: 'department', child: Text('Отдел')),
      DropdownMenuItem(value: 'position', child: Text('Должность')),
      DropdownMenuItem(value: 'rank', child: Text('Звание')),
    ];

    final orderItems = const [
      DropdownMenuItem(value: 'ASC', child: Text('По возрастанию')),
      DropdownMenuItem(value: 'DESC', child: Text('По убыванию')),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        GlassDropdownField<String>(
          label: 'Поле',
          value: sortBy,
          items: items,
          onChanged: onSortByChanged,
          prefixIcon: Icons.sort_by_alpha,
        ),
        const SizedBox(height: 12),
        GlassDropdownField<String>(
          label: 'Порядок',
          value: sortOrder,
          items: orderItems,
          onChanged: onSortOrderChanged,
          prefixIcon: Icons.swap_vert,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}


