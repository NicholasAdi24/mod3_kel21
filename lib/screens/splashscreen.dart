import 'package:flutter/material.dart';
import 'home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isAuthenticating = false;
  bool isAuthenticated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kelompok 21 PPB'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Kelompok 21 PPB',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () {
                // Logika otentikasi
                if (usernameController.text == 'kel21' &&
                    passwordController.text == '21') {
                  setState(() {
                    isAuthenticated = true;
                    isAuthenticating = false;
                  });
                  // Navigasi ke halaman Home jika otentikasi berhasil
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                } else {
                  // Pesan kesalahan jika otentikasi gagal
                  setState(() {
                    isAuthenticating = true;
                  });
                }
              },
              child: Text('Login'),
            ),
            if (isAuthenticating)
              Text(
                'Username atau password salah',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
