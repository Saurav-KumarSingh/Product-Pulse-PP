import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductOfferScreenDetail extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductOfferScreenDetail({Key? key, required this.product}) : super(key: key);

  Future<Map<String, dynamic>?> fetchUserDetails(String userId) async {
    try {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();
      return userDoc.exists ? userDoc.data() as Map<String, dynamic> : null;
    } catch (e) {
      print("Error fetching user details: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>?> (
          future: fetchUserDetails(product['userId']),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(child: Text('Failed to load user details'));
            }

            final userDetails = snapshot.data!;

            return SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Image.network(
                          product['image'],
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        product['name'],
                        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      SizedBox(height: 10),
                      Row(
                
                        children: [
                          Text('Price : ',style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold,)),
                          Text(
                            "₹${product['price']}",
                            style: TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold, decoration: TextDecoration.lineThrough),
                          ),
                          SizedBox(width: 7,),
                          Text(
                            "₹${product['sellingPrice']}",
                            style: TextStyle(fontSize: 22, color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.grey, size: 18),
                          SizedBox(width: 5),
                          Text(
                            "Expiry Date: ${product['expiry']}",
                            style: TextStyle(fontSize: 16, color: Colors.redAccent),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Divider(),
                      SizedBox(height: 10),
                      Text(
                        "Seller Information:",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.all(12),
                        
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Name: ${userDetails['name']}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                            SizedBox(height: 5),
                            Text("Email: ${userDetails['email']}", style: TextStyle(fontSize: 16, color: Colors.black54)),
                            SizedBox(height: 5),
                            Text("Phone: ${userDetails['mobile']}", style: TextStyle(fontSize: 16, color: Colors.black54)),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {},
                          child: Text("Contact Seller", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
