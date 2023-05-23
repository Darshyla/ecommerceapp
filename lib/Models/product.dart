import 'dart:convert';
class Product {
  int id;
  String title;
  double price;
  String description;
  String category;
  String image;
  double rating;
  double ratingCount;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
    required this.ratingCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
  final ratingObj = json['rating'];
  final rating = ratingObj is Map ? (ratingObj['rate'] is num ? ratingObj['rate'].toDouble() : 0.0) : 0.0;
  final ratingCount = ratingObj is Map ? (ratingObj['count'] is num ? ratingObj['count'].toDouble() : 0.0) : 0.0;

  return Product(
    id: json['id'],
    title: json['title'],
    price: json['price'] != null ? (json['price'] is num ? json['price'].toDouble() : 0.0) : 0.0,
    description: json['description'],
    category: json['category'],
    image: json['image'],
    rating: rating,
    ratingCount: ratingCount,
  );
}


}