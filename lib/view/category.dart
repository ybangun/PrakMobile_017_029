import 'package:flutter/material.dart';
import 'package:tugas_akhir_pm/view/detail.dart';

class CategoryPage extends StatefulWidget {
  final String category;
  final List<Map<String, dynamic>> computers;

  CategoryPage({required this.category, required this.computers});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<Map<String, dynamic>> getProductsByCategory() {
    return widget.computers
        .where((computer) =>
            (computer['tipe']?.toLowerCase() ?? '') ==
            widget.category.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> categoryProducts = getProductsByCategory();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kategori ${widget.category}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: categoryProducts.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: categoryProducts.length,
                itemBuilder: (context, index) {
                  final computer = categoryProducts[index];
                  return _buildProductItem(computer);
                },
              ),
            )
          : Center(
              child: Text(
                'Tidak ada produk dalam kategori ini',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> computer) {
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
          color: Color(0xFFF8FAFC), // Warna latar belakang yang lebih lembut
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(
                computer['gambar'] ?? '',
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      computer['nama'] ?? 'Nama tidak tersedia',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      computer['harga'] != null
                          ? 'Rp ${_formatRupiah(computer['harga'])}'
                          : 'Harga tidak tersedia',
                      style: TextStyle(fontSize: 14, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRupiah(dynamic price) {
    final value = int.tryParse(price.toString()) ?? 0;
    return value.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]}.');
  }
}
