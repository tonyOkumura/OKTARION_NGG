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
      DropdownMenuItem(value: 'username', child: Text('Username')),
      DropdownMenuItem(value: 'firstName', child: Text('Имя')),
      DropdownMenuItem(value: 'position', child: Text('Должность')),
      DropdownMenuItem(value: 'department', child: Text('Отдел')),
    ];

    final orderItems = const [
      DropdownMenuItem(value: 'ASC', child: Text('По возрастанию')),
      DropdownMenuItem(value: 'DESC', child: Text('По убыванию')),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassDropdownField<String>(
          label: 'Поле',
          value: sortBy,
          items: items,
          onChanged: onSortByChanged,
          prefixIcon: Icons.sort_by_alpha,
        ),
        GlassDropdownField<String>(
          label: 'Порядок',
          value: sortOrder,
          items: orderItems,
          onChanged: onSortOrderChanged,
          prefixIcon: Icons.swap_vert,
        ),
        
        
      ],
    );
  }
}


