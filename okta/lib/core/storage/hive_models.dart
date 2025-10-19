import 'package:hive/hive.dart';

/// Базовая модель для работы с Hive
/// Все модели должны наследоваться от этого класса
abstract class HiveModel {
  /// Уникальный идентификатор для Hive адаптера
  static int get typeId => 0;
  
  /// Сериализация объекта в Map для сохранения в Hive
  Map<String, dynamic> toJson();
  
  /// Десериализация объекта из Map
  static HiveModel fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('fromJson must be implemented in subclasses');
  }
}

/// Базовый адаптер для Hive моделей
abstract class HiveModelAdapter<T extends HiveModel> extends TypeAdapter<T> {
  @override
  T read(BinaryReader reader) {
    // Это должно быть переопределено в конкретных адаптерах
    throw UnimplementedError('read method must be implemented in concrete adapters');
  }

  @override
  void write(BinaryWriter writer, T obj) {
    writer.writeMap(obj.toJson());
  }
}
