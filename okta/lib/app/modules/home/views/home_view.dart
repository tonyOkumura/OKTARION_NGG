import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

import '../../../../shared/widgets/widgets.dart';
import '../controllers/home_controller.dart';
import '../widgets/widgets.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildSkeletonView(context);
      }
      if (controller.errorText.value != null) {
        return Center(child: Text(controller.errorText.value!));
      }
      
      final theme = Theme.of(context);
      final cs = theme.colorScheme;
      
      return ClipRRect(
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
            child: ListView(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double maxW = constraints.maxWidth;
                    const double spacing = 16;
                    const double minTileWidth = 420;

                    int cols = math.max(
                      1,
                      ((maxW + spacing) / (minTileWidth + spacing)).floor(),
                    );
                    final items = <Widget>[
                      const HomeCardProfile(),
                      const HomeCardWelcome(),
                      const HomeCardTasksOverview(),
                      const HomeCardMessagesPreview(),
                      const HomeCardCalendar(),
                      const HomeCardNotifications(),
                    ];

                    cols = cols.clamp(1, items.length);
                    final double fullRowTileWidth =
                        (maxW - spacing * (cols - 1)) / cols;

                    final int fullRows = items.length ~/ cols;
                    final int remainder = items.length % cols;
                    final double lastRowTileWidth = remainder > 0
                        ? (maxW - spacing * (remainder - 1)) / remainder
                        : fullRowTileWidth;

                    final List<double> widths = List<double>.generate(
                      items.length,
                      (i) {
                        final bool isLastRow =
                            (remainder > 0) && (i >= fullRows * cols);
                        return isLastRow ? lastRowTileWidth : fullRowTileWidth;
                      },
                    );

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        for (int i = 0; i < items.length; i++)
                          SizedBox(width: widths[i], child: items[i]),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSkeletonView(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15)),
          ),
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final double maxW = constraints.maxWidth;
                  const double spacing = 16;
                  const double minTileWidth = 420;

                  int cols = math.max(
                    1,
                    ((maxW + spacing) / (minTileWidth + spacing)).floor(),
                  );
                  final items = <Widget>[
                    const HomeCardProfileSkeleton(),
                    const HomeCardWelcomeSkeleton(),
                    const HomeCardSkeleton(height: 300),
                    const HomeCardSkeleton(height: 300),
                    const HomeCardSkeleton(height: 300),
                    const HomeCardSkeleton(height: 300),
                  ];

                  cols = cols.clamp(1, items.length);
                  final double fullRowTileWidth =
                      (maxW - spacing * (cols - 1)) / cols;

                  final int fullRows = items.length ~/ cols;
                  final int remainder = items.length % cols;
                  final double lastRowTileWidth = remainder > 0
                      ? (maxW - spacing * (remainder - 1)) / remainder
                      : fullRowTileWidth;

                  final List<double> widths = List<double>.generate(
                    items.length,
                    (i) {
                      final bool isLastRow =
                          (remainder > 0) && (i >= fullRows * cols);
                      return isLastRow ? lastRowTileWidth : fullRowTileWidth;
                    },
                  );

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      for (int i = 0; i < items.length; i++)
                        SizedBox(width: widths[i], child: items[i]),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
