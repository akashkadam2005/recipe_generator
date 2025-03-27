import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Privacy Policy", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.orange.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Introduction"),
              _buildSectionContent("Welcome to Chefio! Your privacy is important to us. This Privacy Policy explains how we collect, use, and protect your information."),

              _buildSectionTitle("Information We Collect"),
              _buildSectionContent("- Personal details like name, email, phone number, and address.\n- Data related to your app usage and preferences."),

              _buildSectionTitle("How We Use Your Information"),
              _buildSectionContent("- To improve our services and provide personalized experiences.\n- To ensure secure transactions and user authentication."),

              _buildSectionTitle("Data Security"),
              _buildSectionContent("We take appropriate measures to secure your data against unauthorized access, alteration, or disclosure."),

              _buildSectionTitle("Your Rights"),
              _buildSectionContent("You have the right to update, modify, or delete your personal data within the app settings."),

              _buildSectionTitle("Changes to Privacy Policy"),
              _buildSectionContent("We may update this policy from time to time. We encourage users to review it regularly."),


            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.deepOrange,
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        content,
        style: TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }
}
