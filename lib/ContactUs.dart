import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'Authantication/Authuser.dart';

class ContactUs extends StatefulWidget {
  @override
  _ContactUsState createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final response = await ApiHelper().httpPost(
        "contactus/store.php",  // ✅ Don't forget the `/`
        {
          "contact_name": _nameController.text,
          "contact_email": _emailController.text,
          "contact_phone": _phoneController.text,
          "contact_message": _messageController.text,
        },
      );

      final responseData = jsonDecode(response.body);
      bool success = response.statusCode == 200 && responseData['status'] == 'success';

      if (success) {
        Fluttertoast.showToast(
          msg: "Message sent successfully!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else {
        Fluttertoast.showToast(
          msg: responseData['message'] ?? "Failed to send message",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid response from server", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // final primaryColor = isDarkMode ? Colors.tealAccent : Colors.teal;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;


    return Scaffold(
      appBar: AppBar(
        title: Text("Contact Us", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        // backgroundColor: primaryColor,
        elevation: 4,
      ),
      backgroundColor: backgroundColor,
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
              Container(
              width: 170,
              height: 230,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/ic_launcher.png"),
                  fit: BoxFit.cover, // Ensures full coverage
                ),
              ),
            ),

                SizedBox(height: 16),
                _buildTextField(_nameController, "Name", Icons.person, textColor),
                _buildTextField(_emailController, "Email", Icons.email, textColor, keyboardType: TextInputType.emailAddress),
                _buildTextField(_phoneController, "Phone", Icons.phone, textColor, keyboardType: TextInputType.phone),
                _buildTextField(_messageController, "Message", Icons.message, textColor, maxLines: 4),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(), // Circular Notch Shape
        notchMargin: 8.0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {_submitForm();},
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, Color textColor, {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: label,
          // labelStyle: TextStyle(color: primaryColor),
          // prefixIcon: Icon(icon, color: primaryColor),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide( width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (value) => value!.isEmpty ? "Enter your $label" : null,
      ),
    );
  }
}
