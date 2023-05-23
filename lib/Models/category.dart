import 'dart:convert';

class Category {
  int id;
  String name;

  Category({
    required this.id,
    required this.name,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
    );
  }

  factory Category.fromJson(String json) {
    Map<String, dynamic> map = jsonDecode(json);
    return Category.fromMap(map);
  }
}
