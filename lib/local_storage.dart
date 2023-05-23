import 'db.dart';
import 'package:sqflite/sqflite.dart';

class Cart {
  int id;
  int userId;
  String date;
  List<Map<String, dynamic>> products;
  int v;
  String paid; // nouvel attribut

  Cart({
    required this.id,
    required this.userId,
    required this.date,
    required this.products,
    required this.v,
    required this.paid, // initialisation de l'attribut paid
  });

  Map<String, dynamic> toMap() {
  return {
    'id': id,
    'userId': userId,
    'date': date,
    'products': products,
    '__v': v,
    'paid': paid, // ajout de l'attribut paid
    };
  }

}

class Local{


  static Future<List<Map<String, dynamic>>> getUnpaidCartItems(int userId) async {
  final db = await database();

  // Récupérer l'ID du dernier panier impayé de l'utilisateur
  final unpaidCartIdResult = await db.query(
    'cart',
    where: 'userId = ? AND paid = ?',
    whereArgs: [userId, 'Unpaid'],
    orderBy: 'date DESC',
    limit: 1,
  );

  // Vérifier si l'utilisateur a un panier impayé
  if (unpaidCartIdResult.isEmpty) {
    return []; // Retourner une liste vide si l'utilisateur n'a pas de panier impayé
  }

  // Récupérer les enregistrements cartitem pour le dernier panier impayé de l'utilisateur
  final unpaidCartId = unpaidCartIdResult.first['id'];
  final cartItems = await db.query(
    'cartitem',
    where: 'cartId = ?',
    whereArgs: [unpaidCartId],
  );

  await db.close();

  // Ajouter l'ID de la carte à chaque élément de la liste
  final cartItemsWithCartId = cartItems.map((cartItem) {
    final cartItemId = cartItem['id'];
    final date=cartItem['date'];
    final cartId = cartItem['cartId'];
    final productId = cartItem['productId'];
    final quantity = cartItem['quantity'];
    return {
      'id': cartItemId,
      'date':date,
      'cartId': cartId,
      'productId': productId,
      'quantity': quantity,
    };
  }).toList();

  return cartItemsWithCartId;
}

  static Future<void> markUnpaidCartAsPaid(int userId) async {
  final db = await database();

  // Récupérer l'ID du dernier panier impayé de l'utilisateur
  final unpaidCartIdResult = await db.query(
    'cart',
    where: 'userId = ? AND paid = ?',
    whereArgs: [userId, 'Unpaid'],
    orderBy: 'date DESC',
    limit: 1,
  );

  // Vérifier si l'utilisateur a un panier impayé
  if (unpaidCartIdResult.isEmpty) {
    return; // Ne rien faire si l'utilisateur n'a pas de panier impayé
  }

  // Mettre à jour le panier impayé en tant que payé
  final unpaidCartId = unpaidCartIdResult.first['id'];
  await db.update(
    'cart',
    {'paid': 'Paid'},
    where: 'id = ?',
    whereArgs: [unpaidCartId],
  );

  await db.close();
}

  static Future<List<Map<String, dynamic>>> getUserCarts(int userId) async {
  final db = await database();

  // Récupérer tous les paniers de l'utilisateur
  final cartsResult = await db.query(
    'cart',
    where: 'userId = ?',
    whereArgs: [userId],
    orderBy: 'date DESC',
  );
  
  // Vérifier si l'utilisateur a des paniers
  if (cartsResult.isEmpty) {
    return []; // Retourner une liste vide si l'utilisateur n'a pas de panier
  }
   await db.close();
  // Récupérer les ID de chaque panier et ajouter chaque panier à une liste
  final carts = cartsResult.map((cart) {
    final cartId = cart['id'];
    final userId = cart['userId'];
    final paid = cart['paid'];
    final date = cart['date'];
    return {
      'id': cartId,
      'userId': userId,
      'paid': paid,
      'date': date,
    };
  }).toList();

 

  return carts;
}


  static Future<void> deleteAllCarts() async {
  final db = await database();

  // Supprimer tous les enregistrements de la table 'cart'
  await db.delete('cart');

  // Supprimer tous les enregistrements de la table 'cartitem'
  await db.delete('cartitem');

  await db.close();
}


  static Future<List<Map<String, dynamic>>> getCartItemsById(int cartId) async {
  final db = await database();
  final cartItems = await db.query(
    'cartitem',
    where: 'cartId = ?',
    whereArgs: [cartId],
  );
  await db.close();
  return cartItems;
}

  static Future<void> deleteCartItem(int cartId, int productId) async {
  final db = await database();
  await db.delete(
    'cartitem',
    where: 'cartId = ? AND productId = ?',
    whereArgs: [cartId, productId],
  );
}

  static Future<void> addProductInCart(int productId, int quantity, int cartId, Database db) async {
  final existingCartItem = await db.rawQuery(
      'SELECT * FROM cartitem WHERE cartId = ? AND productId = ?',
      [cartId, productId]);

  if (existingCartItem.isNotEmpty) {
    // Update the quantity of an existing cart item
    final cartItemId = existingCartItem.first['id'];
    int a=existingCartItem.first['quantity'] as int? ?? 0;
    final newQuantity = int.parse(quantity.toString());


    await db.rawUpdate(
        'UPDATE cartItem SET quantity = ? WHERE id = ?', [newQuantity, cartItemId]);
  } else {
    // Create a new cart item
    final newCartItem = {'cartId': cartId, 'productId': productId, 'quantity': quantity};
    await db.insert('cartItem', newCartItem);
  }
}

  static Future<void> addNewCart(int productId, int quantity, int userId) async {
  Database db = await database();

  //final db = await openDatabase('my_database.db');

  // Check if the user has any unpaid carts
  final unpaidCarts = await db.rawQuery(
      'SELECT * FROM cart WHERE userId = ? AND paid = ?',
      [userId, 'Unpaid']);

  if (unpaidCarts.isNotEmpty) {
    // Add the products to the first unpaid cart
    final unpaidCart = unpaidCarts.first;
    final int cartId = unpaidCart['id'] as int? ?? 0;
    await addProductInCart(productId, quantity, cartId, db);
  } else {
    // Create a new cart
    final now = DateTime.now();
   final countResult = await db.rawQuery('SELECT COUNT(*) FROM cart');
    final count = Sqflite.firstIntValue(countResult);
    final newCart = {
  'id': count! + 1,
  'userId': userId,
  'date': now.toIso8601String(),
  'paid': 'Unpaid'
};
final cartId = await db.insert('cart', newCart);


    // Add the products to the new cart
    await addProductInCart(productId, quantity, cartId, db);
  }

  await db.close();
}
  
  static Future<void> deleteFavoriteProductByUser(int userId, int productId) async {
  final Database db = await database();
  await db.delete(
    'produits_aimes',
    where: 'userId = ? AND productId = ?',
    whereArgs: [userId, productId],
  );
}

  static void display() async{
    final db = await database();
    final List<Map<String, dynamic>> fav = await db.query('produits_aimes');

    fav.forEach((FavoriteProduct) { 
      print('userid: ${FavoriteProduct['userId']}');
      print('product: ${FavoriteProduct['productId']}');

    });
  }
  
  void afficher() async{
  final db = await database();

  // Récupérer tous les enregistrements de la table "cart"
  final List<Map<String, dynamic>> carts = await db.query('cart');

  // Afficher les enregistrements de la table "cart" dans la console
  carts.forEach((cart) {
    print('Cart id: ${cart['id']}');
    print('User id: ${cart['userId']}');
    print('Date: ${cart['date']}');
    print('Paid: ${cart['paid']}');
    print('-----------------------------------');
  });

  // Récupérer tous les enregistrements de la table "cartitem"
  final List<Map<String, dynamic>> cartItems = await db.query('cartitem');

  // Afficher les enregistrements de la table "cartitem" dans la console
  cartItems.forEach((cartItem) {
    print('Cart item id: ${cartItem['id']}');
    print('Cart id: ${cartItem['cartId']}');
    print('Product id: ${cartItem['productId']}');
    print('Quantity: ${cartItem['quantity']}');
    print('-----------------------------------');
  });

  // Fermer la connexion à la base de données
  await db.close();
}

  static Future<List<Map<String, dynamic>>> insertFavoriteProduct(int userId, int productId) async {
  final Database db = await database();
  final Map<String, dynamic> row = {
    'userId': userId,
    'productId': productId,
  };
  await db.insert(
    'produits_aimes',
    row,
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
  return db.query('produits_aimes');
}

 static Future<List<int>> getFavoritebyUser(int userId) async {
  final Database db = await database();
  final List<Map<String, dynamic>> results = await db.query(
    'produits_aimes',
    columns: ['productId'],
    where: 'userId = ?',
    whereArgs: [userId],
  );

  return results.map<int>((row) => row['productId'] as int).toList();
}

  static Future<List<Map<String, dynamic>>> getFavoriteProductsByUser(int userId) async {
  final Database db = await database();
  final List<Map<String, dynamic>> maps = await db.query(
    'produits_aimes',
    where: 'userId = ?',
    whereArgs: [userId],
  );
  return maps;
}

  static Future<void> deleteAllFavoriteProductsByUser(int userId) async {
  final Database db = await database();
  await db.delete(
    'produits_aimes',
    where: 'userId = ?',
    whereArgs: [userId],
  );
}


}







