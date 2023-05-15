import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Cart {
  final int id;
  final int userId;
  final String date;
  final String paid;

  Cart({required this.id, required this.userId, required this.date, required this.paid});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date,
      'paid': paid,
    };
  }
}

class CartItem {
  final int cartId;
  final int productId;
  final int quantity;

  CartItem({required this.cartId, required this.productId, required this.quantity});

  Map<String, dynamic> toMap() {
    return {
      'cartId': cartId,
      'productId': productId,
      'quantity': quantity,
    };
  }
}

class FavoriteProduct {
  final int id;
  final int userId;
  final int productId;

  FavoriteProduct({required this.id, required this.userId, required this.productId});

  Map<String, dynamic> toMap() {
  return {
  'id': id,
  'userId': userId,
  'productId': productId,
  };
  }
}

Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    await db.execute('''
      CREATE TABLE produits_aimes (
        id INTEGER PRIMARY KEY,
        userId INTEGER,
        productId INTEGER
      )
    ''');
  }
}

Future<Database> database() async {
  final path = await getDatabasesPath();
  return await openDatabase(
    join(path, 'my_database.db'),
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE cart (
          id INTEGER PRIMARY KEY,
          userId INTEGER,
          date TEXT,
          paid TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE cartitem (
          id INTEGER PRIMARY KEY,
          cartId INTEGER,
          productId INTEGER,
          quantity INTEGER
        )
      ''');
    },
    onUpgrade: _onUpgrade,
    version: 2,
  );
}


Future<void> insertCart(Cart cart) async {
  final Database db = await database();
  await db.insert(
    'cart',
    cart.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<void> insertCartItem(CartItem cartItem) async {
  final Database db = await database();
  await db.insert(
    'cartitem',
    cartItem.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<void> insertFavoriteProduct(FavoriteProduct favoriteProduct) async {
  final Database db = await database();
  await db.insert(
  'produits_aimes',
  favoriteProduct.toMap(),
  conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<List<Map<String, dynamic>>> getCartWithItems(int cartId) async {
  final Database db = await database();
  return await db.rawQuery('''
    SELECT cart.*, cartitem.productId, cartitem.quantity 
    FROM cart 
    INNER JOIN cartitem ON cart.id = cartitem.cartId 
    WHERE cart.id = $cartId
  ''');
}


