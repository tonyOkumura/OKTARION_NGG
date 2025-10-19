import 'package:flutter/material.dart';

class GlassHeaderModeToggle extends StatefulWidget {
  const GlassHeaderModeToggle({
    super.key,
    required this.active,
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.colorScheme,
    this.accentColor,
  });

  final bool active;
  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme? colorScheme;
  final Color? accentColor;

  @override
  State<GlassHeaderModeToggle> createState() => _GlassHeaderModeToggleState();
}

class _GlassHeaderModeToggleState extends State<GlassHeaderModeToggle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
  }

  @override
  void didUpdateWidget(covariant GlassHeaderModeToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = widget.colorScheme ?? Theme.of(context).colorScheme;
    final Color accentColor = widget.accentColor ?? cs.primary;
    return Tooltip(
      message: widget.tooltip,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: widget.active
              ? accentColor.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: widget.active
                ? accentColor.withValues(alpha: 0.35)
                : cs.outline.withValues(alpha: 0.12),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              onPressed: widget.onTap,
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: Icon(
                  widget.icon,
                  key: ValueKey<bool>(widget.active),
                  color: widget.active ? (accentColor) : cs.onSurfaceVariant,
                ),
              ),
            ),
            IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final t = _controller.value;
                  final align = Alignment(-1 + 2 * t, 0);
                  return Opacity(
                    opacity: (1 - (t - 0.5).abs() * 2) * 0.6,
                    child: Align(
                      alignment: align,
                      child: Container(
                        width: 34,
                        height: 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white.withValues(alpha: 0.25),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
