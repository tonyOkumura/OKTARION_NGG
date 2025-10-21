import 'package:flutter/material.dart';
import '../../core/models/contact_model.dart';
import 'glass_avatar.dart';
import 'contact_editing_dialog.dart';

/// Поповер с детальной информацией о контакте
class ContactPopover extends StatelessWidget {
  final Contact contact;
  final VoidCallback? onClose;

  const ContactPopover({
    super.key,
    required this.contact,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок с аватаром и именем
              Row(
                children: [
                  GlassAvatar(
                    label: contact.displayNameOrUsername,
                    avatarUrl: contact.hasAvatar ? contact.avatarUrl : null,
                    radius: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact.displayNameOrUsername,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '@${contact.username}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
               
                ],
              ),

              const SizedBox(height: 16),

              // Статус онлайн
              if (contact.isOnline) ...[
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'В сети',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Статус сообщение
              if (contact.statusMessage != null && contact.statusMessage!.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.surfaceVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    contact.statusMessage!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Детальная информация
              _buildInfoSection(
                theme,
                cs,
                'Основная информация',
                [
                  _buildInfoRow(theme, cs, Icons.email_outlined, 'Email', contact.email ?? 'Не указано'),
                  _buildInfoRow(theme, cs, Icons.phone_outlined, 'Телефон', contact.phone ?? 'Не указано'),
                  _buildInfoRow(theme, cs, Icons.person_outline, 'Имя', contact.firstName ?? 'Не указано'),
                  _buildInfoRow(theme, cs, Icons.person_outline, 'Фамилия', contact.lastName ?? 'Не указано'),
                  _buildInfoRow(theme, cs, Icons.work_outline, 'Должность', contact.position ?? 'Не указано'),
                  _buildInfoRow(theme, cs, Icons.business_outlined, 'Отдел', contact.department ?? 'Не указано'),
                  _buildInfoRow(theme, cs, Icons.business, 'Компания', contact.company ?? 'Не указано'),
                  _buildInfoRow(theme, cs, Icons.military_tech_outlined, 'Звание', contact.rank ?? 'Не указано'),
                ],
              ),

              // Дополнительная информация
              if (contact.dateOfBirth != null || contact.lastSeenAt != null) ...[
                const SizedBox(height: 12),
                _buildInfoSection(
                  theme,
                  cs,
                  'Дополнительно',
                  [
                    if (contact.dateOfBirth != null)
                      _buildInfoRow(theme, cs, Icons.cake_outlined, 'Дата рождения', _formatDate(contact.dateOfBirth!)),
                    if (contact.lastSeenAt != null)
                      _buildInfoRow(theme, cs, Icons.access_time_outlined, 'Последний раз в сети', _formatLastSeen(contact.lastSeenAt!)),
                  ],
                ),
              ],

              // Роль и права
              if (contact.role != 'user') ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

              // Дата создания
              const SizedBox(height: 12),
              Text(
                'Зарегистрирован: ${_formatDate(contact.createdAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    ThemeData theme,
    ColorScheme cs,
    String title,
    List<Widget> children,
  ) {
    if (children.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelMedium?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    ColorScheme cs,
    IconData icon,
    String label,
    String value,
  ) {
    final isNotSpecified = value == 'Не указано';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isNotSpecified ? cs.onSurfaceVariant.withValues(alpha: 0.5) : cs.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: isNotSpecified ? cs.onSurfaceVariant.withValues(alpha: 0.7) : null,
                fontStyle: isNotSpecified ? FontStyle.italic : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'сегодня';
    } else if (difference.inDays == 1) {
      return 'вчера';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} дн. назад';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks нед. назад';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'только что';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} мин. назад';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ч. назад';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} дн. назад';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks нед. назад';
    } else {
      return '${lastSeen.day}.${lastSeen.month}.${lastSeen.year}';
    }
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ContactEditingDialog(
        contact: contact,
        onSave: (updatedContact) {
          // TODO: Обновить контакт в списке
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Контакт ${updatedContact.displayNameOrUsername} обновлен'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }
}
