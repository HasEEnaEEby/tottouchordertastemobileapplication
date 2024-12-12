import 'package:flutter/material.dart';
import 'package:tottouchordertastemobileapplication/screens/dashboard_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // Clean white background for the AppBar
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.deepOrange),
          onPressed: () {
            Navigator.pop(context); // Go back to previous screen
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Image.asset(
              'assets/images/AppLogo.png',
              height: 30,
            ), // Logo in the app bar
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // App Logo
                CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.orange.shade100,
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/AppLogo.png',
                      fit: BoxFit.cover,
                      height: 160,
                      width: 160,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Email Input Field
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.black87),
                    filled: true,
                    fillColor: Color.fromARGB(255, 166, 96, 52),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 18, horizontal: 15),
                  ),
                ),
                const SizedBox(height: 15),

                // Password Input Field
                const TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.black87),
                    filled: true,
                    fillColor: Color.fromARGB(255, 166, 96, 52),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 18, horizontal: 15),
                  ),
                ),
                const SizedBox(height: 25),

                // Login Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    backgroundColor: const Color.fromARGB(255, 241, 130, 96),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DashboardScreen()),
                    );
                  },
                  child: const Text(
                    'Log In',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                const SizedBox(height: 25),

                // Sign Up Text Button
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/sign-in');
                  },
                  child: const Text(
                    'Don\'t have an account? Sign Up',
                    style: TextStyle(
                        color: Color.fromARGB(255, 100, 30, 8), fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
