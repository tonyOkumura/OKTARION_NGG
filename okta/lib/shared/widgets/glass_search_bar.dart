import 'dart:ui';
import 'package:flutter/material.dart';

import 'glass_button.dart';
import 'glass_header_mode_toggle.dart';
import '../../core/enums/app_enums.dart';

class GlassSearchBar extends StatelessWidget {
  const GlassSearchBar({
    super.key,
    required this.searchController,
    this.onSearchChanged,
    this.onFilterPressed,
    this.onSortPressed,
    this.onAddPressed,
    this.viewModes = const [],
    this.currentViewMode = 0,
    this.onViewModeChanged,
    this.hintText = 'Поиск...',
    this.showFilterButton = true,
    this.showSortButton = true,
    this.showAddButton = false,
  });

  final TextEditingController searchController;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onFilterPressed;
  final VoidCallback? onSortPressed;
  final VoidCallback? onAddPressed;
  final List<ViewMode> viewModes;
  final int currentViewMode;
  final ValueChanged<int>? onViewModeChanged;
  final String hintText;
  final bool showFilterButton;
  final bool showSortButton;
  final bool showAddButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Кнопка добавления (самая первая)
              if (showAddButton) ...[
                GlassButton(
                  onPressed: onAddPressed,
                  padding: const EdgeInsets.all(8),
                  backgroundColor: cs.surface.withValues(alpha: 0.7),
                  borderColor: AppTheme.values[3].primaryColor.withValues(alpha: 0.3),
                  child: Icon(
                    Icons.add_outlined,
                    size: 20,
                    color: AppTheme.values[3].primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              
              // Кнопки фильтра и сортировки (primary цвета)
              if (showFilterButton) ...[
                GlassButton(
                  onPressed: onFilterPressed,
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.filter_list_outlined,
                    size: 20,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (showSortButton) ...[
                GlassButton(
                  onPressed: onSortPressed,
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.sort_outlined,
                    size: 20,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              
              // Поле поиска
              Expanded(
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    
                  ),
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 16,
                  ),
                ),
              ),
              
              // Переключатели представлений
              if (viewModes.isNotEmpty) ...[
                const SizedBox(width: 8),
                ...viewModes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final mode = entry.value;
                  // Используем разные акцентные цвета для каждого переключателя
                  final accentColor = AppTheme.values[index % AppTheme.values.length].primaryColor;
                  
                  return Padding(
                    padding: EdgeInsets.only(
                      left: index > 0 ? 4 : 0,
                    ),
                    child: GlassHeaderModeToggle(
                      active: currentViewMode == index,
                      tooltip: mode.tooltip,
                      icon: mode.icon,
                      onTap: () => onViewModeChanged?.call(index),
                      accentColor: accentColor,
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ViewMode {
  const ViewMode({
    required this.icon,
    required this.tooltip,
  });

  final IconData icon;
  final String tooltip;
}
