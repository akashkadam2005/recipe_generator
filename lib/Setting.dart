import 'package:flutter/material.dart';
import 'package:recipe_generator/PrivacyPolicyPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ContactUs.dart';
import 'ProfileUpdate.dart';
import 'Authantication/Login.dart';
import 'Home.dart';
import 'Recipes.dart';
import 'TermsAndConditionsPage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int? _customerId;

  @override
  void initState() {
    super.initState();
    _loadCustomerId();
  }

  Future<void> _loadCustomerId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _customerId = prefs.getInt('userId'); // Retrieve stored customer_id
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored data
    _showToast('🚪 Logged out successfully!', Colors.blue);
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false,
      );
    }
  }

  void _showToast(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.exit_to_app, size: 60, color: Colors.redAccent),
                const SizedBox(height: 15),
                Text(
                  "Are you sure you want to logout?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _logout();
                      },
                      child: const Text("Logout", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Image.asset('assets/images/logologin.jpg', width: 100),
            const SizedBox(height: 10),
            const Text('Chefio Ai', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text('Version: 1.1', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            _buildOptionTile(
              context,
              icon: Icons.person,
              text: "Profile Update",
              textColor: Colors.green,
              hasArrow: true,
              onTap: () {
                if (_customerId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileUpdatePage(customerId: _customerId!)),
                  );
                } else {
                  _showToast('⚠️ Customer ID not found!', Colors.red);
                }
              },
            ),
            _buildOptionTile(context, icon: Icons.privacy_tip, text: "Privacy Policy", onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>PrivacyPolicyPage()));
            }),
            _buildOptionTile(context, icon: Icons.article, text: "Terms & Conditions", onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>TermsAndConditionsPage()));
            }),
            _buildOptionTile(context, icon: Icons.help, text: "Contact Us ", onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>ContactUs()));
            }),
            _buildOptionTile(context, icon: Icons.logout, text: "Logout", textColor: Colors.red, onTap: _showLogoutDialog),
            const SizedBox(height: 20),
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: 2,
      //   selectedItemColor: Colors.blue.shade900,
      //   unselectedItemColor: Colors.grey,
      //   items: [
      //     BottomNavigationBarItem(
      //       icon: IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage())), icon: const Icon(Icons.auto_awesome)),
      //       label: "AI Generator",
      //     ),
      //     BottomNavigationBarItem(
      //       icon: IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RecipesScreen())), icon: Icon(Icons.receipt_long)),
      //       label: "Recipes",
      //     ),
      //     const BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
      //   ],
      // ),
    );
  }

  Widget _buildOptionTile(BuildContext context, {required IconData icon, required String text, Color textColor = Colors.black, bool hasArrow = false, VoidCallback? onTap}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: textColor),
        title: Text(text, style: TextStyle(color: textColor)),
        trailing: hasArrow ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
        onTap: onTap,
      ),
    );
  }
}
