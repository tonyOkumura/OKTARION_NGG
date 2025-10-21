import 'package:flutter/material.dart';

import '../../../../core/config/work_types.dart';
import '../../../../shared/widgets/glass_dropdown.dart';


class ContactsFiltersWidget extends StatelessWidget {
  const ContactsFiltersWidget({
    super.key,
    this.query,
    this.onQueryChanged,
    this.department,
    this.onDepartmentChanged,
    this.company,
    this.onCompanyChanged,
    this.position,
    this.onPositionChanged,
    this.rank,
    this.onRankChanged,
    this.status,
    this.onStatusChanged,
    this.onApply,
    this.onClear,
  });

  final String? query;
  final ValueChanged<String>? onQueryChanged;

  final DepartmentType? department;
  final ValueChanged<DepartmentType?>? onDepartmentChanged;

  final CompanyType? company;
  final ValueChanged<CompanyType?>? onCompanyChanged;

  final PositionType? position;
  final ValueChanged<PositionType?>? onPositionChanged;

  final RankType? rank;
  final ValueChanged<RankType?>? onRankChanged;

  final StatusType? status;
  final ValueChanged<StatusType?>? onStatusChanged;

  final VoidCallback? onApply;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassDropdownField<DepartmentType>(
            label: 'Отдел',
            value: department,
            items: WorkTypesLabels.buildDropdownItems(
              DepartmentType.values,
              WorkTypesLabels.department,
            ),
            onChanged: (v) => onDepartmentChanged?.call(v),
            prefixIcon: Icons.business_outlined,
          ),
          GlassDropdownField<CompanyType>(
            label: 'Компания',
            value: company,
            items: WorkTypesLabels.buildDropdownItems(
              CompanyType.values,
              WorkTypesLabels.company,
            ),
            onChanged: (v) => onCompanyChanged?.call(v),
            prefixIcon: Icons.business,
          ),
          GlassDropdownField<PositionType>(
            label: 'Должность',
            value: position,
            items: WorkTypesLabels.buildDropdownItems(
              PositionType.values,
              WorkTypesLabels.position,
            ),
            onChanged: (v) => onPositionChanged?.call(v),
            prefixIcon: Icons.work_outline,
          ),
          GlassDropdownField<RankType>(
            label: 'Звание',
            value: rank,
            items: WorkTypesLabels.buildDropdownItems(
              RankType.values,
              WorkTypesLabels.rank,
            ),
            onChanged: (v) => onRankChanged?.call(v),
            prefixIcon: Icons.military_tech_outlined,
          ),
          GlassDropdownField<StatusType>(
            label: 'Статус',
            value: status,
            items: WorkTypesLabels.buildDropdownItems(
              StatusType.values,
              WorkTypesLabels.status,
            ),
            onChanged: (v) => onStatusChanged?.call(v),
            prefixIcon: Icons.circle_outlined,
          ),
       
        ],
      ),
    );
  }
}


