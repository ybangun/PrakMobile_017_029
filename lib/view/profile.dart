import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import 'package:tugas_akhir_pm/hive/user.dart';
import 'package:tugas_akhir_pm/view/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late SharedPreferences loginData;
  User? _user;
  String _selectedTimezone = 'WIB';

  @override
  void initState() {
    super.initState();
    initial();
    _loadUserData();
  }

  void initial() async {
    loginData = await SharedPreferences.getInstance();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    if (username != null) {
      var box = Hive.box<User>('usersBox');
      User? user = box.values.firstWhere((user) => user.username == username);
      setState(() {
        _user = user;
      });
    }
  }

  Stream<String> _timeStream() async* {
    while (true) {
      yield _getCurrentTime();
      await Future.delayed(Duration(minutes: 1));
    }
  }

  String _getCurrentTime() {
    DateTime now = DateTime.now().toUtc();
    String formattedTime;
    switch (_selectedTimezone) {
      case 'WIB':
        formattedTime = DateFormat.Hm().format(now.add(Duration(hours: 7)));
        break;
      case 'WITA':
        formattedTime = DateFormat.Hm().format(now.add(Duration(hours: 8)));
        break;
      case 'WIT':
        formattedTime = DateFormat.Hm().format(now.add(Duration(hours: 9)));
        break;
      case 'London':
        bool isBST = _isBST(now);
        formattedTime = DateFormat.Hm().format(
          now.add(Duration(hours: isBST ? 1 : 0)),
        );
        break;
      default:
        formattedTime = DateFormat.Hm().format(now);
    }
    return formattedTime;
  }

  bool _isBST(DateTime date) {
    final lastSundayInMarch = DateTime(date.year, 3, 31)
        .subtract(Duration(days: DateTime(date.year, 3, 31).weekday));
    final lastSundayInOctober = DateTime(date.year, 10, 31)
        .subtract(Duration(days: DateTime(date.year, 10, 31).weekday));
    return date.isAfter(lastSundayInMarch) &&
        date.isBefore(lastSundayInOctober);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
            StreamBuilder<String>(
              stream: _timeStream(),
              builder: (context, snapshot) {
                return Text(snapshot.data ?? '');
              },
            ),
            DropdownButton<String>(
              value: _selectedTimezone,
              onChanged: (newValue) {
                setState(() {
                  _selectedTimezone = newValue!;
                });
              },
              items: <String>['London', 'WIB', 'WITA', 'WIT']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _user != null &&
                          _user!.imagePath != null &&
                          _user!.imagePath!.isNotEmpty
                      ? FileImage(File(_user!.imagePath!))
                      : NetworkImage(
                              'https://icons.veryicon.com/png/o/education-technology/big-data-platform/smile-14.png')
                          as ImageProvider,
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  _user?.username ?? 'No Username',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 16),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileDetailRow(
                          label: 'Username', value: _user?.username ?? ''),
                      ProfileDetailRow(
                          label: 'No Telp', value: _user?.noTelepon ?? ''),
                      ProfileDetailRow(
                          label: 'Alamat', value: _user?.alamat ?? ''),
                      ProfileDetailRow(
                          label: 'Email', value: _user?.email ?? ''),
                      ProfileDetailRow(label: 'Password', value: '********'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kesan:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'Cukup bagus untuk mahasiswa dalam bereksplorasi tentang apa saja yang dapat dilakukan pada Flutter.',
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Pesan:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'Kurangi kesulitan kuis dan perpanjang waktu kuis.',
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  loginData.setBool('login', true);
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => LoginPage()));
                },
                child: Text('Log out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileDetailRow extends StatelessWidget {
  final String label;
  final String value;

  ProfileDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
