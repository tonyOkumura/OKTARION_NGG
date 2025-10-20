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
    Offset? mouseOffset, // Добавляем позицию мыши
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

        // Если есть позиция мыши, используем умное позиционирование
        Offset rel;
        if (mouseOffset != null) {
          // Умное позиционирование относительно мыши
          rel = _calculateSmartMousePosition(
            mouseOffset, 
            overlaySize, 
            popSize, 
            margin
          );
        } else {
          // Используем стандартное позиционирование
          rel = order.first(anchor, overlaySize, popSize, margin);
        }

        // Debug info
        print('GlassPopoverUtils: targetBox = $targetBox');
        print('GlassPopoverUtils: anchor = $anchor');
        print('GlassPopoverUtils: overlaySize = $overlaySize');
        print('GlassPopoverUtils: popSize = $popSize');
        print('GlassPopoverUtils: mouseOffset = $mouseOffset');
        print('GlassPopoverUtils: rel = $rel');

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

  /// Умное позиционирование поповера относительно позиции мыши
  static Offset _calculateSmartMousePosition(
    Offset mouseOffset,
    Size overlaySize,
    Size popSize,
    EdgeInsets margin,
  ) {
    // Смещение поповера относительно мыши (чтобы не перекрывать курсор)
    const mouseOffsetX = 15.0; // Отступ от курсора по X
    const mouseOffsetY = 15.0; // Отступ от курсора по Y
    
    // Определяем центр экрана
    final screenCenterX = overlaySize.width / 2;
    
    // Определяем, в какой половине экрана находится мышь
    final isMouseOnLeftSide = mouseOffset.dx < screenCenterX;
    
    print('GlassPopoverUtils: Mouse at ${mouseOffset.dx}, screen center: $screenCenterX, isLeftSide: $isMouseOnLeftSide');
    
    // Пробуем разные позиции в порядке приоритета
    final positions = <Offset>[];

    if (isMouseOnLeftSide) {
      // Мышь слева от центра - привязываем ЛЕВЫЙ край поповера к мыши
      print('GlassPopoverUtils: Using LEFT edge positioning');
      
      // 1. Левый край рядом с мышью - снизу справа
      positions.add(Offset(mouseOffset.dx + mouseOffsetX, mouseOffset.dy + mouseOffsetY));
      
      // 2. Левый край рядом с мышью - сверху справа
      positions.add(Offset(mouseOffset.dx + mouseOffsetX, mouseOffset.dy - popSize.height - mouseOffsetY));
      
      // 3. Левый край рядом с мышью - по центру справа
      positions.add(Offset(mouseOffset.dx + mouseOffsetX, mouseOffset.dy - popSize.height / 2));
      
      // 4. Левый край рядом с мышью - снизу слева (если справа не помещается)
      positions.add(Offset(mouseOffset.dx - popSize.width - mouseOffsetX, mouseOffset.dy + mouseOffsetY));
      
      // 5. Левый край рядом с мышью - сверху слева (если справа не помещается)
      positions.add(Offset(mouseOffset.dx - popSize.width - mouseOffsetX, mouseOffset.dy - popSize.height - mouseOffsetY));
      
      // 6. Левый край рядом с мышью - по центру слева (если справа не помещается)
      positions.add(Offset(mouseOffset.dx - popSize.width - mouseOffsetX, mouseOffset.dy - popSize.height / 2));
      
    } else {
      // Мышь справа от центра - привязываем ПРАВЫЙ край поповера к мыши
      print('GlassPopoverUtils: Using RIGHT edge positioning');
      
      // 1. Правый край рядом с мышью - снизу слева
      positions.add(Offset(mouseOffset.dx - popSize.width - mouseOffsetX, mouseOffset.dy + mouseOffsetY));
      
      // 2. Правый край рядом с мышью - сверху слева
      positions.add(Offset(mouseOffset.dx - popSize.width - mouseOffsetX, mouseOffset.dy - popSize.height - mouseOffsetY));
      
      // 3. Правый край рядом с мышью - по центру слева
      positions.add(Offset(mouseOffset.dx - popSize.width - mouseOffsetX, mouseOffset.dy - popSize.height / 2));
      
      // 4. Правый край рядом с мышью - снизу справа (если слева не помещается)
      positions.add(Offset(mouseOffset.dx + mouseOffsetX, mouseOffset.dy + mouseOffsetY));
      
      // 5. Правый край рядом с мышью - сверху справа (если слева не помещается)
      positions.add(Offset(mouseOffset.dx + mouseOffsetX, mouseOffset.dy - popSize.height - mouseOffsetY));
      
      // 6. Правый край рядом с мышью - по центру справа (если слева не помещается)
      positions.add(Offset(mouseOffset.dx + mouseOffsetX, mouseOffset.dy - popSize.height / 2));
    }
    
    // Дополнительные варианты - по центру относительно курсора
    positions.add(Offset(mouseOffset.dx - popSize.width / 2, mouseOffset.dy - popSize.height - mouseOffsetY)); // Центр сверху
    positions.add(Offset(mouseOffset.dx - popSize.width / 2, mouseOffset.dy + mouseOffsetY)); // Центр снизу
    
    // Выбираем первую позицию, которая помещается на экране
    for (final position in positions) {
      // Проверяем, помещается ли поповер на экране
      if (position.dx >= margin.left &&
          position.dx + popSize.width <= overlaySize.width - margin.right &&
          position.dy >= margin.top &&
          position.dy + popSize.height <= overlaySize.height - margin.bottom) {
        
        print('GlassPopoverUtils: Smart positioning - using position: $position');
        print('GlassPopoverUtils: Mouse offset: $mouseOffset');
        
        // Возвращаем позицию относительно anchor (который будет использоваться в расчетах)
        return Offset(position.dx, position.dy);
      }
    }
    
    // Если ничего не подходит, используем первую позицию и позволим clamp исправить
    print('GlassPopoverUtils: Smart positioning - fallback to default position');
    return positions.first;
  }
}
