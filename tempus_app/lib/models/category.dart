import 'subject.dart';

class Category {
  final String id;
  final String name;
  final String hexColor;
  final String userId;

  Category({
    required this.id,
    required this.name,
    required this.hexColor,
    required this.userId,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      hexColor: json['hex_color'] as String,
      userId: json['user_id'] as String,
    );
  }

  Subject toSubject() => Subject(
        id: id,
        name: name,
        colorValue: convertToColorValue(hexColor),
        categoryId: id,
      );

  static int convertToColorValue(String hexColor) =>
      int.parse(hexColor.substring(1, 7), radix: 16) + 0xFF000000;
}
