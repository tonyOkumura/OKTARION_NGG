import 'package:flutter/material.dart';
import '../../../../core/models/contact_model.dart';
import '../../../../shared/widgets/glass_avatar.dart';
import '../../../../shared/widgets/contact_popover.dart';
import '../../../../shared/widgets/glass_popover.dart';

/// Компактная плиточка контакта для списков
class ContactTile extends StatefulWidget {
  final Contact contact;
  final VoidCallback? onTap;
  final bool showOnlineStatus;
  final bool showRole;
  final EdgeInsetsGeometry? padding;
  final bool showPopover;
  final VoidCallback? onMessagePressed;
  final bool showHoverHighlight; // Новый параметр для выделения при наведении

  const ContactTile({
    super.key,
    required this.contact,
    this.onTap,
    this.showOnlineStatus = true,
    this.showRole = false,
    this.padding,
    this.showPopover = true,
    this.onMessagePressed,
    this.showHoverHighlight = false, // По умолчанию отключено
  });

  @override
  State<ContactTile> createState() => _ContactTileState();
}

class _ContactTileState extends State<ContactTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    Widget tileContent = Container(
      margin: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isHovered && widget.showHoverHighlight 
              ? cs.primary.withValues(alpha: 0.6) 
              : cs.outline.withValues(alpha: 0.15),
          width: _isHovered && widget.showHoverHighlight ? 2.0 : 1.0,
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Аватар
                Stack(
                  children: [
                    GlassAvatar(
                      label: widget.contact.displayNameOrUsername,
                      avatarUrl: widget.contact.hasAvatar ? widget.contact.avatarUrl : null,
                      radius: 24,
                    ),
                    if (widget.showOnlineStatus && widget.contact.isOnline)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: cs.surface,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(width: 12),
                
                // Информация
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Имя и роль
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.contact.displayNameOrUsername,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (widget.showRole && widget.contact.role != 'user') ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: cs.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.contact.role.toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      const SizedBox(height: 2),
                      
                      // Username
                      Text(
                        '@${widget.contact.username}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      // Статус сообщение
                      if (widget.contact.statusMessage != null && widget.contact.statusMessage!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.contact.statusMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Кнопка "написать"
                if (widget.onMessagePressed != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: cs.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: widget.onMessagePressed,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.message_outlined,
                            size: 18,
                            color: cs.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    // Если нужно выделение при наведении, оборачиваем в MouseRegion
    if (widget.showHoverHighlight) {
      tileContent = MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: tileContent,
      );
    }

    // Если поповер включен, оборачиваем в _ContactTileWithPopover
    if (widget.showPopover) {
      return _ContactTileWithPopover(
        contact: widget.contact,
        child: tileContent,
      );
    }

    return tileContent;
  }
}

/// Обертка для ContactTile с поддержкой поповера
class _ContactTileWithPopover extends StatefulWidget {
  final Contact contact;
  final Widget child;

  const _ContactTileWithPopover({
    required this.contact,
    required this.child,
  });

  @override
  State<_ContactTileWithPopover> createState() => _ContactTileWithPopoverState();
}

class _ContactTileWithPopoverState extends State<_ContactTileWithPopover> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _popoverEntry;
  bool _isHovering = false;
  Offset? _mousePosition;

  @override
  void dispose() {
    _closePopover();
    super.dispose();
  }

  void _showPopover(BuildContext buttonContext, Offset mousePosition) {
    if (_popoverEntry != null || !_isHovering) return;

    _popoverEntry = GlassPopoverUtils.showAtLink(
      context: context,
      targetContext: buttonContext,
      link: _layerLink,
      width: 300,
      height: 400,
      mouseOffset: mousePosition, // Передаем позицию мыши
      onDismiss: () => _popoverEntry = null,
      builder: (context) => ContactPopover(
        contact: widget.contact,
        onClose: _closePopover,
      ),
    );
  }

  void _closePopover() {
    _popoverEntry?.remove();
    _popoverEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (buttonContext) => CompositedTransformTarget(
        link: _layerLink,
        child: MouseRegion(
          onEnter: (_) {
            setState(() {
              _isHovering = true;
            });
          },
          onHover: (event) {
            setState(() {
              _mousePosition = event.localPosition;
            });
            // Небольшая задержка перед показом поповера
            Future.delayed(const Duration(milliseconds: 500), () {
              if (_isHovering && mounted && _mousePosition != null) {
                _showPopover(buttonContext, _mousePosition!);
              }
            });
          },
          onExit: (_) {
            setState(() {
              _isHovering = false;
              _mousePosition = null;
            });
            _closePopover();
          },
          child: widget.child,
        ),
      ),
    );
  }
}
