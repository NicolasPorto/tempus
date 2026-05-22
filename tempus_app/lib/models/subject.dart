import 'package:flutter/material.dart';

class Subject {
  String id;
  String name;
  int colorValue;

  Subject({String? id, required this.name, required this.colorValue})
      : id = id ?? UniqueKey().toString();

  /// Igualdade por id para que o DropdownButton encontre
  /// o item correto mesmo após recriação dos objetos (novo loadSubjects).
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Subject && other.id == id);

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'color': colorValue};
  static Subject fromMap(Map m) =>
      Subject(id: m['id'], name: m['name'], colorValue: m['color']);
}
