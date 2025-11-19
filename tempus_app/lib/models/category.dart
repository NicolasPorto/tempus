import 'subject.dart';

class Category {
  String UUID;
  String Name;
  String HexColor;
  String Auth0Identifier;

  Category({required this.UUID, required this.Name, required this.HexColor, required this.Auth0Identifier});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      UUID: json['uuid'] as String,
      Name: json['name'] as String,
      HexColor: json['hexColor'] as String,
      Auth0Identifier: json['auth0Identifier'] as String,
    );
  }

  Subject toSubject() => Subject(id: this.UUID, name: this.Name, colorValue: convertToColorValue(this.HexColor), categoryId: UUID );

  static int convertToColorValue(String hexColor) => int.parse(hexColor.substring(1, 7), radix: 16) + 0xFF000000;
}
