import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

import '../controllers/settings_controller.dart';
import '../widgets/sections.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;
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
                    AppearanceSection(controller: controller),
                    MessagesSection(controller: controller),
                    NotificationsSection(controller: controller),
                    PrivacySection(controller: controller),
                    const AboutSection(),
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