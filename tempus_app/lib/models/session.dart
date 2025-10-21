import 'package:flutter/material.dart';

class SessionLog {
  final String id;
  final String subjectId;
  final int durationMinutes;
  final DateTime createdAt;

  SessionLog({
    String? id,
    required this.subjectId,
    required this.durationMinutes,
    DateTime? createdAt,
  })  : id = id ?? UniqueKey().toString(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'subjectId': subjectId,
        'durationMinutes': durationMinutes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SessionLog.fromMap(Map<String, dynamic> map) => SessionLog(
        id: map['id'],
        subjectId: map['subjectId'],
        durationMinutes: map['durationMinutes'],
        createdAt: DateTime.parse(map['createdAt']),
      );
}
