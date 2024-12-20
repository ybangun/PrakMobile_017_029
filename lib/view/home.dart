import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tugas_akhir_pm/model/api_data_source.dart';
import 'package:tugas_akhir_pm/view/cart.dart';
import 'package:tugas_akhir_pm/view/category.dart';
import 'package:tugas_akhir_pm/view/detail.dart';
import 'package:tugas_akhir_pm/view/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  late List<Map<String, dynamic>> computers = [];
  String? _username;
  int? accIndex;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _getUsername();
  }

  Future<void> _loadProducts() async {
    try {
      final List<dynamic> response =
          await ApiDataSource.instance.loadProducts();
      setState(() {
        computers = response.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      print("Error loading products: $e");
    }
  }

  Future<void> _getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username');
      accIndex = prefs.getInt('accIndex');
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selamat Datang,',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  Text(
                    '${_username ?? 'Pengguna'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 200,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari Produk',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
          ],
        ),
        backgroundColor: Colors.purple,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: <Widget>[
          _buildHomePage(),
          CartPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.purple,
      ),
    );
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoriesSection(),
            const SizedBox(height: 20),
            _buildProductSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String title, String category, IconData icon) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CategoryPage(category: category, computers: computers),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
          color: Colors.purple.shade50,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40,
              color: Colors.purple,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _buildCategoryItem('Motherboard', 'motherboard', Icons.memory),
        _buildCategoryItem(
            'Processor', 'processor', Icons.settings_input_component),
        _buildCategoryItem('VGA', 'vga', Icons.display_settings),
      ],
    );
  }

  Widget _buildProductSection() {
    List<Map<String, dynamic>> filteredProducts = _searchController.text.isEmpty
        ? List<Map<String, dynamic>>.from(computers)
        : computers.where((computer) {
            String title = computer['nama'] ?? '';
            return title
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());
          }).toList();

    return filteredProducts.isEmpty
        ? const Center(
            child: Text(
              'Produk tidak ditemukan',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Produk',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final computer = filteredProducts[index];
                  return _buildProductItem(computer);
                },
              ),
            ],
          );
  }

  Widget _buildProductItem(Map<String, dynamic> computer) {
    // Formatter untuk angka
    final formatter = NumberFormat('#,###', 'id_ID');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(computer: computer),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
          color: Colors.purple.shade50,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              computer['gambar'] ?? '',
              width: double.infinity,
              height: 120,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    computer['nama'] ?? 'Nama tidak tersedia',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    computer['harga'] != null
                        ? 'Rp. ${formatter.format(int.parse(computer['harga']))}'
                        : 'Harga tidak tersedia',
                    style: const TextStyle(fontSize: 14, color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
