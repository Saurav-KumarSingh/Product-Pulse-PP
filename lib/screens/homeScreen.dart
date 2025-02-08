import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../const/colors.dart';
import '../utils/helper.dart';
import '../widgets/customNavBar.dart';
import 'reminderDetail.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});
  static const routeName = "/homePage";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String userName = 'Guest';
  Stream<QuerySnapshot>? _productsStream;
  String _searchQuery = '';
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(currentUser.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          setState(() {
            userName = userDoc['name']?.toString() ?? 'Guest';
          });
        }
        setState(() {
          _productsStream = _firestore
              .collection('users')
              .doc(currentUser.uid)
              .collection('products')
              .orderBy('timestamp', descending: true)
              .snapshots();
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  void _searchProducts(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts
            .where((product) =>
                product.productName.toLowerCase().contains(_searchQuery))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(top: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Good morning\n$userName!",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    SizedBox(height: 30),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: ShapeDecoration(
                          color: AppColor.placeholderbg,
                          shape: StadiumBorder(),
                        ),
                        child: TextField(
                          onChanged: _searchProducts,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Image.asset(
                                Helper.getAssetName("search_filled.png", "virtual")),
                            hintText: "Search products",
                            hintStyle: TextStyle(
                              color: AppColor.placeholder,
                              fontSize: 18,
                            ),
                            contentPadding: EdgeInsets.only(top: 12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    _productsStream != null
                        ? StreamBuilder<QuerySnapshot>(
                      stream: _productsStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text("Error: ${snapshot.error}"));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(child: Text("No products found."));
                        }

                        _allProducts = snapshot.data!.docs.map((doc) {
                          try {
                            return Product(
                              id: doc.id,
                              barcodeId: doc['barcodeId']?.toString() ?? '',
                              expiryDate: doc['expiryDate']?.toString() ?? '',
                              scannedText: doc['scannedText']?.toString() ?? '',
                              productName: doc['productName']?.toString() ?? 'Unknown',
                              description: doc['description']?.toString() ?? '',
                              imageUrl: doc['imageUrl']?.toString() ?? '',
                            );
                          } catch (e) {
                            print("Error parsing product: $e");
                            return Product(
                              id: doc.id,
                              barcodeId: '',
                              expiryDate: '',
                              scannedText: '',
                              productName: 'Error loading',
                              description: '',
                              imageUrl: '',
                            );
                          }
                        }).toList();

                        if (_searchQuery.isEmpty) {
                          _filteredProducts = _allProducts;
                        }

                        return CategoryListScreen(products: _filteredProducts);
                      },
                    )
                        : Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomNavBar(),
          ),
        ],
      ),
    );
  }
}

class CategoryListScreen extends StatelessWidget {
  final List<Product> products;

  CategoryListScreen({required this.products});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return CategoryCard(product: products[index]);
      },
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Product product;

  const CategoryCard({required this.product});

  @override
  Widget build(BuildContext context) {
    DateTime expiryDate = _parseExpiryDate(product.expiryDate);
    DateTime currentDate = DateTime.now();
    String expiryStatus;

    // Check if the expiry is greater than one month
    Duration difference = expiryDate.difference(currentDate);
    if (difference.inDays > 30) {
      // If expiry is more than a month away, show the default expiry date
      expiryStatus = product.expiryDate; // Display the raw expiry date
    } else {
      // If expiry is within a month, calculate the remaining days or show "Expired"
      if (expiryDate.isBefore(currentDate)) {
        expiryStatus = "Expired";
      } else {
        int daysLeft = difference.inDays;
        expiryStatus = "$daysLeft day${daysLeft != 1 ? 's' : ''} left";
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: ListTile(
        title: Text(product.productName, style: kTitleTextStyle),
        subtitle: Text("Expiry: $expiryStatus", style: kSubtitleTextStyle),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.orange),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(product: product),
            ),
          );
        },
      ),
    );
  }

  DateTime _parseExpiryDate(String expiryDateStr) {
    List<String> dateFormats = [
      "MM-yyyy",      // For format: MM-YYYY
      "dd-MM-yyyy",   // For format: DD-MM-YYYY
      "dd-MM-yy",     // For format: DD-MM-YY
      "MM-yy",        // For format: MM-YY
    ];

    for (var format in dateFormats) {
      try {
        return DateFormat(format).parseStrict(expiryDateStr);
      } catch (e) {
        // If parsing fails, continue to the next format
        continue;
      }
    }
    // If no format is valid, return a default date far in the future or handle error
    return DateTime(2100, 1, 1);
  }
}

class Product {
  final String id;
  final String barcodeId;
  final String expiryDate;
  final String scannedText;
  final String productName;
  final String description;
  final String imageUrl;

  Product({
    required this.id,
    required this.barcodeId,
    required this.expiryDate,
    required this.scannedText,
    required this.productName,
    required this.description,
    required this.imageUrl,
  });
}

const kTitleTextStyle = TextStyle(fontSize: 17, fontWeight: FontWeight.bold);
const kSubtitleTextStyle = TextStyle(fontSize: 13, color: Colors.redAccent);
