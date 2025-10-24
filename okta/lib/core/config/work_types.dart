import 'package:flutter/material.dart';

/// Тип должности
enum PositionType {
  chief, // начальник
  deputyChief, // зам.начальника
  labChief, // начальник лаборатории
  deputyLabChief, // зам.начальника лаборатории
  departmentChief, // начальник кафедры
  deputyDepartmentChief, // зам.начальника кафедры
  courseChief, // начальник курса
  deputyCourseChief, // зам.начальника курса
  teacher, // преподаватель
  assistant, // ассистент
  associateProfessor, // доцент
  professor, // профессор
}

/// Тип отдела
enum DepartmentType {
  department, // кафедра
  laboratory, // лаборатория
  course, // курс
}

/// Звание/грейд
enum RankType {
  private, // рядовой
  sergeant, // сержант
  seniorSergeant, // старшина
  lieutenant, // лейтенант
  captain, // капитан
  major, // майор
  lieutenantColonel, // подполковник
  colonel, // полковник
}

/// Управление/подразделение
enum CompanyType {
  academy, // академия
  faculty1, // 1 факультет
  faculty2, // 2 факультет
  faculty3, // 3 факультет
  faculty4, // 4 факультет
  faculty5, // 5 факультет
  faculty6, // 6 факультет
  faculty7, // 7 факультет
  faculty8, // 8 факультет
  faculty9, // 9 факультет
  spoFaculty, // факультет Спо
  vini, // ВиНи
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
      case PositionType.chief: return 'Начальник';
      case PositionType.deputyChief: return 'Зам. начальника';
      case PositionType.labChief: return 'Начальник лаборатории';
      case PositionType.deputyLabChief: return 'Зам. начальника лаборатории';
      case PositionType.departmentChief: return 'Начальник кафедры';
      case PositionType.deputyDepartmentChief: return 'Зам. начальника кафедры';
      case PositionType.courseChief: return 'Начальник курса';
      case PositionType.deputyCourseChief: return 'Зам. начальника курса';
      case PositionType.teacher: return 'Преподаватель';
      case PositionType.assistant: return 'Ассистент';
      case PositionType.associateProfessor: return 'Доцент';
      case PositionType.professor: return 'Профессор';
    }
  }

  static String department(DepartmentType v) {
    switch (v) {
      case DepartmentType.department: return 'Кафедра';
      case DepartmentType.laboratory: return 'Лаборатория';
      case DepartmentType.course: return 'Курс';
    }
  }

  static String rank(RankType v) {
    switch (v) {
      case RankType.private: return 'Рядовой';
      case RankType.sergeant: return 'Сержант';
      case RankType.seniorSergeant: return 'Старшина';
      case RankType.lieutenant: return 'Лейтенант';
      case RankType.captain: return 'Капитан';
      case RankType.major: return 'Майор';
      case RankType.lieutenantColonel: return 'Подполковник';
      case RankType.colonel: return 'Полковник';
    }
  }

  static String company(CompanyType v) {
    switch (v) {
      case CompanyType.academy: return 'Академия';
      case CompanyType.faculty1: return '1 факультет';
      case CompanyType.faculty2: return '2 факультет';
      case CompanyType.faculty3: return '3 факультет';
      case CompanyType.faculty4: return '4 факультет';
      case CompanyType.faculty5: return '5 факультет';
      case CompanyType.faculty6: return '6 факультет';
      case CompanyType.faculty7: return '7 факультет';
      case CompanyType.faculty8: return '8 факультет';
      case CompanyType.faculty9: return '9 факультет';
      case CompanyType.spoFaculty: return 'Факультет СПО';
      case CompanyType.vini: return 'ВиНи';
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


