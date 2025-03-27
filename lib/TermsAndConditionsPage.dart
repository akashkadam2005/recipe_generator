import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Terms & Conditions"),
        // backgroundColor: Colors.deepOrangeAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("1. Introduction"),
            _buildSectionContent("Welcome to Chefio! These Terms & Conditions govern your use of our app and services. By using Chefio, you agree to comply with these terms."),

            _buildSectionTitle("2. User Responsibilities"),
            _buildSectionContent("Users must provide accurate information, respect others, and comply with all applicable laws when using Chefio."),

            _buildSectionTitle("3. Privacy Policy"),
            _buildSectionContent("We collect and protect your data in accordance with our Privacy Policy. By using Chefio, you consent to our data practices."),

            _buildSectionTitle("4. Payments & Refunds"),
            _buildSectionContent("All transactions made through Chefio are final. Refunds are subject to our company policies and specific service agreements."),

            _buildSectionTitle("5. Prohibited Activities"),
            _buildSectionContent("Users must not engage in illegal activities, abuse other users, or misuse the app's features in any way."),

            _buildSectionTitle("6. Changes to Terms"),
            _buildSectionContent("Chefio reserves the right to modify these Terms & Conditions at any time. Users will be notified of significant updates."),


          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.deepOrangeAccent,
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Text(
        content,
        style: TextStyle(
          fontSize: 16,
          // color: Colors.black87,
        ),
      ),
    );
  }
}
