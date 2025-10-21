import 'package:flutter/material.dart';

class TaskItem {
  final String id;
  final String title;
  bool done;
  final String subjectId;

  TaskItem({
    String? id,
    required this.title,
    this.done = false,
    required this.subjectId,
  }) : id = id ?? UniqueKey().toString();

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'done': done,
        'subjectId': subjectId,
      };

  factory TaskItem.fromMap(Map<String, dynamic> map) => TaskItem(
        id: map['id'],
        title: map['title'],
        done: map['done'],
        subjectId: map['subjectId'],
      );
}
