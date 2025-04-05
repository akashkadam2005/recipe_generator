import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../Authantication/Authuser.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<dynamic> wishlistItems = [];
  int? customerId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWishlist();
  }

  Future<void> fetchWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    customerId = prefs.getInt('userId');

    if (customerId == null) {
      setState(() => isLoading = false);
      return;
    }

    final url = Uri.parse(
      "${ApiHelper().httpGet('/wishlist/list.php?customer_id=$customerId')}",
    );

    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        setState(() {
          wishlistItems = data['wishlist'] ?? [];
        });
      }
    } catch (e) {
      print("Error fetching wishlist: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> removeFromWishlist(String recipeId) async {
    final url = Uri.parse("${ApiHelper().baseUrl}/wishlist/delete.php");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "wishlist_genrate_resipe_id": recipeId,
          "wishlist_customer_id": customerId,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['success']), backgroundColor: Colors.green),
        );
        fetchWishlist(); // Refresh after removing
      }
    } catch (e) {
      print("Error removing item: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Wishlist",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : wishlistItems.isEmpty
          ? const Center(
          child: Text("💔 No items in your wishlist yet!",
              style: TextStyle(fontSize: 18)))
          : ListView.builder(
        itemCount: wishlistItems.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final item = wishlistItems[index];
          return _buildWishlistCard(item);
        },
      ),
    );
  }

  Widget _buildWishlistCard(Map<String, dynamic> item) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFFe0f2f1), Color(0xFFb2dfdb)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 35,
              backgroundImage: AssetImage('assets/images/food3.jpg'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['generate_name'] ?? 'Unnamed',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 16, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(
                        "${item['generate_preparation_time'] ?? 'N/A'} min",
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        "${item['generate_kcal'] ?? 'N/A'} kcal",
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.redAccent),
              onPressed: () => removeFromWishlist(item['generate_id'].toString()),
            )
          ],
        ),
      ),
    );
  }
}
