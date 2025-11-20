import 'package:flutter/material.dart';

class TaskItem {
  final String id;
  final String title;
  bool done;
  final String subjectId;
  final int minutesMeta;

  TaskItem({
    String? id,
    required this.title,
    this.done = false,
    required this.subjectId,
    this.minutesMeta = 25,
  }) : id = id ?? UniqueKey().toString();

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['uuid'] ?? '',
      title: json['name'] ?? '',
      done: json['done'] ?? false,
      subjectId: json['categoryUUID'] ?? '',
      minutesMeta: json['minutesMeta'] ?? 25,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'done': done,
        'subjectId': subjectId,
      };
}