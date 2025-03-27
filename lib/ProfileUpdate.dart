import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class ProfileUpdatePage extends StatefulWidget {
  final int customerId;

  const ProfileUpdatePage({super.key, required this.customerId});

  @override
  State<ProfileUpdatePage> createState() => _ProfileUpdatePageState();
}

class _ProfileUpdatePageState extends State<ProfileUpdatePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  File? _image;
  String? _profileImageUrl;
  final ImagePicker _picker = ImagePicker();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _loadCustomerData);
  }

  Future<void> _loadCustomerData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? customerData = prefs.getString('customerData');

      if (customerData != null && customerData.isNotEmpty) {
        final Map<String, dynamic> customer = jsonDecode(customerData);

        debugPrint("Loaded Customer Data: $customer"); // ✅ Prints full data

        setState(() {
          _nameController.text = customer['customer_name'] ?? '';
          _emailController.text = customer['customer_email'] ?? '';
          _phoneController.text = customer['customer_phone'] ?? '';
          _addressController.text = customer['customer_address'] ?? '';
          _profileImageUrl = customer['customer_image'] ?? '';
          _passwordController.text = customer['customer_password'] ?? '';
        });
      }
    } catch (e) {
      debugPrint("Error loading customer data: $e");
    }
  }


  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  String encryptPassword(String password) {
    final key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows!');
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    return encrypter.encrypt(password, iv: iv).base64;
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      debugPrint("❌ Validation Failed: Some fields are empty");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required!")),
      );
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.0.100/chefio/api/customer/update.php'),
    );

    request.fields['customer_id'] = widget.customerId.toString();
    request.fields['customer_name'] = _nameController.text;
    request.fields['customer_email'] = _emailController.text;
    request.fields['customer_phone'] = _phoneController.text;
    request.fields['customer_address'] = _addressController.text;
    request.fields['customer_password'] = _passwordController.text;  // ❌ Remove encryption here
    request.fields['customer_status'] = "Active";

    debugPrint("📤 Sending Data: ${request.fields}"); // ✅ Prints data before sending

    if (_image != null) {
      debugPrint("📸 Sending Image: ${_image!.path}"); // ✅ Prints image path if selected
      request.files.add(await http.MultipartFile.fromPath('customer_image', _image!.path));
    }

    try {
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      Fluttertoast.showToast(
        msg: "Profile updated successfully!",
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
      debugPrint("❌ Error updating profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Update Profile")),
      body:
      SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _image != null
                        ? FileImage(_image!)
                        : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty
                        ? NetworkImage("http://192.168.0.100/chefio/uploads/customers/$_profileImageUrl")
                        : AssetImage("assets/images/logologin.jpg")) as ImageProvider,
                  ),
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.teal,
                        child: Icon(Icons.camera_alt, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            buildTextField("Customer Name", _nameController, Icons.person, false),
            buildTextField("Email", _emailController, Icons.email, false),
            buildTextField("Phone", _phoneController, Icons.phone, false),
            buildTextField("Address", _addressController, Icons.location_on, false),
            buildTextField("Password", _passwordController, Icons.lock, true),

            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              child: Text(
                "Save Changes",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }




  Widget buildTextField(String label, TextEditingController controller, IconData icon, bool isPassword) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? !_isPasswordVisible : false,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.teal),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.teal),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.teal),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.teal),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.teal, width: 2),
          ),
        ),
      ),
    );
  }

}
