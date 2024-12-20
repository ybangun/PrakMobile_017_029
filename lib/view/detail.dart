import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:tugas_akhir_pm/hive/user.dart';
import 'package:tugas_akhir_pm/model/product_model.dart';
import 'package:tugas_akhir_pm/view/cart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Untuk format angka

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> computer;

  DetailPage({required this.computer});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  String _selectedCurrency = 'IDR'; // Default currency: IDR

  Future<void> _addToCart(Map<String, dynamic> computer) async {
    var box = await Hive.openBox<User>('usersBox');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? accIndex = prefs.getInt("accIndex") ?? 0;

    Computers newCart = Computers(
      gambar: computer['gambar'],
      nama: computer['nama'],
      harga: computer['harga'],
    );

    if (box.getAt(accIndex)?.carts != null) {
      box.getAt(accIndex)!.carts?.add(newCart);
    } else {
      var user = box.getAt(accIndex);
      user?.carts = [newCart];
      await box.putAt(accIndex, user!);
    }

    // Tampilkan snackbar saat item berhasil ditambahkan
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item berhasil ditambahkan ke keranjang!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Produk',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Image.network(
                          widget.computer['gambar'] ?? '',
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      widget.computer['nama'] ?? 'Nama tidak tersedia',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        DropdownButton<String>(
                          value: _selectedCurrency,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCurrency = newValue!;
                            });
                          },
                          items: <String>['IDR', 'USD', 'EUR', 'JPY', 'SGD']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        SizedBox(width: 8),
                        Text(
                          _convertCurrency(
                              widget.computer['harga'], _selectedCurrency),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Deskripsi:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.computer['deskripsi'] ??
                          'Deskripsi tidak tersedia',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    Divider(),
                    Text(
                      'Tipe: ${widget.computer['tipe'] ?? 'Tipe tidak tersedia'}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                _addToCart(widget.computer);
              },
              child: Text('Tambahkan ke Keranjang'),
            ),
          ),
        ],
      ),
    );
  }

  String _convertCurrency(dynamic price, String currency) {
    final formatter =
        NumberFormat.decimalPattern('id'); // Format angka Indonesia
    double convertedPrice = double.tryParse(price.toString()) ?? 0.0;
    String symbol = '';
    if (currency == 'IDR') {
      symbol = 'Rp ';
      return '$symbol${formatter.format(convertedPrice)}';
    } else if (currency == 'EUR') {
      convertedPrice *= 0.0000569; // Contoh konversi EUR
      symbol = '€ ';
    } else if (currency == 'USD') {
      convertedPrice *= 0.000065; // Contoh konversi USD
      symbol = '\$ ';
    } else if (currency == 'JPY') {
      convertedPrice *= 0.0091; // Contoh konversi JPY
      symbol = '¥ ';
    } else if (currency == 'SGD') {
      convertedPrice *= 0.000088; // Contoh konversi SGD
      symbol = 'S\$ ';
    }
    return '$symbol${convertedPrice.toStringAsFixed(2)}';
  }
}
