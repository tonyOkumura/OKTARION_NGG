import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'glass_card.dart';

class HomeCard extends StatefulWidget {
  const HomeCard({
    super.key,
    required this.title,
    required this.child,
    this.showPagination = false,
    this.totalItemsRx,
    this.itemsPerPage = 10,
    this.childBuilder,
    this.height = 300,
  });

  final String title;
  final Widget child;
  final bool showPagination;
  final RxInt? totalItemsRx;
  final int itemsPerPage;
  final Widget Function(int currentPage, int itemsPerPage)? childBuilder;
  final double height;

  @override
  State<HomeCard> createState() => _HomeCardState();
}

class _HomeCardState extends State<HomeCard> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (widget.showPagination && widget.totalItemsRx != null && widget.childBuilder != null) {
      return Obx(() {
        final totalItems = widget.totalItemsRx!.value;
        final totalPages = (totalItems / widget.itemsPerPage).ceil();

        if (_currentPage >= totalPages && totalPages > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _currentPage = 0;
            });
          });
        }

        final startIndex = _currentPage * widget.itemsPerPage;
        final endIndex = (startIndex + widget.itemsPerPage).clamp(0, totalItems);
        final pageInfo = '${startIndex + 1}-${endIndex} из ${totalItems}';

        return _buildCard(
          theme: theme,
          cs: cs,
          showPagination: totalPages > 1,
          currentPage: _currentPage,
          totalPages: totalPages,
          pageInfo: totalPages > 1 ? pageInfo : null,
          child: widget.childBuilder!(_currentPage, widget.itemsPerPage),
        );
      });
    }

    return _buildCard(
      theme: theme,
      cs: cs,
      showPagination: false,
      currentPage: 0,
      totalPages: 1,
      pageInfo: null,
      child: widget.child,
    );
  }

  Widget _buildCard({
    required ThemeData theme,
    required ColorScheme cs,
    required bool showPagination,
    required int currentPage,
    required int totalPages,
    required String? pageInfo,
    required Widget child,
  }) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 64,
              child: Row(
                children: [
                  if (showPagination)
                    IconButton(
                      onPressed: currentPage > 0
                          ? () {
                              setState(() {
                                _currentPage--;
                              });
                            }
                          : null,
                      icon: const Icon(Icons.chevron_left),
                      iconSize: 20,
                      tooltip: 'Предыдущая страница',
                    ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          widget.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (showPagination && pageInfo != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              pageInfo,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (showPagination)
                    IconButton(
                      onPressed: currentPage < totalPages - 1
                          ? () {
                              setState(() {
                                _currentPage++;
                              });
                            }
                          : null,
                      icon: const Icon(Icons.chevron_right),
                      iconSize: 20,
                      tooltip: 'Следующая страница',
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(height: widget.height, child: child),
          ],
        ),
      ),
    );
  }
}
