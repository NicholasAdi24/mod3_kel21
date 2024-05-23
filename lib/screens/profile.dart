import 'package:flutter/material.dart';
import 'home.dart'; // Import halaman "home.dart"

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final List<Map<String, String>> teamMembers = [
    {
      'Nama': 'Nicholas Priyambodo Adi',
      'NIM': '21120121120026',
    },
    {
      'Nama': 'Zaqi Ayuna Putri',
      'NIM': '21120121140084',
    },
    {
      'Nama': 'Thufail Azzam',
      'NIM': '21120121140104',
    },
    {
      'Nama': 'Fadhillah Zainum Muttaqin',
      'NIM': '21120121140131',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              // Navigasi ke halaman "home.dart" saat tombol "Home" ditekan
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var member in teamMembers)
              ListTile(
                title: Text('Nama: ${member['Nama']}'),
                subtitle: Text('NIM: ${member['NIM']}'),
              ),
          ],
        ),
      ),
      // Tambahkan bottomNavigationBar untuk navbar
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 1, // Index kedua (Profile) dipilih awal
        onTap: (index) {
          if (index == 0) {
            // Navigasi ke halaman Home
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => HomePage(),
            ));
          } else if (index == 1) {
            // Tidak perlu tindakan tambahan (kita sudah ada di halaman Profile)
          }
        },
      ),
    );
  }
}
