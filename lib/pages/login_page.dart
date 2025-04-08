import 'package:flutter/material.dart';
import 'driver_main_page.dart';
import 'driver_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String _selectedUserType = 'driver';
  bool _isDriverHovered = false;
  bool _isClientHovered = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section
            // In the build method, update the Image.asset path
            Container(
              height: 240,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF181D48), Color(0xFF3C348B)],
                ),
              ),
              child: Center(
                child: Image.asset(
                  'assets/bypass_logo.png', // Updated path to match your file location
                  width: 160,
                  height: 160,
                ),
              ),
            ),
            // Login form
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildUserTypeButtons(),
                  const SizedBox(height: 24),
                  _buildLoginForm(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTypeButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildUserTypeButton(
            title: 'DRIVER',
            icon: Icons.local_shipping,
            color: const Color(0xFFE3531C),
            isSelected: _selectedUserType == 'driver',
            onTap: () => setState(() => _selectedUserType = 'driver'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildUserTypeButton(
            title: 'CLIENT',
            icon: Icons.person,
            color: const Color(0xFFF3B334),
            isSelected: _selectedUserType == 'client',
            onTap: () => setState(() => _selectedUserType = 'client'),
          ),
        ),
      ],
    );
  }

  Widget _buildUserTypeButton({
    required String title,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? color : const Color(0xFF181D48),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        TextField(
          controller: _usernameController,
          decoration: const InputDecoration(
            labelText: 'Username',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _handleLogin,
          child: const Text('LOGIN'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }

  void _handleLogin() {
    if (_selectedUserType == 'driver') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DriverPage()),
      );
    } else {
      // Handle client login
    }
  }
}