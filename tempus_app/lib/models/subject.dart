import 'package:flutter/material.dart';
import 'dart:math';

class Subject {
  String id;
  String name;
  int colorValue;

  Subject({String? id, required this.name, required this.colorValue})
      : id = id ?? UniqueKey().toString();

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'color': colorValue};
  static Subject fromMap(Map m) => Subject(id: m['id'], name: m['name'], colorValue: m['color']);
}
