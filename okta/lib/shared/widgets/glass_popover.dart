import 'dart:ui';

import 'package:flutter/material.dart';

class GlassPopover extends StatelessWidget {
  const GlassPopover({
    super.key,
    required this.child,
    this.title,
    this.leading,
    this.onClose,
    this.closeIcon,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(12),
  });

  final Widget child;
  final String? title;
  final Widget? leading;
  final VoidCallback? onClose;
  final IconData? closeIcon;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final Widget header = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 8)],
          Expanded(
            child: Text(
              title ?? '',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(closeIcon ?? Icons.refresh_rounded),
            visualDensity: VisualDensity.compact,
            tooltip: 'Сбросить',
          ),
        ],
      ),
    );

    final box = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              Divider(color: cs.outlineVariant, height: 1),
              Flexible(
                child: Padding(padding: padding, child: child),
              ),
            ],
          ),
        ),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: box,
      ),
    );
  }
}

typedef _Placement =
    Offset Function(Rect anchor, Size overlay, Size popover, EdgeInsets margin);

class GlassPopoverUtils {
  static OverlayEntry showAtLink({
    required BuildContext context,
    required BuildContext targetContext,
    required LayerLink link,
    required WidgetBuilder builder,
    double width = 320,
    double height = 300,
    EdgeInsets margin = const EdgeInsets.all(8),
    List<_Placement>? placements,
    VoidCallback? onDismiss,
  }) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) {
      throw StateError('No Overlay found in the given context');
    }

    final List<_Placement> order =
        placements ??
        <_Placement>[
          // below
          (anchor, overlaySize, popSize, m) =>
              Offset((anchor.width - popSize.width) / 2, anchor.height + m.top),
          // above
          (anchor, overlaySize, popSize, m) => Offset(
            (anchor.width - popSize.width) / 2,
            -popSize.height - m.bottom,
          ),
          // right
          (anchor, overlaySize, popSize, m) => Offset(
            anchor.width + m.left,
            (anchor.height - popSize.height) / 2,
          ),
          // left
          (anchor, overlaySize, popSize, m) => Offset(
            -popSize.width - m.right,
            (anchor.height - popSize.height) / 2,
          ),
        ];

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) {
        final mq = MediaQuery.of(context);
        final overlaySize = mq.size;

        final targetBox = targetContext.findRenderObject() as RenderBox?;
        final anchor = targetBox == null
            ? Rect.zero
            : (targetBox.localToGlobal(Offset.zero) & targetBox.size);

        final popSize = Size(width, height);

        // Debug info
        print('GlassPopoverUtils: targetBox = $targetBox');
        print('GlassPopoverUtils: anchor = $anchor');
        print('GlassPopoverUtils: overlaySize = $overlaySize');
        print('GlassPopoverUtils: popSize = $popSize');

        // choose best placement
        Offset rel = order.first(anchor, overlaySize, popSize, margin);

        // clamp to overlay by adjusting relative offset
        double globalX = anchor.left + rel.dx;
        double globalY = anchor.top + rel.dy;
        globalX = globalX.clamp(
          margin.left,
          overlaySize.width - width - margin.right,
        );
        globalY = globalY.clamp(
          margin.top,
          overlaySize.height - height - margin.bottom,
        );
        final Offset followerOffset = Offset(
          globalX - anchor.left,
          globalY - anchor.top,
        );

        // Debug final positioning
        print('GlassPopoverUtils: globalX = $globalX, globalY = $globalY');
        print('GlassPopoverUtils: followerOffset = $followerOffset');

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTapDown: (details) {
                  // Close by outside tap
                  print('GlassPopoverUtils: Outside tap detected, closing popover');
                  if (entry.mounted) {
                    entry.remove();
                    onDismiss?.call();
                  }
                },
                behavior: HitTestBehavior.translucent,
                child: const SizedBox(),
              ),
            ),
            CompositedTransformFollower(
              link: link,
              showWhenUnlinked: false,
              offset: followerOffset,
              child: SizedBox(
                width: width,
                height: height,
                child: Builder(builder: builder),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(entry);
    return entry;
  }
}
