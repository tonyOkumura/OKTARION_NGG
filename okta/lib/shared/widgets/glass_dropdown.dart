import 'package:flutter/material.dart';
import 'dart:ui';

/// Базовый стеклянный контейнер для элементов ввода
class _GlassContainer extends StatelessWidget {
  const _GlassContainer({
    required this.child,
    this.borderRadius = 12,
    this.padding,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: cs.surface.withOpacity(0.35),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: cs.primary.withOpacity(0.25),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Простой стеклянный Dropdown без лейбла
class GlassDropdown<T> extends StatelessWidget {
  const GlassDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.icon,
    this.enabled = true,
  });

  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final Widget? hint;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Widget? icon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return _GlassContainer(
      borderRadius: borderRadius,
      padding: padding,
      child: _GlassSelect<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        enabled: enabled,
        hint: hint,
        icon: icon ?? Icon(Icons.arrow_drop_down_rounded, color: cs.primary),
        borderRadius: borderRadius,
      ),
    );
  }
}

/// Dropdown со стильным лейблом и иконкой, как у текстовых полей
class GlassDropdownField<T> extends StatelessWidget {
  const GlassDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.icon,
    this.helperText,
    this.errorText,
    this.prefixIcon,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final IconData? icon; // устар.
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Row(
            children: [
              if (prefixIcon != null)
                Icon(prefixIcon, size: 16, color: cs.primary),
              if (prefixIcon != null) const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        _GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: _GlassSelect<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            icon: Icon(Icons.arrow_drop_down_rounded, color: cs.primary),
            borderRadius: 12,
          ),
        ),
        if (helperText != null && (errorText == null))
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 6),
            child: Text(
              helperText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 6),
            child: Text(
              errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

/// Внутренняя реализация выпадающего списка с оверлеем поверх всего UI
class _GlassSelect<T> extends StatefulWidget {
  const _GlassSelect({
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.icon,
    this.enabled = true,
    this.borderRadius = 12,
  });

  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final Widget? hint;
  final Widget? icon;
  final bool enabled;
  final double borderRadius;

  @override
  State<_GlassSelect<T>> createState() => _GlassSelectState<T>();
}

class _GlassSelectState<T> extends State<_GlassSelect<T>> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;
  bool _isOpen = false;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _toggle() {
    if (!widget.enabled) return;
    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    _entry = OverlayEntry(
      builder: (ctx) {
        final RenderBox? box = context.findRenderObject() as RenderBox?;
        final Size fieldSize = box?.size ?? const Size(220, 40);
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removeOverlay,
                child: const SizedBox(),
              ),
            ),
            CompositedTransformFollower(
              link: _link,
              showWhenUnlinked: false,
              offset: Offset(0, fieldSize.height + 8),
              child: Material(
                type: MaterialType.transparency,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 280),
                      width: fieldSize.width,
                      decoration: BoxDecoration(
                        color: cs.surface.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(widget.borderRadius),
                        border: Border.all(color: cs.primary.withOpacity(0.25), width: 1),
                      ),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shrinkWrap: true,
                        itemBuilder: (c, i) {
                          final item = widget.items[i];
                          final T? val = item.value;
                          final bool selected = val == widget.value;
                          return InkWell(
                            onTap: () {
                              widget.onChanged(val);
                              _removeOverlay();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: selected ? cs.primary.withOpacity(0.12) : Colors.transparent,
                                border: Border(
                                  left: BorderSide(color: selected ? cs.primary : Colors.transparent, width: 2),
                                ),
                              ),
                              child: DefaultTextStyle(
                                style: theme.textTheme.bodyMedium!.copyWith(color: cs.onSurface),
                                child: Row(
                                  children: [
                                    Expanded(child: item.child),
                                    if (selected) Icon(Icons.check_rounded, size: 18, color: cs.primary),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => Divider(height: 1, color: cs.primary.withOpacity(0.15)),
                        itemCount: widget.items.length,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_entry!);
    setState(() => _isOpen = true);
  }

  void _removeOverlay() {
    _entry?.remove();
    _entry = null;
    if (_isOpen) setState(() => _isOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final currentItem = widget.items.firstWhere(
      (it) => it.value == widget.value,
      orElse: () => DropdownMenuItem<T>(value: null, child: const SizedBox.shrink()),
    );

    final Widget displayChild;
    if (widget.value == null) {
      displayChild = widget.hint ?? Text(
        '-',
        style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
      );
    } else {
      displayChild = currentItem.child;
    }

    return CompositedTransformTarget(
      link: _link,
      child: InkWell(
        onTap: _toggle,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: DefaultTextStyle(
                    style: theme.textTheme.bodyMedium!.copyWith(color: cs.onSurface),
                    child: displayChild,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              widget.icon ?? Icon(Icons.arrow_drop_down_rounded, color: cs.primary),
            ],
          ),
        ),
      ),
    );
  }
}


