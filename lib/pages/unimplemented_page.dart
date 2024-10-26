import 'package:flutter/material.dart';

class UnImplementedPage extends StatelessWidget {
  const UnImplementedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('功能未实现'),
      ),
      body: const Center(
        child: Text(
          '该功能尚未完成，请之后再试。',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
