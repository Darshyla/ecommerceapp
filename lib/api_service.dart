import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';


class ApiService {
  static const String apiUrl = 'https://fakestoreapi.com';

  static Future<List<dynamic>> getProducts() async {
    final response = await http.get(Uri.parse('$apiUrl/products'));
    if (response.statusCode == 200) {
      final List<dynamic> products = jsonDecode(response.body);
      return products;
    } else {
      throw Exception('Failed to load products');
    }
  }

  static Future<List<dynamic>> getProductinCat(String catTitle) async {
  final response =await http.get(Uri.parse('$apiUrl/products/category/$catTitle'));

  if (response.statusCode == 200) {
    final List<dynamic> productsInCat = jsonDecode(response.body);
    return productsInCat;
  } else {
    throw Exception('Failed to load product details');
    }
  }

  static Future<Map<String, dynamic>> getProductById(int productId) async {
  final response =await http.get(Uri.parse('$apiUrl/products/$productId'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load product details');
    }
  }

  static Future<List<dynamic>> getFavoriteProducts(int n) async {
  final response = await http.get(Uri.parse('$apiUrl/products'));
  if (response.statusCode == 200) {
    final List<dynamic> products = jsonDecode(response.body);
    products.sort((a, b) => b["rating"].toString().compareTo(a["rating"].toString()));
    return products.take(n).toList();
  } else {
    throw Exception('Failed to fetch products');
  }
}

  static Future<List<dynamic>> getFavoriteCategories(int n) async {
  
  final response = await http.get(Uri.parse('$apiUrl/products/categories'));
  if (response.statusCode == 200) {
    final List<dynamic> categories = jsonDecode(response.body);
    categories.sort((a, b) => a.compareTo(b));
    return categories.take(n).toList();
  } else {
    throw Exception('Failed to fetch categories');
  }
  }

  static Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(Uri.parse('$apiUrl/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Invalid username or password');
    }
  }

  static Future<int?> getUserId(String username) async {
    final response = await http.get(Uri.parse('$apiUrl/users'));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = data.firstWhere((u) => u['username'] == username, orElse: () => null);
      return user != null ? user['id'] : null;
    } else {
      throw Exception('Failed to load users');
    }
  }

  static Future<List<dynamic>> getCartsByUser(int? userId) async {
    String response = await rootBundle.loadString('assets/cartList.json');
    final List<dynamic> carts = json.decode(response);
    List<dynamic> userCarts = carts.where((cart) => cart['userId'] == userId).toList();
    return userCarts;
}

  
  
}

