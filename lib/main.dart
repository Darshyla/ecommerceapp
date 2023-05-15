import 'package:flutter/material.dart';
import 'api_service.dart';
import 'dart:io';
import 'package:numberpicker/numberpicker.dart';
import 'db.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as Path;
import 'local_storage.dart';


Future<List<dynamic>>? products,favoriteProd, favoriteCat, productInCat, carts;
Future<dynamic>? singleProduct;
int idSelectedProd=0;
int selectedIndex=0;
int? userId=0;
String titleSelCat='', username='';
bool connnexionState=false;
List<Map<String, dynamic>> likedProducts = [];
List<Map<String, dynamic>> cartItem=[];


void main() {
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'eCommerce App',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: HomeScreen()
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List bodyOption=[DisplayFavorite(), DisplayHome(),DisplayCart()];

  @override
  void initState() {
    super.initState();
      selectedIndex=1;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EBOUTIKOO'),
        actions: [
          ElevatedButton(onPressed:(){
            Navigator.push(context, MaterialPageRoute(builder:(context) =>PayScreen()));
          }, child: Text('PEYE'))
        ],
      ),
      drawer: Displaydrawer(),
      body:bodyOption.elementAt(selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.orange,
        selectedIconTheme: IconThemeData(size: 32),
        currentIndex: selectedIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'FAVORI'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'AKÈY'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'CHARYO')
        ],
        onTap: (index) {
            setState(() {
              selectedIndex=index;
            });
          }
        
      ),

    );
  }
}

class Displaydrawer extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Drawer(
        child:ListView(
          children: [
            DrawerHeader(child:Text("EBOUTIKOO",
              style: TextStyle(color: Colors.white, fontSize: 25)),
            decoration:BoxDecoration(color: Colors.indigo),
            ),
            ListTile(title:Text("Konekte"), onTap: () {
                if(connnexionState)
                  DisplayDeconnexion(context, "Vous serez deconnecté en tant que ${username}.");
                if(!connnexionState)
                  Navigator.push(context, MaterialPageRoute(builder:(context) =>LoginScreen()));
              }),
            ListTile(title: Text("Lis pwodui"),
            onTap: () {
                Navigator.push(context, MaterialPageRoute(builder:(context) =>DisplayProducts()));
              }),
            ListTile(title: Text("Dekonekte"),onTap: () {
              if(connnexionState)
                DisplayDeconnexion(context,"Voulez vous vraiment vous deconnecter?");
              else
                DisplayDeconnexion(context, "Vous n'etiez jamais connecté.");
              })
          ],
        )
      );
  }
}

class DisplayProducts extends StatefulWidget {
  const DisplayProducts({Key? key}) : super(key: key);

  @override
  Products createState() => Products();
}

class Products extends State<DisplayProducts>{
  final products=ApiService.getProducts();
  Home home=Home();
 

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });}

  @override
  Widget build(BuildContext context){
   return Scaffold(
    appBar: AppBar(
      title: Text('Lis pwodui'),
      actions: [
          ElevatedButton(onPressed:(){
            Navigator.push(context, MaterialPageRoute(builder:(context) =>PayScreen()));
          }, child: Text('PEYE'))
        ],
      ),
    body:Center(
        child: FutureBuilder<List<dynamic>>(
          future: products,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData) {
              return Text('No products');
            } else {
               return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: MediaQuery.of(context).size.width /
                        (MediaQuery.of(context).size.height / 1.2),
                  ),
                  itemCount: snapshot.data?.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        idSelectedProd=snapshot.data?[index]['id'];
                        print(idSelectedProd);
                        singleProduct=ApiService.getProductById(idSelectedProd);
                        Navigator.push(context, MaterialPageRoute(builder:(context) =>DisplaySingleProd()));
                      },
                      
                      child: Card(
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: Image.network(
                              snapshot.data?[index]['image'],
                              fit: BoxFit.cover,
                              height: 100, width:100
                            ),
                          ),
                          Text(snapshot.data?[index]['title'],style:TextStyle(color: Colors.orange, fontSize:12 )),
                          Text(snapshot.data?[index]['description']?.toString().substring(0, 70) ?? 'No description available',style: TextStyle(fontSize: 10),textAlign: TextAlign.justify,),
                          Text('\$${snapshot.data?[index]['price']}'),
                           Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children:<Widget> [
                              IconButton(onPressed:(){}, icon: Icon(Icons.star)),
                              SizedBox(width:30),
                              IconButton(onPressed:(){home.displayAddToCart(snapshot.data?[index]['id'],context);},
                                         icon: Icon(Icons.shopping_cart_checkout_outlined)),
                              SizedBox(width:30),
                              Text(snapshot.data?[index]['rating']['rate']?.toString() ?? '0'),
                            ],
                          )
                          
                        ],
                      ),
                    )
                    );
                      
                  },
                );
            }
          },
        ),
      )
   );
  }
}

class DisplaySingleProd extends StatelessWidget{
  Home home=Home();
    @override

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Detay'),
        actions: [
          ElevatedButton(onPressed:(){
            Navigator.push(context, MaterialPageRoute(builder:(context) =>PayScreen()));
          }, child: Text('PEYE'))
        ],
      ),
      body: Center(
        child: FutureBuilder<dynamic>(
          future: singleProduct,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData) {
              return Text('No data');
            } else {
              var data = snapshot.data;
              return Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                            child: Image.network(
                              snapshot.data?['image'],
                            ),
                          ),
                    Text(data['title'], style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16.0),
                    Text('Price: \$${data['price'].toStringAsFixed(2)}', style: TextStyle(fontSize: 20.0)),
                    SizedBox(height: 16.0),
                    Text('Description:', style: TextStyle(fontSize: 20.0)),
                    SizedBox(height: 8.0),
                    Text(data['description'], style: TextStyle(fontSize: 16.0)),
                     Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children:<Widget> [
                              IconButton(onPressed:(){}, icon: Icon(Icons.star)),
                              SizedBox(width:30),
                               IconButton(onPressed:(){home.displayAddToCart(data['id'],context);},
                                         icon: Icon(Icons.shopping_cart_checkout_outlined)),
                              SizedBox(width:30),
                              Text(snapshot.data?['rating']['rate']?.toString() ?? '0'),
                            ],
                          ),
                  ],
                ),
              );
            }
          },
        )
      )

    );
    
  }
}

class DisplayHome extends StatefulWidget{
 
  Home createState() => Home();
}

class Home extends State<DisplayHome>{
  final favoriteProd=ApiService.getFavoriteProducts(6);
  final favoriteCat=ApiService.getFavoriteCategories(4);

  bool isPressed = false;

  void displayAddToCart(int idProd, BuildContext context){
    int quantity=1;
    @override
    void initState() {
      super.initState();
      setState(() {
        quantity=1;
      });
    }
    
    if (!connnexionState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connexion to an account is required to add a product to the cart'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  else{
    showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add to cart"),
          content: StatefulBuilder(
            builder: (context, SBsetState) {
              
              return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Quantity"),
              SizedBox(height: 20),
              NumberPicker(
                value: quantity,
                minValue: 1,
                maxValue: 100,
                onChanged: (value) { 
                setState(() => quantity = value);// to change on widget level state 
                SBsetState(() => quantity = value);
                }
              )
            ]
          );
         }
       ),
           actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text("Add to cart"),
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Product added to cart.'),
                    duration: Duration(seconds: 2),
                  ),
                );
                setState(() {
                  quantity = quantity;
                });
                Local.addNewCart(idProd, quantity, userId!);
              },
            ),
          ]
        );
      },
    );
  }
  
}
 
  
  @override
  Widget build(BuildContext context){
    return Column(
      children: [
          Expanded(
            flex: 3,
            child: Column(children: [
            Text('FAVORITE CATEGORIES'),
            Expanded(child:FutureBuilder<List<dynamic>>(
          future:favoriteCat,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData) {
              return Text('No Categories');
            } else {
               return GridView.builder(
                  
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: MediaQuery.of(context).size.width /
                        (MediaQuery.of(context).size.height / 1.2),
                  ),
                  itemCount: snapshot.data?.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        titleSelCat=snapshot.data?[index];
                        print(titleSelCat);
                        productInCat=ApiService.getProductinCat(titleSelCat);
                        Navigator.push(context, MaterialPageRoute(builder:(context) =>DisplayProdInCat()));
                      },
                      
                      child: Card(
                      child: Column(
                        children: <Widget>[
                          Text(snapshot.data?[index].toString().toUpperCase()??'',style: TextStyle(fontSize: 12),textAlign: TextAlign.center,)
                        ],
                      ),
                    )
                    );
                      
                  },
                );
            }
          },
          )
            
            )
          ],)
          
        ),
          Expanded(
            flex: 7,
            child: Column(children: [
            Text('FAVORITE PRODUCTS'),
            Expanded(child:FutureBuilder<List<dynamic>>(
          future:favoriteProd,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData) {
              return Text('No products');
            } else {
               return GridView.builder(
                
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: MediaQuery.of(context).size.width /
                        (MediaQuery.of(context).size.height / 1.2),
                  ),
                  itemCount: snapshot.data?.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        idSelectedProd=snapshot.data?[index]['id'];
                        print(idSelectedProd);
                        singleProduct=ApiService.getProductById(idSelectedProd);
                        Navigator.push(context, MaterialPageRoute(builder:(context) =>DisplaySingleProd()));
                      },
                      
                      child: Card(
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: Image.network(
                              snapshot.data?[index]['image'],
                              fit: BoxFit.cover,
                              height: 100, width:100
                            ),
                          ),
                          Text(snapshot.data?[index]['title'],style:TextStyle(color: Colors.orange, fontSize:12 )),
                          Text(snapshot.data?[index]['description']?.toString().substring(0, 70) ?? 'No description available',style: TextStyle(fontSize: 10),textAlign: TextAlign.justify,),
                          Text('\$${snapshot.data?[index]['price']}'),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children:<Widget> [
                              IconButton(icon: Icon(Icons.favorite,color: isPressed ? Colors.red : Colors.grey,),
                                         onPressed: () {
                                          print('b');
                                          setState(() {
                                            isPressed = !isPressed;
                                            if(isPressed)
                                              Local.getFavoriteProductsByUser(userId!);
                                            else
                                              Local.deleteFavoriteProductByUser(userId!,snapshot.data?[index]['id']);
                                            
                                          });
                                          Local.display();
                                        },
                                      ),
                              IconButton(onPressed:(){displayAddToCart(snapshot.data?[index]['id'],context);},
                                         icon: Icon(Icons.shopping_cart_checkout_outlined)),
                              SizedBox(width:30),
                              Text(snapshot.data?[index]['rating']['rate']?.toString() ?? '0'),
                            ],
                          )
                          
                        ],
                      ),
                    )
                    );
                      
                  },
                );
            }
          },
          )
            
            )
          ],)
          
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
          Text('See more products'),
          IconButton(icon:Icon(Icons.arrow_forward, color: Colors.orange) , 
          onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder:(context) =>DisplayProducts()));
              } )
        ],)
        
      ]
    );
        
   
  }
}

class DisplayCart extends StatefulWidget {
  
  const DisplayCart({Key? key}) : super(key: key);
  @override
  CartState createState() => CartState();
}

class CartState extends State<DisplayCart> {
  Future<List<Map<String, dynamic>>> carts = Local.getUserCarts(userId!);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: carts,
        builder: (context, snapshot) {
          if (!connnexionState) {
            return Text('Connexion to an account is required to check out');
          } else {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData && snapshot.data!.isEmpty) {
              return Text('Your cart is empty');
            } else {
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                ),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final cart = snapshot.data![index];
                  final cartItems = Local.getCartItemsById(cart['id']);
                  double totalAmount = 0;
                  return Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Id: ${cart['id'].toString()}'),
                        Text('Date: ${cart['date']?.toString() ?? 'No date available'}'),
                        SizedBox(height: 10),
                        Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              //itemCount: cartItems.length,
                              itemBuilder: (context, index) {
                                //final cartItem = 
                                final product = ApiService.getProductById(cart[index]['productId']);
                                return FutureBuilder<dynamic>(
                                  future: product,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    final productData = snapshot.data;
                                    final quantity = cart['quantity'];
                                    final price = productData['price'];
                                    double total = quantity * price.toDouble();
                                    totalAmount = totalAmount + total;
                                    return ListTile(
                                      leading:
                                          Image.network(productData['image']),
                                      title: Text(productData['title']),
                                      subtitle: Text(
                                          '\$${price} Quantity: ${quantity}'),
                                      trailing: Text('Total: \$$total'),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        Text('Total amount: \$$totalAmount'),
                      ],
                    ),
                  );
                },
              );
            }
          }
        },
      ),
    );
  }
}

Future<dynamic> DisplayDeconnexion(BuildContext context, String contenu){
  
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Demande de deconnexion"),
          content: Text(contenu),
          actions: [
            TextButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
                connnexionState=false;
                userId=0;
              },
            ),
            TextButton(
              child: Text("Annuler"),
              onPressed: () {
                Navigator.of(context).pop(); 
              },
            ),
          ],
        );
      });
  
}

class DisplayProdInCat extends StatelessWidget{
  Home home=Home();
  @override
  Widget build(BuildContext context){
   return Scaffold(
    appBar: AppBar(
      title: Text(titleSelCat.toUpperCase()),
      actions: [
          ElevatedButton(onPressed:(){
            Navigator.push(context, MaterialPageRoute(builder:(context) =>PayScreen()));
          }, child: Text('PEYE'))
        ],
      ),
    body:Center(
        child: FutureBuilder<List<dynamic>>(
          future: productInCat,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData) {
              return Text('No products');
            } else {
               return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: MediaQuery.of(context).size.width /
                        (MediaQuery.of(context).size.height / 1.2),
                  ),
                  itemCount: snapshot.data?.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        idSelectedProd=snapshot.data?[index]['id'];
                        print(idSelectedProd);
                        singleProduct=ApiService.getProductById(idSelectedProd);
                        Navigator.push(context, MaterialPageRoute(builder:(context) =>DisplaySingleProd()));
                      },
                      
                      child: Card(
                      child: Flex(
                        direction: Axis.vertical,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child: Image.network(
                              snapshot.data?[index]['image'],
                              fit: BoxFit.cover,
                              height: 100, width:100
                            ),
                          ),
                          Text(snapshot.data?[index]['title'],style:TextStyle(color: Colors.orange, fontSize:12 )),
                          Text(snapshot.data?[index]['description']?.toString().substring(0, 70) ?? 'No description available',style: TextStyle(fontSize: 10),textAlign: TextAlign.justify,),
                          Text('\$${snapshot.data?[index]['price']}'),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children:<Widget> [
                              IconButton(onPressed:(){}, icon: Icon(Icons.star)),
                              SizedBox(width:50),
                              IconButton(onPressed:(){home.displayAddToCart(snapshot.data?[index]['id'],context);},
                                         icon: Icon(Icons.shopping_cart_checkout_outlined)),
                            ],
                          )
                          
                        ],
                      ),
                    )
                    );
                      
                  },
                );
            }
          },
        ),
      )
   );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  String _password = '';

  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _login() async {
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await ApiService.login(username, _password);
       Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connexion reussie pour ${username}'),
          duration: Duration(seconds: 2),
        ),
      );
      connnexionState=true;
      userId=await ApiService.getUserId(username);
      print(userId);
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid username or password';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
                onSaved: (value) {
                  username = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value!;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _isLoading ? null : () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _login();
                   
                    
                  }
                
                },
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('Login'),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class DisplayFavorite extends StatefulWidget {
  const DisplayFavorite({Key? key}) : super(key: key);

  @override
  Favorite createState() => Favorite();
}

class Favorite extends State<DisplayFavorite>{
  late Future<List<Map<String, dynamic>>> _favoriteProducts= Local.getFavoriteProductsByUser(userId!); 
  Home home=Home();
  
  @override
  Widget build(BuildContext context) {
    
    return Center(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _favoriteProducts,
        builder: (context, snapshot) {
          if(!connnexionState){
            return Text('Connexion to an account is required to check out');
          }
          else{
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData && snapshot.data!.isEmpty) {
              return Text('There\'s no unpaid cart');
            } else {
              return ListView.builder(
                itemCount: 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final product = ApiService.getProductById(snapshot.data?[index]['productId']);
                    return Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          FutureBuilder<Map<String, dynamic>>(
                            future: product,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                                return Text('You don\'t have favorite carts');
                              } else {
                                return Column(
                                  children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: ClampingScrollPhysics(),
                                      itemCount: snapshot.data!.length,
                                      itemBuilder: (context, index) {
                                        return FutureBuilder<dynamic>(
                                          future: product,
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                              return Center(
                                                child: CircularProgressIndicator(),
                                              );
                                            }
                                            final productData = snapshot.data;
                                            return ListTile(
                                              leading: Image.network(productData['image'],width: 25,height: 20,),
                                              title: Text(productData['title']),
                                              subtitle: Text('Price:\$${productData['price']}'),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  }
                  else {
                    final product = ApiService.getProductById(snapshot.data?[index-1]['productId']);
                    return Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          FutureBuilder<Map<String, dynamic>>(
                            future: product,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                                return Text('You don\'t have favorite carts');
                              } else {
                                return Column(
                                  children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: ClampingScrollPhysics(),
                                      itemCount: snapshot.data!.length,
                                      itemBuilder: (context, index) {
                                        return FutureBuilder<dynamic>(
                                          future: product,
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                              return Center(
                                                child: CircularProgressIndicator(),
                                              );
                                            }
                                            final productData = snapshot.data;
                                            return ListTile(
                                              leading: Image.network(productData['image'],width: 25,height: 20,),
                                              title: Text(productData['title']),
                                              subtitle: Text('Price:\$${productData['price']}'),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  }
                },
              );
            }
          }
        },
      ),
    );
  }
}


class PayScreen extends StatefulWidget {

  @override
  PayScreenState createState() => PayScreenState();
}

class PayScreenState extends State<PayScreen> {
  late Future<List<Map<String, dynamic>>> _cartItemsFuture;
  
  @override
  void initState() {
    super.initState();
    _cartItemsFuture = Local.getUnpaidCartItems(userId!);
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PEYE')),
      body:Center(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _cartItemsFuture,
        builder: (context, snapshot) {
          if(!connnexionState){
            return Text('Connexion to an account is required to check out');
          }
          else{
             if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return Text('There\'s no unpaid cart');
          } else {
            return ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                if (index == 0) {
  final cart = snapshot.data!.first;
  return Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: Local.getUnpaidCartItems(userId!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData && snapshot.data!.isEmpty) {
              return Text('Your cart is empty');
            } else {
              return Column(
                children: [
                  ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final cartItem = snapshot.data![index];
                  int cartId=cartItem['cartId'];
                  final product = ApiService.getProductById(cartItem['productId']);
                  return FutureBuilder<dynamic>(
                    future: product,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final productData = snapshot.data;
                      final quantity = cartItem['quantity'];
                      final price = productData['price'];
                      double total = quantity * price.toDouble();
                      return ListTile(
                        leading: Image.network(productData['image'],width: 25,height: 20,),
                        title: Text(productData['title']),
                        subtitle: Text('Price:\$${price} Quantity: ${quantity} Total: \$$total'),
                        trailing: IconButton(icon: Icon(Icons.delete_outlined),onPressed: (){
                           setState(() {
                            int prod=productData['id'];
                            print(cartId);
                            Local.deleteCartItem(cartId, prod);
                            ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Product deleted in cart'),
                          ),
                        );
                          });
                          
                        },)
                      );
                    },
                  );
                },
              ),
              ElevatedButton(child: Text('Check out'),onPressed:(){
                   Navigator.push(context, MaterialPageRoute(builder:(context) =>PaymentMethodScreen()));
                })
                ]
              ) ;
            }
          },
        ),
      ],
    ),
  );
}
 else {
                  final cartItem = snapshot.data![index - 1];
                  final product = ApiService.getProductById(cartItem['productId']);
                  return FutureBuilder<dynamic>(
                    future: product,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final productData = snapshot.data;
                      final quantity = cartItem['quantity'];
                      final price = productData['price'];
                      double total = quantity * price;
                      return Card(
                        child: ListTile(
                          leading: Image.network(productData['image']),
                          title: Text(productData['title']),
                          subtitle: Text('\$${price} Quantity: ${quantity}'),
                          trailing: Row(
                            children: [Text('Total: \$$total'),
                              IconButton(onPressed: (){
                                int prod=productData['id'];
                                print(prod);
                              }, icon: Icon(Icons.delete))
                            ]),
                        ),
                      );
                    },
                  );
                }
              },
            );
          }
          }
         
        },
      ),
      )
    );
  }
}

class PaymentMethodScreen extends StatefulWidget{
  @override
  PaymentMethodState createState() => PaymentMethodState();
}

class PaymentMethodState extends State<PaymentMethodScreen>{
   int _selectedPaymentMethod = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choisissez votre méthode de paiement'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListTile(
              leading: Image.asset('assets/images/paypal.png',width: 50,height: 20),

              title: Text('PayPal'),
              trailing: Radio(
                value: 0,
                groupValue: _selectedPaymentMethod,
                onChanged: (int? value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
              ),
            ),
            ListTile(
              leading: Image.asset('assets/images/MasterCard_Logo.svg.png',width: 50,height: 20),
              title: Text('Master Card'),
              trailing: Radio(
                value: 1,
                groupValue: _selectedPaymentMethod,
                onChanged: (int? value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
              ),
            ),
            ListTile(
              leading: Image.asset('assets/images/moncash.png',width: 50,height: 20),
              title: Text('MonCash'),
              trailing: Radio(
                value: 2,
                groupValue: _selectedPaymentMethod,
                onChanged: (int? value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                print(_selectedPaymentMethod);
                if(_selectedPaymentMethod==1)
                  Navigator.push(context, MaterialPageRoute(builder:(context) =>MasterCardScreen()));  
                else if(_selectedPaymentMethod==0)
                  Navigator.push(context, MaterialPageRoute(builder:(context) =>PaypalFormScreen()));
                else if(_selectedPaymentMethod==2)
                  Navigator.push(context, MaterialPageRoute(builder:(context) =>MonCashFormScreen()));

                
              },
              child: Text('Payer maintenant'),
            ),
          ],
        ),
      ),
    );
  }

}

class MasterCardScreen extends StatefulWidget {
  @override
  MasterCardState createState() => MasterCardState();
}

class MasterCardState extends State<MasterCardScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Master card payment'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/MasterCard_Logo.svg.png',
                  height: 80.0,
                ),
                SizedBox(height: 16.0),
                Text(
                  '',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Name on the card',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the name on the card';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Number of card',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the number of the card';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Expiration (MM/AA)',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Pleasse enter expiration date';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Security code',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter security code';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        //TODO: traitement de paiement
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Payment done successfully'),
                          ),
                        );
                         Navigator.push(context, MaterialPageRoute(builder:(context) =>HomeScreen()));
                         Local.markUnpaidCartAsPaid(userId!);
                      }
                    },
                    child: Text('Check out'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PaypalFormScreen extends StatefulWidget {
  @override
  PaypalFormState createState() => PaypalFormState();
}

class PaypalFormState extends State<PaypalFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String _email='';
  String _password='';
  String _cardNumber='';
  String _cvv='';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PayPal Payment'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                child: Image.asset('assets/images/paypal.png'),
              ),
              SizedBox(height: 16.0),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _email = value!;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _password = value!;
                  },
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Card Details',
                style: TextStyle(fontSize: 16.0),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Card Number',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your card number';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _cardNumber = value!;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Expiration Date',
                  ),
                  keyboardType: TextInputType.datetime,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'CVV',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your CVV';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _cvv = value!;
                  },
                ),
              ),
              SizedBox(height: 32.0),
             ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        //TODO: traitement de paiement
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Payment done successfully'),
                          ),
                        );
                        Navigator.push(context, MaterialPageRoute(builder:(context) =>HomeScreen()));
                        Local.markUnpaidCartAsPaid(userId!);
                      }
                    },
                    child: Text('Check out'),
                  )
            ],
          ),
        ),
      ),
    );
  }
}

class MonCashFormScreen extends StatefulWidget {
  @override
  MonCashState createState() => MonCashState();
}

class MonCashState extends State<MonCashFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String _phoneNumber = '';
  String _pin = '';
  String _amount = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MonCash Payment'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/moncash.png',
                height: 100,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Phone number',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _phoneNumber = value!;
                },
              ),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'PIN',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your PIN';
                  }
                  return null;
                },
                onSaved: (value) {
                  _pin = value!;
                },
              ),
              SizedBox(height: 16),
             ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        //TODO: traitement de paiement
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Payment done successfully'),
                          ),
                        );
                        Navigator.push(context, MaterialPageRoute(builder:(context) =>HomeScreen()));
                        Local.markUnpaidCartAsPaid(userId!);
                      }
                    },
                    child: Text('Check out'),
                  )
            ],
          ),
        ),
      ),
    );
  }
}

