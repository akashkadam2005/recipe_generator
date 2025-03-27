import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:recipe_generator/Authantication/Authuser.dart';
import 'package:recipe_generator/Authantication/Sigup.dart';
import 'package:recipe_generator/Home.dart';
import 'package:recipe_generator/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showToast('❗ Please enter both email and password.', Colors.redAccent);
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final response = await ApiHelper().httpPost(
        'customer/login.php',
        {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == "Login successful!") {
          String? token = data['token'];
          Map<String, dynamic>? customer = data['customer'];

          if (token != null && customer != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('authToken', token);
            await prefs.setInt('userId', int.tryParse(customer['customer_id'].toString()) ?? 0);

            // ✅ Manually add password before saving
            customer['customer_password'] = password;

            await prefs.setString('customerData', json.encode(customer));

            _showToast('🎉 Login successful! Welcome back!', Colors.green);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainScreen(),
              ),
            );
          } else {
            _showToast('❌ Invalid token or customer data.', Colors.red);
          }
        } else {
          _showToast(data['error'] ?? '❌ Invalid email or password.', Colors.red);
        }
      } else {
        _showToast('🚨 Server error: ${response.statusCode}.', Colors.orangeAccent);
      }
    } catch (error) {
      _showToast('⚠️ An error occurred: $error', Colors.redAccent);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true, // Ensure keyboard pushes content
      body: SingleChildScrollView(
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
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Log in",
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  SizedBox(height: 10),
                  Divider(height: 1, color: Colors.grey),
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
                  SizedBox(height: 50),

                  /// Input Fields
                  _buildTextField("Email", isDarkMode, controller: _emailController),
                  SizedBox(height: 10),
                  _buildTextField("Password", isDarkMode, obscureText: true, controller: _passwordController),
                  SizedBox(height: 20),
                  _buildContinueButton(isDarkMode),
                  SizedBox(height: 30),
                  _buildDivider(isDarkMode),
                  SizedBox(height: 20),

                  /// Signup Button
                  _buildSocialLoginButton("Create New Account", Icons.new_label, isDarkMode, context),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 📌 Input Field Builder
  Widget _buildTextField(String hint, bool isDarkMode, {bool obscureText = false, TextEditingController? controller}) {
    return TextField(
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
        onPressed: _login,
        child: _isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Text("Continue", style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
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
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Sigup())),
        icon: Icon(icon, color: isDarkMode ? Colors.white70 : Colors.black54),
        label: Text(
          text,
          style: GoogleFonts.poppins(fontSize: 16, color: isDarkMode ? Colors.white : Colors.black87),
        ),
      ),
    );
  }
}
