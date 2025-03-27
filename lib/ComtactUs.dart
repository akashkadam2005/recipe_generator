import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

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

    final url = Uri.parse("http://192.168.0.100/chefio/api/contactus/store.php");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contact_name": _nameController.text,
        "contact_email": _emailController.text,
        "contact_phone": _phoneController.text,
        "contact_message": _messageController.text,
      }),
    );

    try {
      final responseData = jsonDecode(response.body);
      String message = responseData['message'] ?? "Unknown error";
      bool success = response.statusCode == 200 && responseData['status'] == 'success';

      Fluttertoast.showToast(
        msg: "Message Send successfully!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        webPosition: "center",
        webBgColor: "#00FF00",
      );
      // ✅ Prints server response

      Future.delayed(Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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

    return Scaffold(
      appBar: AppBar(
        title: Text("Contact Us", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        // backgroundColor: primaryColor,
        elevation: 4,
      ),
      backgroundColor: backgroundColor,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  "We'd love to hear from you!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),
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
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitForm,
            child: Text("Submit", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              // backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ),
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
