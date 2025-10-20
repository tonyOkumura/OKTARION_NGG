import 'package:flutter/material.dart';
import '../../../../core/models/contact_model.dart';
import '../../../../shared/widgets/glass_avatar.dart';

/// Переиспользуемая карточка контакта
class ContactCard extends StatelessWidget {
  final Contact contact;
  final VoidCallback? onTap;
  final bool showOnlineStatus;
  final bool showRole;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const ContactCard({
    super.key,
    required this.contact,
    this.onTap,
    this.showOnlineStatus = true,
    this.showRole = false,
    this.padding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Аватар
              Stack(
                children: [
                  GlassAvatar(
                    label: contact.displayNameOrUsername,
                    avatarUrl: contact.hasAvatar ? contact.avatarUrl : null,
                    radius: 32,
                  ),
                  if (showOnlineStatus && contact.isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
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
              
              const SizedBox(height: 12),
              
              // Имя
              Text(
                contact.displayNameOrUsername,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Username
              Text(
                '@${contact.username}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              if (showRole && contact.role != 'user') ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    contact.role.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              
              if (contact.statusMessage != null && contact.statusMessage!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  contact.statusMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
