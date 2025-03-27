import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'Authuser.dart';
import 'Login.dart';

class Sigup extends StatefulWidget {
  @override
  _SigupState createState() => _SigupState();
}

class _SigupState extends State<Sigup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final apiHelper = ApiHelper();
      final url = Uri.parse('${apiHelper.baseUrl}customer/store.php');

      var request = http.MultipartRequest('POST', url);

      request.fields['customer_name'] = _nameController.text;
      request.fields['customer_email'] = _emailController.text;
      request.fields['customer_password'] = _passwordController.text;
      request.fields['customer_phone'] = _phoneController.text;
      request.fields['customer_address'] = _addressController.text;

      try {
        var response = await request.send();

        if (response.statusCode == 200) {
          final responseData = await response.stream.bytesToString();
          final Map<String, dynamic> responseJson = json.decode(responseData);

          if (responseJson['success'] != null) {
            _showToast('✅ Registration successful! Please login.', Colors.green);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
            );
          } else {
            _showToast(responseJson['error'] ?? '❌ Registration failed.', Colors.red);
          }
        } else {
          _showToast('🚨 Server error: ${response.statusCode}', Colors.orangeAccent);
        }
      } catch (error) {
        _showToast('⚠️ An error occurred: $error', Colors.redAccent);
      }
    } else {
      _showToast('❗ Please fill in all required fields.', Colors.red);
    }
  }

// 🔥 Beautiful Toast Message Function
  void _showToast(String message, Color backgroundColor) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {


    final Brightness brightness = Theme.of(context).brightness;
    final bool isDarkMode = brightness == Brightness.dark;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body:
        SingleChildScrollView(
        child: Container(
        height: screenHeight, // Set the full height
        decoration: BoxDecoration(
        image: DecorationImage(
        image: AssetImage("assets/images/background.jpg"),
    fit: BoxFit.cover,
    ),
    ),
    child: SafeArea(
    child: Padding(
      padding:EdgeInsets.all(0),
    // padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
    child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 126),
                  Text(
                    "Sign in",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  SizedBox(height: 10),
                  Divider(height: 1, thickness: 1, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "Welcome to Chefio",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField("Name", isDarkMode, controller: _nameController),
                          SizedBox(height: 10),
                          _buildTextField("Email", isDarkMode, controller: _emailController),
                          SizedBox(height: 10),
                          _buildTextField("Password", isDarkMode, obscureText: true, controller: _passwordController),
                          SizedBox(height: 10),
                          _buildTextField("Phone", isDarkMode, controller: _phoneController),
                          SizedBox(height: 10),
                          _buildTextField("Address", isDarkMode, controller: _addressController),
                          SizedBox(height: 20),
                          _buildContinueButton(isDarkMode),
                          SizedBox(height: 20),
                          _buildDivider(isDarkMode),
                          SizedBox(height: 20),

                          _buildSocialLoginButton("Already Login", Icons.new_label, isDarkMode, context),
                        ],
                      ),
                    ),
                  ),


                  // SizedBox(height: 30),

                  // SizedBox(height: 20),
                ],
              ),
            ),
          ),
      ),
        ),
    );
  }

  Widget _buildTextField(String hint, bool isDarkMode, {bool obscureText = false, TextEditingController? controller}) {
    return SizedBox(
      height: 45,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: GoogleFonts.poppins(color: isDarkMode ? Colors.white : Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: isDarkMode ? Colors.white54 : Colors.black54, fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: isDarkMode ? Colors.black54 : Colors.grey[200],
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        ),
      ),
    );
  }


  Widget _buildContinueButton(bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkMode ? Colors.orangeAccent : Colors.blue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          _register(); // Call the register function on continue
        },
        child: Text(
          "Continue",
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDarkMode) {
    return Row(
      children: [
        Expanded(child: Divider(thickness: 1, color: isDarkMode ? Colors.white24 : Colors.grey[300])),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            "or",
            style: GoogleFonts.poppins(fontSize: 16, color: isDarkMode ? Colors.white70 : Colors.black54),
          ),
        ),
        Expanded(child: Divider(thickness: 1, color: isDarkMode ? Colors.white24 : Colors.grey[300])),
      ],
    );
  }


  Widget _buildSocialLoginButton(String text, IconData icon, bool isDarkMode, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 47,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkMode ? Colors.black54 : Colors.grey[200],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage())),
        icon: Icon(icon, color: isDarkMode ? Colors.white70 : Colors.black54),
        label: Text(
          text,
          style: GoogleFonts.poppins(fontSize: 16, color: isDarkMode ? Colors.white : Colors.black87),
        ),
      ),
    );
  }
}