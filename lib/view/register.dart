import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:tugas_akhir_pm/hive/user.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  File? _image;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _noTeleponController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  String _encryptPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _register() async {
    if (_usernameController.text.isEmpty ||
        _noTeleponController.text.isEmpty ||
        _alamatController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showErrorDialog('Harap Isi Data Anda!', 'Inputan Tidak Boleh Kosong');
      return;
    }

    if (!_emailController.text.contains('@')) {
      _showErrorDialog(
          'Email Tidak Valid!', 'Email yang Anda masukkan tidak valid.');
      return;
    }

    var box = Hive.box<User>('usersBox');
    bool emailExists =
        box.values.any((user) => user.email == _emailController.text);
    if (emailExists) {
      _showErrorDialog('Email Sudah Digunakan!',
          'Email yang Anda masukkan sudah terdaftar.');
      return;
    }

    String encryptedPassword = _encryptPassword(_passwordController.text);

    User newUser = User(
      username: _usernameController.text,
      noTelepon: _noTeleponController.text,
      alamat: _alamatController.text,
      email: _emailController.text,
      password: encryptedPassword,
      imagePath: _image?.path,
      carts: [],
    );

    await box.add(newUser);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Register",
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                SizedBox(height: 20.0),
                Text(
                  "Selamat Datang di Toko Komputer",
                  style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
                ),
                SizedBox(height: 30.0),
                _buildInputCard(),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: _register,
                  child: Text(
                    "Register",
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 100.0, vertical: 15.0),
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Text(
                  "Sudah memiliki akun?",
                  style: TextStyle(color: Colors.grey[700]),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text("Masuk"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(controller: _usernameController, label: "Username"),
            SizedBox(height: 10.0),
            _buildTextField(
                controller: _noTeleponController, label: "No Telepon"),
            SizedBox(height: 10.0),
            _buildTextField(controller: _alamatController, label: "Alamat"),
            SizedBox(height: 10.0),
            _buildTextField(controller: _emailController, label: "Email"),
            SizedBox(height: 10.0),
            _buildTextField(
                controller: _passwordController,
                label: "Password",
                obscureText: true),
            SizedBox(height: 15.0),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text("Upload Gambar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                SizedBox(width: 10.0),
                _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.file(
                          _image!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.purple),
        ),
      ),
    );
  }
}
