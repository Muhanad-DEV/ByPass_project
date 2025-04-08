import 'package:flutter/material.dart';

class DriverMainPage extends StatelessWidget {
  const DriverMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
      ),
      body: const Center(
        child: Text('Welcome Driver!'),
      ),
    );
  }
}