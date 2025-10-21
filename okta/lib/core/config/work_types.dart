import 'package:flutter/material.dart';

/// Тип должности
enum PositionType {
  intern,
  junior,
  middle,
  senior,
  lead,
  manager,
  director,
  cLevel,
  other,
}

/// Тип отдела
enum DepartmentType {
  engineering,
  product,
  design,
  marketing,
  sales,
  support,
  hr,
  finance,
  operations,
  legal,
  other,
}

/// Звание/грейд
enum RankType {
  trainee,
  grade1,
  grade2,
  grade3,
  principal,
  staff,
  distinguished,
  other,
}

/// Компания/подразделение
enum CompanyType {
  main,
  subsidiaryA,
  subsidiaryB,
  subsidiaryC,
  partner,
  contractor,
  freelance,
  other,
}

/// Статус/состояние пользователя
enum StatusType {
  atWork, // На работе
  onVacation, // В отпуске
  sickLeave, // Больничный
  inMeeting, // На встрече
  busy, // Занят
  doNotDisturb, // Не беспокоить
  remote, // Удаленно
  offline, // Не в сети
  available, // Доступен
  other,
}

/// Утилиты для преобразования и локализации значений
class WorkTypesLabels {
  static String position(PositionType v) {
    switch (v) {
      case PositionType.intern: return 'Стажер';
      case PositionType.junior: return 'Младший специалист';
      case PositionType.middle: return 'Специалист';
      case PositionType.senior: return 'Старший специалист';
      case PositionType.lead: return 'Лид';
      case PositionType.manager: return 'Менеджер';
      case PositionType.director: return 'Директор';
      case PositionType.cLevel: return 'C-level';
      case PositionType.other: return 'Другое';
    }
  }

  static String department(DepartmentType v) {
    switch (v) {
      case DepartmentType.engineering: return 'Инженерия';
      case DepartmentType.product: return 'Продукт';
      case DepartmentType.design: return 'Дизайн';
      case DepartmentType.marketing: return 'Маркетинг';
      case DepartmentType.sales: return 'Продажи';
      case DepartmentType.support: return 'Поддержка';
      case DepartmentType.hr: return 'HR';
      case DepartmentType.finance: return 'Финансы';
      case DepartmentType.operations: return 'Операции';
      case DepartmentType.legal: return 'Юридический отдел';
      case DepartmentType.other: return 'Другое';
    }
  }

  static String rank(RankType v) {
    switch (v) {
      case RankType.trainee: return 'Стажер';
      case RankType.grade1: return 'Грейд 1';
      case RankType.grade2: return 'Грейд 2';
      case RankType.grade3: return 'Грейд 3';
      case RankType.principal: return 'Principal';
      case RankType.staff: return 'Staff';
      case RankType.distinguished: return 'Distinguished';
      case RankType.other: return 'Другое';
    }
  }

  static String company(CompanyType v) {
    switch (v) {
      case CompanyType.main: return 'Основная компания';
      case CompanyType.subsidiaryA: return 'Дочерняя A';
      case CompanyType.subsidiaryB: return 'Дочерняя B';
      case CompanyType.subsidiaryC: return 'Дочерняя C';
      case CompanyType.partner: return 'Партнер';
      case CompanyType.contractor: return 'Подрядчик';
      case CompanyType.freelance: return 'Фриланс';
      case CompanyType.other: return 'Другое';
    }
  }

  static String status(StatusType v) {
    switch (v) {
      case StatusType.atWork: return 'На работе';
      case StatusType.onVacation: return 'В отпуске';
      case StatusType.sickLeave: return 'Больничный';
      case StatusType.inMeeting: return 'На встрече';
      case StatusType.busy: return 'Занят';
      case StatusType.doNotDisturb: return 'Не беспокоить';
      case StatusType.remote: return 'Удаленно';
      case StatusType.offline: return 'Не в сети';
      case StatusType.available: return 'Доступен';
      case StatusType.other: return 'Другое';
    }
  }

  /// Универсальный билдер пунктов меню
  static List<DropdownMenuItem<T>> buildDropdownItems<T>(
    List<T> values,
    String Function(T) label,
  ) {
    return values
        .map((v) => DropdownMenuItem<T>(value: v, child: Text(label(v))))
        .toList();
  }
}

/// Парсинги из строкового значения модели в enum, по лучшему совпадению
class WorkTypesParser {
  static PositionType? positionFromString(String? value) {
    if (value == null || value.isEmpty) return null;
    final lower = value.toLowerCase();
    for (final v in PositionType.values) {
      final lbl = WorkTypesLabels.position(v).toLowerCase();
      if (lower == lbl || lower.contains(lbl.split(' ').first)) return v;
    }
    return null;
  }

  static DepartmentType? departmentFromString(String? value) {
    if (value == null || value.isEmpty) return null;
    final lower = value.toLowerCase();
    for (final v in DepartmentType.values) {
      final lbl = WorkTypesLabels.department(v).toLowerCase();
      if (lower == lbl || lower.contains(lbl.split(' ').first)) return v;
    }
    return null;
  }

  static RankType? rankFromString(String? value) {
    if (value == null || value.isEmpty) return null;
    final lower = value.toLowerCase();
    for (final v in RankType.values) {
      final lbl = WorkTypesLabels.rank(v).toLowerCase();
      if (lower == lbl || lower.contains(lbl.split(' ').first)) return v;
    }
    return null;
  }

  static CompanyType? companyFromString(String? value) {
    if (value == null || value.isEmpty) return null;
    final lower = value.toLowerCase();
    for (final v in CompanyType.values) {
      final lbl = WorkTypesLabels.company(v).toLowerCase();
      if (lower == lbl || lower.contains(lbl.split(' ').first)) return v;
    }
    return null;
  }

  static StatusType? statusFromString(String? value) {
    if (value == null || value.isEmpty) return null;
    final lower = value.toLowerCase();
    for (final v in StatusType.values) {
      final lbl = WorkTypesLabels.status(v).toLowerCase();
      if (lower == lbl || lower.contains(lbl.split(' ').first)) return v;
    }
    return null;
  }
}


