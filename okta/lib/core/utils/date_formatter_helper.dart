import 'package:intl/intl.dart';

/// Вспомогательный класс для форматирования дат и времени
class DateFormatter {
  DateFormatter._();

  /// Форматировать время в формате HH:mm
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  /// Форматировать дату в виде строки "14 марта понедельник"
  static String formatDateLine(DateTime dateTime) {
    return DateFormat('d MMMM EEEE', 'ru').format(dateTime);
  }

  /// Форматировать только день недели "понедельник"
  static String formatWeekday(DateTime dateTime) {
    return DateFormat('EEEE', 'ru').format(dateTime);
  }

  /// Форматировать день и месяц "14 марта"
  static String formatDayMonth(DateTime dateTime) {
    return DateFormat('d MMMM', 'ru').format(dateTime);
  }

  /// Форматировать полную дату и время
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
  }

  /// Форматировать только дату
  static String formatDate(DateTime dateTime) {
    return DateFormat('dd.MM.yyyy').format(dateTime);
  }
}
