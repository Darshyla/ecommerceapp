class Cart {
  int id;
  int userId;
  String date;
  String paid;

  Cart({
    required this.id,
    required this.userId,
    required this.date,
    required this.paid,
  });

  factory Cart.fromMap(Map<String, dynamic> map) {
    return Cart(
      id: map['id'],
      userId: map['userId'],
      date: map['date'],
      paid: map['paid'],
    );
  }

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'],
      userId: json['userId'],
      date: json['date'],
      paid: json['paid'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date,
      'paid': paid,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date,
      'paid': paid,
    };
  }
}


class CartItem {
  int id;
  int cartId;
  int productId;
  int quantity;

  CartItem({
    required this.id,
    required this.cartId,
    required this.productId,
    required this.quantity,
  });

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'],
      cartId: map['cartId'],
      productId: map['productId'],
      quantity: map['quantity'],
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      cartId: json['cartId'],
      productId: json['productId'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cartId': cartId,
      'productId': productId,
      'quantity': quantity,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cartId': cartId,
      'productId': productId,
      'quantity': quantity,
    };
  }
}

