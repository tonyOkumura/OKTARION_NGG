import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import '../../core/models/contact_model.dart';
import '../../core/utils/screen_type_helper.dart';
import '../../core/config/work_types.dart';
import 'glass_dialog.dart';
import 'glass_dropdown.dart';
import 'glass_avatar.dart';
import 'glass_text_field.dart';

/// Диалог редактирования контакта
class ContactEditingDialog extends StatelessWidget {
  ContactEditingDialog({
    super.key,
    required this.contact,
    this.onSave,
  });

  final Contact contact;
  final Future<void> Function(Contact updatedContact)? onSave;
  
  final GlobalKey<_ContactEditingFormState> _formKey = GlobalKey<_ContactEditingFormState>();

  @override
  Widget build(BuildContext context) {
    final screenType = ScreenTypeHelper.getScreenTypeFromContext(context);
    final size = MediaQuery.of(context).size;

    // Адаптивные размеры диалога
    final double dialogWidth = _getAdaptiveDialogWidth(size.width, screenType);
    final double? dialogHeight = _getAdaptiveDialogHeight(size.height, screenType);

    return GlassDialog(
      title: 'Редактировать контакт',
      width: dialogWidth,
      height: dialogHeight,
      onConfirm: () => _handleSave(context),
      child: _ContactEditingForm(
        key: _formKey,
        contact: contact,
        onContactChanged: (updatedContact) {
          // Здесь можно обновить локальное состояние
        },
      ),
    );
  }

  double _getAdaptiveDialogWidth(double screenWidth, ScreenType screenType) {
    switch (screenType) {
      case ScreenType.phone:
        return screenWidth * 0.95; // почти на всю ширину
      case ScreenType.mobile:
        return screenWidth * 0.9;
      case ScreenType.tablet:
        return 650; // шире на планшетах
      case ScreenType.laptop:
        return 600;
      case ScreenType.desktop:
        return 560;
    }
  }

  double? _getAdaptiveDialogHeight(double screenHeight, ScreenType screenType) {
    switch (screenType) {
      case ScreenType.phone:
        return screenHeight * 0.85; // почти на всю высоту
      case ScreenType.mobile:
        return screenHeight * 0.8;
      case ScreenType.tablet:
        return 700; // фиксированная высота на планшетах
      case ScreenType.laptop:
        return 650;
      case ScreenType.desktop:
        return 600;
    }
  }

  void _handleSave(BuildContext context) async {
    final formState = _formKey.currentState;
    
    if (formState != null && formState._formKey.currentState?.validate() == true) {
      final updatedContact = formState._buildUpdatedContact();
      
      try {
        // Ждем завершения операции сохранения
        await onSave?.call(updatedContact);
        
        // Используем GetX навигацию вместо Navigator.of(context)
        Get.back();
      } catch (e) {
        // Не закрываем диалог при ошибке, чтобы пользователь мог попробовать снова
      }
    }
  }
}

/// Форма редактирования контакта
class _ContactEditingForm extends StatefulWidget {
  const _ContactEditingForm({
    super.key,
    required this.contact,
    required this.onContactChanged,
  });

  final Contact contact;
  final Function(Contact) onContactChanged;

  @override
  State<_ContactEditingForm> createState() => _ContactEditingFormState();
}

class _ContactEditingFormState extends State<_ContactEditingForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _displayNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  StatusType? _status;
  PositionType? _position;
  DepartmentType? _department;
  RankType? _rank;
  CompanyType? _company;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _firstNameController = TextEditingController(text: widget.contact.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.contact.lastName ?? '');
    _displayNameController = TextEditingController(text: widget.contact.displayName ?? '');
    _emailController = TextEditingController(text: widget.contact.email ?? '');
    _phoneController = TextEditingController(text: widget.contact.phone ?? '');
    _status = WorkTypesParser.statusFromString(widget.contact.statusMessage);
    _department = WorkTypesParser.departmentFromString(widget.contact.department);
    _rank = WorkTypesParser.rankFromString(widget.contact.rank);
    _position = WorkTypesParser.positionFromString(widget.contact.position);
    _company = WorkTypesParser.companyFromString(widget.contact.company);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _displayNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final screenType = ScreenTypeHelper.getScreenTypeFromContext(context);
    final isWide = screenType == ScreenType.tablet ||
        screenType == ScreenType.laptop ||
        screenType == ScreenType.desktop;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          _buildAvatarSection(theme, cs),
          const SizedBox(height: 24),

          // Личная информация (1 колонка на узких, 2 на широких)
          _buildSection(
            theme,
            cs,
            'Личная информация',
            Icons.person_outline,
            isWide
                ? [
                    Row(
                      children: [
                        Expanded(
                          child: GlassTextField(
                            controller: _firstNameController,
                            label: 'Имя',
                            prefixIcon: Icons.person_outline,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GlassTextField(
                            controller: _lastNameController,
                            label: 'Фамилия',
                            prefixIcon: Icons.person_outline,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: GlassTextField(
                            controller: _displayNameController,
                            label: 'Отображаемое имя',
                            prefixIcon: Icons.badge_outlined,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: GlassTextField(
                            controller: _emailController,
                            label: 'Email',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GlassTextField(
                            controller: _phoneController,
                            label: 'Телефон',
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                  ]
                : [
                    GlassTextField(
                      controller: _firstNameController,
                      label: 'Имя',
                      prefixIcon: Icons.person_outline,
                    ),
                    GlassTextField(
                      controller: _lastNameController,
                      label: 'Фамилия',
                      prefixIcon: Icons.person_outline,
                    ),
                    GlassTextField(
                      controller: _displayNameController,
                      label: 'Отображаемое имя',
                      prefixIcon: Icons.badge_outlined,
                    ),
                    GlassTextField(
                      controller: _emailController,
                      label: 'Email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    GlassTextField(
                      controller: _phoneController,
                      label: 'Телефон',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
          ),
          const SizedBox(height: 24),

          // Рабочая информация (переведено на выпадающие списки)
          _buildSection(
            theme,
            cs,
            'Рабочая информация',
            Icons.work_outline,
            isWide
                ? [
                    Row(
                      children: [
                        Expanded(
                          child: GlassDropdownField<CompanyType>(
                            label: 'Управление',
                            value: _company,
                            items: WorkTypesLabels.buildDropdownItems(
                              CompanyType.values,
                              WorkTypesLabels.company,
                            ),
                            onChanged: (v) => setState(() => _company = v),
                            prefixIcon: Icons.business,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GlassDropdownField<DepartmentType>(
                            label: 'Отдел',
                            value: _department,
                            items: WorkTypesLabels.buildDropdownItems(
                              DepartmentType.values,
                              WorkTypesLabels.department,
                            ),
                            onChanged: (v) => setState(() => _department = v),
                            prefixIcon: Icons.business_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GlassDropdownField<PositionType>(
                            label: 'Должность',
                            value: _position,
                            items: WorkTypesLabels.buildDropdownItems(
                              PositionType.values,
                              WorkTypesLabels.position,
                            ),
                            onChanged: (v) => setState(() => _position = v),
                            prefixIcon: Icons.work_outline,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GlassDropdownField<RankType>(
                            label: 'Звание',
                            value: _rank,
                            items: WorkTypesLabels.buildDropdownItems(
                              RankType.values,
                              WorkTypesLabels.rank,
                            ),
                            onChanged: (v) => setState(() => _rank = v),
                            prefixIcon: Icons.military_tech_outlined,
                          ),
                        ),
                      ],
                    ),
                  ]
                : [
                    GlassDropdownField<CompanyType>(
                      label: 'Управление',
                      value: _company,
                      items: WorkTypesLabels.buildDropdownItems(
                        CompanyType.values,
                        WorkTypesLabels.company,
                      ),
                      onChanged: (v) => setState(() => _company = v),
                      prefixIcon: Icons.business,
                    ),
                    GlassDropdownField<DepartmentType>(
                      label: 'Отдел',
                      value: _department,
                      items: WorkTypesLabels.buildDropdownItems(
                        DepartmentType.values,
                        WorkTypesLabels.department,
                      ),
                      onChanged: (v) => setState(() => _department = v),
                      prefixIcon: Icons.business_outlined,
                    ),
                    GlassDropdownField<PositionType>(
                      label: 'Должность',
                      value: _position,
                      items: WorkTypesLabels.buildDropdownItems(
                        PositionType.values,
                        WorkTypesLabels.position,
                      ),
                      onChanged: (v) => setState(() => _position = v),
                      prefixIcon: Icons.work_outline,
                    ),
                    GlassDropdownField<RankType>(
                      label: 'Звание',
                      value: _rank,
                      items: WorkTypesLabels.buildDropdownItems(
                        RankType.values,
                        WorkTypesLabels.rank,
                      ),
                      onChanged: (v) => setState(() => _rank = v),
                      prefixIcon: Icons.military_tech_outlined,
                    ),
                  ],
          ),
          const SizedBox(height: 24),

          // Дополнительно (статус выбора вместо свободного текста)
          _buildSection(
            theme,
            cs,
            'Дополнительно',
            Icons.info_outline,
            isWide
                ? [
                    GlassDropdownField<StatusType>(
                      label: 'Статус',
                      value: _status,
                      items: WorkTypesLabels.buildDropdownItems(
                        StatusType.values,
                        WorkTypesLabels.status,
                      ),
                      onChanged: (v) => setState(() => _status = v),
                      prefixIcon: Icons.message_outlined,
                    ),
                  ]
                : [
                    GlassDropdownField<StatusType>(
                      label: 'Статус',
                      value: _status,
                      items: WorkTypesLabels.buildDropdownItems(
                        StatusType.values,
                        WorkTypesLabels.status,
                      ),
                      onChanged: (v) => setState(() => _status = v),
                      prefixIcon: Icons.message_outlined,
                    ),
                  ],
          ),
        ],
      ),)
    );
  }

  Widget _buildAvatarSection(ThemeData theme, ColorScheme cs) {
    return Center(
      child: Column(
        children: [
          GlassAvatar(
            label: widget.contact.displayNameOrUsername,
            avatarUrl: widget.contact.hasAvatar ? widget.contact.avatarUrl : null,
            radius: 50,
          ),
          const SizedBox(height: 12),
          Text(
            widget.contact.displayNameOrUsername,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '@${widget.contact.username}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    ThemeData theme,
    ColorScheme cs,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: cs.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),
      ),
    );
  }

  /// Создать обновленный контакт из данных формы
  Contact _buildUpdatedContact() {
    return Contact(
      id: widget.contact.id,
      username: widget.contact.username,
      firstName: _firstNameController.text.isNotEmpty ? _firstNameController.text : null,
      lastName: _lastNameController.text.isNotEmpty ? _lastNameController.text : null,
      displayName: _displayNameController.text.isNotEmpty ? _displayNameController.text : null,
      email: _emailController.text.isNotEmpty ? _emailController.text : null,
      phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      isOnline: widget.contact.isOnline,
      lastSeenAt: widget.contact.lastSeenAt,
      statusMessage: _status != null ? WorkTypesLabels.status(_status!) : null,
      role: widget.contact.role,
      department: _department != null ? WorkTypesLabels.department(_department!) : null,
      rank: _rank != null ? WorkTypesLabels.rank(_rank!) : null,
      position: _position != null ? WorkTypesLabels.position(_position!) : null,
      company: _company != null ? WorkTypesLabels.company(_company!) : null,
      avatarUrl: widget.contact.avatarUrl,
      dateOfBirth: widget.contact.dateOfBirth,
      locale: widget.contact.locale,
      timezone: widget.contact.timezone,
      createdAt: widget.contact.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // удалён локальный builder дропдауна — используем GlassDropdownField
}
