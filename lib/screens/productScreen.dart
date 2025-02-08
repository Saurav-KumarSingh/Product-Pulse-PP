import 'package:flutter/material.dart';

import '../widgets/customNavBar.dart'; // Ensure this import is correct

class ProductOfferScreen extends StatefulWidget {
  static const routeName = "/offerPage";

  @override
  _ProductOfferScreenState createState() => _ProductOfferScreenState();
}

class _ProductOfferScreenState extends State<ProductOfferScreen> {
  final List<Map<String, dynamic>> products = [
    {
      'name': 'Aashirvad Atta',
      'price': '250',
      'image': 'assets/images/dummy/atta.webp',
      'discount': '50% OFF',
      'expiry': '1-3-2025',
    },
    {
      'name': 'Cream Wheat',
      'price': '49.00',
      'image': 'assets/images/dummy/caw.webp',
      'discount': '30% OFF',
      'expiry': '10-3-2025',
    },
    {
      'name': 'Visco Fer',
      'price': '150.00',
      'image': 'assets/images/dummy/ma.webp',
      'discount': '10% OFF',
      'expiry': '1-3-2025',
    },
    {
      'name': 'H RAB DSA',
      'price': '199.00',
      'image': 'assets/images/dummy/mb.webp',
      'discount': '50% OFF',
      'expiry': '1-5-2025',
    },
    {
      'name': 'Product 1',
      'price': '29.99',
      'image': 'assets/images/dummy/caw.webp',
      'discount': '20% OFF',
      'expiry': '2023-11-30',
    },
    {
      'name': 'Product 2',
      'price': '49.99',
      'image': 'assets/images/dummy/ma.webp',
      'discount': '30% OFF',
      'expiry': '2023-12-25',
    },
  ];

  List<Map<String, dynamic>> filteredProducts = [];

  @override
  void initState() {
    super.initState();
    filteredProducts = products;
  }

  void filterSearchResults(String query) {
    setState(() {
      filteredProducts = products
          .where((product) => product['name']
          .toLowerCase()
          .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: filterSearchResults,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 10, right: 10, bottom: 100),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 20.0,
                      childAspectRatio: 0.55,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return ProductCard(
                        name: product['name'],
                        price: product['price'],
                        imageUrl: product['image'],
                        discount: product['discount'],
                        expiry: product['expiry'],
                      );
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: CustomNavBar(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String imageUrl;
  final String discount;
  final String expiry;

  const ProductCard({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.discount,
    required this.expiry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
            child: Image.asset(
              imageUrl,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "₹ $price",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    discount,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Expiry: $expiry',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}