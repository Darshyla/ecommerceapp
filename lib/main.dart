import 'package:ecommerce_app/Models/product.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'dart:io';
import 'package:numberpicker/numberpicker.dart';
import 'db.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as Path;
import 'local_storage.dart';


Future<List<dynamic>>? favoriteProd, favoriteCat, productInCat, carts, products;
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
      theme: ThemeData(primarySwatch: Colors.green, secondaryHeaderColor: Colors.green.shade800),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false
      
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
        title: Text('SHYSHOP'),
        actions: [
          ElevatedButton(onPressed:(){
            Navigator.push(context, MaterialPageRoute(builder:(context) =>PayScreen()));
          }, child: Text('Check out'))
        ],
      ),
      drawer: Displaydrawer(),
      body:bodyOption.elementAt(selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.green.shade300,
        unselectedItemColor: Colors.green.shade900,
        selectedIconTheme: IconThemeData(size: 32),
        currentIndex: selectedIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'FAVORITE'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'HOME'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'CARTS')
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

class Displaydrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
  child: ListView(
    children: [
      Container(
        decoration: BoxDecoration(color: Colors.green.shade300),
        child: DrawerHeader(
          padding: EdgeInsets.all(16),
          child: connnexionState
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   Center(
                    child:Text( "SHYSHOP",style: TextStyle( color: Colors.green.shade900,fontSize: 25,fontWeight: FontWeight.bold,)),) ,
                    SizedBox(height: 15,),
                    Center(
                      child:Container(
                        width:300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    
                    child: SingleChildScrollView(

                      child: Center(
                        child:
                        Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.person_2_outlined, color: Colors.green.shade900),
                              Text("Username", style: TextStyle(color: Colors.green.shade900, fontSize: 18)),
                              Text(username, style: TextStyle(color: Colors.green.shade900, fontSize: 16)),
                            
                          ],
                      ) ,)
                    ),
                  )
                    )


                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text( "SHYSHOP",style: TextStyle( color: Colors.green.shade900,fontSize: 25,fontWeight: FontWeight.bold,),textAlign: TextAlign.center),
                    ),
                    Text( "",style: TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.bold,),),
                  ],
                ),
        ),
      ),
      ListTile(
        leading: Icon(Icons.login_outlined, color: Colors.green.shade900,),
        title: Text("Log in"),
        onTap: () {
          if (connnexionState)
            DisplayDeconnexion(
                context, "Vous serez déconnecté en tant que $username.");
          if (!connnexionState)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
        },
      ),
      ListTile(
        leading: Icon(Icons.shopping_basket_outlined, color: Colors.green.shade900,),
        title: Text("Product list"),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DisplayProducts()),
          );
        },
      ),
      ListTile(
        leading: Icon(Icons.logout_outlined,  color: Colors.green.shade900,),
        title: Text("Log out"),
        enabled: connnexionState,
        onTap: () {
          if (connnexionState) {
            DisplayDeconnexion(context, "Do you really want to log out");
          } else {
            DisplayDeconnexion(context, "You aren't connected.");
          }
        },
      ),
    ],
  ),
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
 
   List<bool> favoriteStatus = List<bool>.filled(20, false);
   

    @override
    void initState() {
      super.initState();
      if (userId == 0) {
        favoriteStatus = List<bool>.filled(20, false);
      } else {
        checkFavoriteProducts();
      }
    }
   

    Future<void> checkFavoriteProducts() async {
      final favoriteProdIds = await Local.getFavoritebyUser(userId!);
      final a = await ApiService.getProducts();

      favoriteStatus = List<bool>.filled(20, false); // Réinitialisez la liste à false

       setState(() {
      favoriteStatus = List<bool>.filled(20, false);
      for (int i = 0; i < a.length; i++) {  
        final int productId = a[i]['id'];
        final bool isFavorite = favoriteProdIds.contains(productId);
        favoriteStatus[i] = isFavorite; 
      }
    });

      print('${favoriteStatus}');
    }

    void onItemTapped() {
    setState(() {
      checkFavoriteProducts();
    });}

  @override
  Widget build(BuildContext context){
   return Scaffold(
    appBar: AppBar(
      title: Text('Product list'),
      actions: [
          ElevatedButton(onPressed:(){
            Navigator.push(context, MaterialPageRoute(builder:(context) =>PayScreen()));
          }, child: Text('Check out'))
        ],
      ),
    body:Center(
        child: FutureBuilder<List<dynamic>>(
          future:  products,

          builder: (context, snapshot) {
            //onItemTapped();
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
                        idSelectedProd=snapshot.data![index]['id'];
                        print(idSelectedProd);
                        singleProduct=ApiService.getProductById(idSelectedProd);
                        Navigator.push(context, MaterialPageRoute(builder:(context) =>SingleProd()));
                      },
                      
                      child: Card(
                      elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                              child: Image.network(
                                snapshot.data![index]['image'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  snapshot.data![index]['title'],
                                  style: TextStyle(
                                    color: Colors.green.shade900,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  snapshot.data![index]['description'].toString().substring(0, 70),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '\$${snapshot.data?[index]['price']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    IconButton(
                                      icon: Icon(
                                        favoriteStatus[index]
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: favoriteStatus[index]
                                            ? Colors.red
                                            : Colors.black,
                                      ),
                                      onPressed: () {
                                        if (!connnexionState) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Connexion required to like product'),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        } else {
                                          setState(() {
                                            favoriteStatus[index] = !favoriteStatus[index];
                                            if (favoriteStatus[index])
                                              Local.insertFavoriteProduct(
                                                  userId!, snapshot.data![index]['id']);
                                            else
                                              Local.deleteFavoriteProductByUser(
                                                  userId!, snapshot.data![index]['id']);
                                            checkFavoriteProducts();
                                          });
                                          Local.display();
                                        }
                                      },
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        displayAddToCart(snapshot.data![index]['id'], context);
                                      },
                                      icon: Icon(Icons.shopping_cart_checkout_outlined),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      snapshot.data?[index]['rating']['rate'].toString() ?? '0',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
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

class SingleProd extends StatefulWidget {
  const SingleProd({Key? key}) : super(key: key);

  @override
  DisplaySingleProd createState() => DisplaySingleProd();
}

class DisplaySingleProd extends State<SingleProd>{
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

   bool favoriteStatus = false;
int size = 0;

@override
void initState() {
  super.initState();
  if (userId == 0) {
    favoriteStatus = false;
  } else {
    checkFavoriteProducts();
  }
}

Future<void> checkFavoriteProducts() async {
  final favoriteProdIds = await Local.getFavoritebyUser(userId!);
  final dynamic a = await singleProduct;

  favoriteStatus = false; // Reset the list to false
  setState(() {
    final int productId = a['id'];
  final bool isFavorite = favoriteProdIds.contains(productId);
  favoriteStatus = isFavorite; // Assign the value to the specific index
  });
  

  print('${favoriteStatus}');
}



   @override
Widget build(BuildContext context){
  return Scaffold(
    appBar: AppBar(
      title: Text('Details'),
      actions: [
        ElevatedButton(
          onPressed:(){
            Navigator.push(context, MaterialPageRoute(builder:(context) =>PayScreen()));
          },
          child: Text('Check out')
        )
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
                  Text(data['title'], style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.green.shade900)),
                  SizedBox(height: 16.0),
                  Text('\$${data['price'].toStringAsFixed(2)}', style: TextStyle(fontSize: 20.0)),
                  SizedBox(height: 16.0),
                  Text(data['description'], style: TextStyle(fontSize: 16.0)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          favoriteStatus? Icons.favorite : Icons.favorite_border,
                          color: favoriteStatus ? Colors.red : Colors.black,
                        ),
                        onPressed: () {
                          if (!connnexionState) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Connexion required to like product'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } else {
                            setState(() {
                              favoriteStatus = !favoriteStatus;
                              if (favoriteStatus)
                                Local.insertFavoriteProduct(userId!, snapshot.data?['id']);
                              else
                                Local.deleteFavoriteProductByUser(userId!,snapshot.data?['id']);
                              checkFavoriteProducts();
                            });
                            Local.display();
                          }
                        },
                      ),
                      SizedBox(width: 30),
                      IconButton(
                        onPressed: () {
                          displayAddToCart(data['id'],context);
                        },
                        icon: Icon(Icons.shopping_cart_checkout_outlined),
                      ),
                      SizedBox(width: 30),
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

class Home extends State<DisplayHome> {
  final favoriteCat=ApiService.getFavoriteCategories(4);
  final favoriteProd =  ApiService.getFavoriteProducts(6);

  List<bool> favoriteStatus = List<bool>.filled(6, false);

@override
void initState() {
  super.initState();
  if (userId == 0) {
    favoriteStatus = List<bool>.filled(6, false);
  } else {
    checkFavoriteProducts();
  }
}

Future<void> checkFavoriteProducts() async {
  final favoriteProdIds = await Local.getFavoritebyUser(userId!);
  final a = await ApiService.getFavoriteProducts(6);

  favoriteStatus = List<bool>.filled(6, false); // Réinitialisez la liste à false

  setState(() {
    for (int i = 0; i < a.length; i++) {
    final int productId = a[i]['id'];
    final bool isFavorite = favoriteProdIds.contains(productId);
    favoriteStatus[i] = isFavorite; // Affectez la valeur à l'indice spécifique
  }

  });
  
  print('${favoriteStatus}');
}



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
            flex: 1,
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
                        Navigator.push(context, MaterialPageRoute(builder:(context) =>ProdInCat()));
                      },
                      
                      child: Card(
                        child:Text(snapshot.data?[index].toString().toUpperCase()??'', style: TextStyle(fontSize: 11, color: Colors.white),textAlign: TextAlign.center, ),
                        color: Colors.green.shade900,
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
                        Navigator.push(context, MaterialPageRoute(builder:(context) =>SingleProd()));
                      },
                      
                      child: Card(
                      child: Column(
                        children: <Widget>[
                           Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                              child: Image.network(
                                snapshot.data![index]['image'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Text(snapshot.data?[index]['title'],
                            style: TextStyle(
                                    color: Colors.green.shade900,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,)),
                          Text(snapshot.data?[index]['description']?.toString().substring(0, 70) ?? 'No description available',
                            style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.justify,),
                          Text('\$${snapshot.data?[index]['price']}', style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children:<Widget> [
                              IconButton(icon: Icon(favoriteStatus[index]? Icons.favorite : Icons.favorite_border,
                                                    color: favoriteStatus[index] ? Colors.red : Colors.black,),
                                         onPressed: () {
                                          if(!connnexionState)
                                          {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Connexion required to like product'),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          }
                                          else
                                          {
                                             setState(() {
                                             favoriteStatus[index] = !favoriteStatus[index];
                                            if(favoriteStatus[index])
                                              Local.insertFavoriteProduct(userId!, snapshot.data?[index]['id']);
                                            else
                                              Local.deleteFavoriteProductByUser(userId!,snapshot.data?[index]['id']);
                                            checkFavoriteProducts();
                                            
                                          });
                                          Local.display();
                                          }
                                         
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
          IconButton(icon:Icon(Icons.arrow_forward, color: Colors.green.shade300) , 
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
  late Future<List<Map<String, dynamic>>> carts;

  @override
  void initState() {
    super.initState();
    carts = Local.getUserCarts(userId!);
  }

  @override
Widget build(BuildContext context) {
  return Center(
    child: FutureBuilder<List<Map<String, dynamic>>>(
      future: carts,
      builder: (context, snapshot) {
        if (!connnexionState) {
          return Text('Connexion to an account is required to check out');
        } else if (snapshot.connectionState == ConnectionState.waiting) {
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
              return FutureBuilder<List<Map<String, dynamic>>>(
                future: cartItems,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                    return Text('No items in the cart');
                  } else {
                    return SingleChildScrollView( // Ajout du SingleChildScrollView ici
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Id: ${cart['id'].toString()}'),
                          Text(
                            'Date: ${cart['date']?.toString() ?? 'No date available'}',
                          ),
                          SizedBox(height: 10),
                          Column(
                            children: snapshot.data!.map((cartItem) {
                              return FutureBuilder<Map<String, dynamic>>(
                                future: ApiService.getProductById(cartItem['productId']),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  final productData = snapshot.data;
                                  final quantity = cartItem['quantity'];
                                  final price = productData!['price'];
                                  double total = quantity * price.toDouble();
                                  totalAmount += total;
                                  return ListTile(
                                    leading: Image.network(
                                      productData['image'],
                                    ),
                                    title: Text(productData['title']),
                                    subtitle: Text(
                                        '\$${price} Quantity: ${quantity}'),
                                    trailing: Text('Total: \$$total'),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 15),
                        ],
                      ),
                    );
                  }
                },
              );
            },
          );
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

class ProdInCat extends StatefulWidget { 
  
  const ProdInCat({Key? key}) : super(key: key);
  @override
  DisplayProdInCat createState() => DisplayProdInCat();
}

class DisplayProdInCat extends State<ProdInCat>{
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

  List<bool> favoriteStatus =  List<bool>.filled(9, false);
   int size = 0;

    @override
    void initState() {
      super.initState();
      if (userId == 0) {
        favoriteStatus = List<bool>.filled(9, false);
      } else {
        checkFavoriteProducts();
      }
    }

    Future<void> checkFavoriteProducts() async {
      final favoriteProdIds = await Local.getFavoritebyUser(userId!);
      final a = await productInCat;

      favoriteStatus = List<bool>.filled(6, false); // Réinitialisez la liste à false
      setState(() {
        for (int i = 0; i < a!.length; i++) {
        final int productId = a[i]['id'];
        final bool isFavorite = favoriteProdIds.contains(productId);
        favoriteStatus[i] = isFavorite; // Affectez la valeur à l'indice spécifique
      }
      });
      

      print('${favoriteStatus}');
    }
  
  @override
  Widget build(BuildContext context){
   return Scaffold(
    appBar: AppBar(
      title: Text(titleSelCat.toUpperCase()),
      actions: [
          ElevatedButton(onPressed:(){
            Navigator.push(context, MaterialPageRoute(builder:(context) =>PayScreen()));
          }, child: Text('Check out'))
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
                        Navigator.push(context, MaterialPageRoute(builder:(context) =>SingleProd()));
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
                          Text(snapshot.data?[index]['title'],style:TextStyle(color: Colors.green.shade900, fontSize:12 )),
                          Text(snapshot.data?[index]['description']?.toString().substring(0, 70) ?? 'No description available',style: TextStyle(fontSize: 10),textAlign: TextAlign.justify,),
                          Text('\$${snapshot.data?[index]['price']}'),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children:<Widget> [
                             IconButton(icon: Icon(favoriteStatus[index]? Icons.favorite : Icons.favorite_border,
                                                    color: favoriteStatus[index] ? Colors.red : Colors.black,),
                                         onPressed: () {
                                          if(!connnexionState)
                                          {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Connexion required to like product'),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          }
                                          else
                                          {
                                             setState(() {
                                             favoriteStatus[index] = !favoriteStatus[index];
                                            if(favoriteStatus[index])
                                              Local.insertFavoriteProduct(userId!, snapshot.data?[index]['id']);
                                            else
                                              Local.deleteFavoriteProductByUser(userId!,snapshot.data?[index]['id']);
                                            checkFavoriteProducts();
                                            
                                          });
                                          Local.display();
                                          }
                                         
                                        },
                                      ),
                              SizedBox(width:50),
                              IconButton(onPressed:(){displayAddToCart(snapshot.data?[index]['id'],context);},
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

class Favorite extends State<DisplayFavorite> {
  final Future<List<Map<String, dynamic>>> _favoriteProducts =
      Local.getFavoriteProductsByUser(userId!);
  Home home = Home();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _favoriteProducts,
        builder: (context, snapshot) {
          if (!connnexionState) {
            return Text('Connexion is required to see favorite products');
          } else {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData && snapshot.data!.isEmpty) {
              return Text('There\'s no liked product');
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final productId = snapshot.data![index]['productId'];
                  final product = ApiService.getProductById(productId);
                  return Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        FutureBuilder<Map<String, dynamic>>(
                          future: product,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.hasData &&
                                snapshot.data!.isEmpty) {
                              return Text('You don\'t have favorite carts');
                            } else {
                              final productData = snapshot.data!;
                              return ListTile(
                                leading: Image.network(
                                  productData['image'],
                                  width: 25,
                                  height: 20,
                                ),
                                title: Text(productData['title']),
                                subtitle:
                                    Text('Price:\$${productData['price']}'),
                              );
                            }
                          },
                        ),
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
      appBar: AppBar(title: Text('Check out')),
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

