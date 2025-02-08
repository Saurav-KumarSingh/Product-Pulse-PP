import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  static const routeName = "/helpSupport";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help & Support',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepOrange,

      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Text
              Text(
                "Welcome to our Help & Support section! We are here to assist you with any concerns regarding food expiry products. Below are some frequently asked questions and support options.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),

              // FAQ Section
              Text(
                "Frequently Asked Questions (FAQs)",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              _buildFAQ("1. How do I check the expiry date of a product?",
                  "Most food products have an expiry or best-before date printed on the packaging. Look for terms such as 'Use By,' 'Best Before,' or 'Sell By.' If the date is unclear or missing, please contact the manufacturer or retailer for clarification."),
              _buildFAQ("2. Can I consume a product after its expiry date?",
                  "It is generally not recommended to consume food past its expiry date, as it may pose health risks. However, some products labeled 'Best Before' may still be safe to consume if stored properly, though their quality may decline."),
              _buildFAQ("3. What should I do if I purchased an expired product?",
                  "If you accidentally purchased an expired product, you can:\n- Contact the store where you bought it and request a refund or replacement.\n- Report the issue to the food regulatory authority in your area.\n- Dispose of the product safely if it appears spoiled."),
              _buildFAQ("4. How can I store food to extend its shelf life?",
                  "Keep perishable items refrigerated at the recommended temperature.\nStore dry goods in a cool, dry place away from direct sunlight.\nFollow any storage instructions provided on the packaging."),
              _buildFAQ("5. How can I report a food safety issue?",
                  "If you encounter a food safety issue, such as mold, contamination, or improper labeling, you can:\n- Contact the manufacturer’s customer service.\n- Report it to your local food safety authority.\n- Share your concern with the store where you purchased the product."),
              _buildFAQ("6. How can I store the product in your app?",
                  "Our app provides a convenient way to track and store your food products:\n- Use the 'Add Product' feature to log expiry dates and storage details.\n- Set reminders for upcoming expiry dates to minimize food waste.\n- Categorize products based on storage location (e.g., fridge, freezer, pantry).\n- Access tips on best storage practices for different food items."),

              SizedBox(height: 30),

              // Contact Support Section
              Text(
                "Contact Support",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              _buildContactInfo("📞 Customer Support: ", "725804XXXX"),
              _buildContactInfo("📧 Email Support: ", "productpulse@gmail.com"),
              _buildContactInfo("📍 Visit Us: ", "SVIET"),

              SizedBox(height: 30),

              // Thank You Note
              Text(
                "We value your feedback and are committed to ensuring your safety and satisfaction. Thank you for choosing us!",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for displaying FAQ items
  Widget _buildFAQ(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(
            answer,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  // Helper widget for displaying contact information
  Widget _buildContactInfo(String label, String info) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            info,
            style: TextStyle(fontSize: 16, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
