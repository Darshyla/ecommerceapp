class User {
  int id;
  String username;
  String email;
  String password;
  String name;
  String phone;
  String address;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
    required this.address,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      name: map['name'],
      phone: map['phone'],
      address: map['address'],
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      password: json['password'],
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
      'address': address,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
      'address': address,
    };
  }
}
