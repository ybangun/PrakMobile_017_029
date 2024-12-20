import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:tugas_akhir_pm/hive/user.dart';
import 'package:tugas_akhir_pm/model/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Computers>? _cartItems;
  Map<int, bool> _isCheckedMap = {};
  double _totalPrice = 0.0;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _getCartItems();
  }

  void _initializeNotifications() async {
    var androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(
      android: androidSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(String itemName) async {
    var androidDetails = AndroidNotificationDetails(
      'cart_channel_id',
      'Cart Notifications',
      channelDescription: 'Notifikasi ketika item ditambahkan ke keranjang',
      importance: Importance.high,
      priority: Priority.high,
    );

    var notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Berhasil Checkout!',
      '$itemName berhasil di checkout.',
      notificationDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Keranjang Belanja',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _cartItems == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _cartItems!.isEmpty
              ? Center(
                  child: Text(
                    'Keranjang Anda kosong.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        itemCount: _cartItems!.length,
                        separatorBuilder: (_, __) => Divider(),
                        itemBuilder: (context, index) {
                          final computer = _cartItems![index];
                          return ListTile(
                            leading: Image.network(
                              computer.gambar!,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            ),
                            title: Text(
                              computer.nama!,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Rp ${_formatRupiah(computer.harga)}',
                              style: TextStyle(color: Colors.red),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: _isCheckedMap[index] ?? false,
                                  onChanged: (value) {
                                    setState(() {
                                      _isCheckedMap[index] = value!;
                                      _updateTotalPrice();
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      if (_isCheckedMap[index] == true) {
                                        _totalPrice -=
                                            double.tryParse(computer.harga!) ??
                                                0.0;
                                      }
                                      _cartItems!.removeAt(index);
                                      _isCheckedMap.remove(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total: Rp ${_formatRupiah(_totalPrice.toStringAsFixed(0))}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            onPressed: _cartItems!.isNotEmpty
                                ? () {
                                    _checkoutItems();
                                  }
                                : null,
                            child: Text('Checkout'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Future<void> _getCartItems() async {
    var box = await Hive.openBox<User>('usersBox');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? accIndex = prefs.getInt("accIndex");

    if (accIndex == null) {
      setState(() {
        _cartItems = [];
      });
      return;
    }

    User? currentUser = box.get(accIndex);
    if (currentUser == null || currentUser.carts == null) {
      setState(() {
        _cartItems = [];
      });
      return;
    }

    setState(() {
      _cartItems = currentUser.carts;
      _isCheckedMap.clear();
      for (int i = 0; i < _cartItems!.length; i++) {
        _isCheckedMap[i] = false;
      }
      _totalPrice = 0.0;
    });
  }

  void _updateTotalPrice() {
    double totalPrice = 0.0;
    for (int i = 0; i < _cartItems!.length; i++) {
      if (_isCheckedMap[i] == true) {
        totalPrice += double.tryParse(_cartItems![i].harga!) ?? 0.0;
      }
    }
    setState(() {
      _totalPrice = totalPrice;
    });
  }

  Future<void> _checkoutItems() async {
    List<String> checkoutItems = [];
    for (int i = 0; i < _cartItems!.length; i++) {
      if (_isCheckedMap[i] == true) {
        checkoutItems.add(_cartItems![i].nama!);
      }
    }

    _showNotification('Barang berhasil di checkout!');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Checkout berhasil. Terima kasih!'),
        duration: Duration(seconds: 2),
      ),
    );

    setState(() {
      // Menghapus elemen yang tercentang dari daftar
      _cartItems!.removeWhere((item) {
        int index = _cartItems!.indexOf(item);
        return _isCheckedMap[index] == true;
      });

      // Menghapus centang dan mereset harga total
      _isCheckedMap.clear();
      _totalPrice = 0.0;
    });
  }

  String _formatRupiah(dynamic price) {
    final value = price is String
        ? int.tryParse(price) ?? 0
        : price is double
            ? price.toInt()
            : price;
    return value.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
}
