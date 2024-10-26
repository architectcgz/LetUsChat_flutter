import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget buildTextField({
  required TextEditingController controller,
  required String label,
  bool obscureText = false,
  TextInputType keyboardType = TextInputType.text,
  List<TextInputFormatter>? inputFormatters
}) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(labelText: label),
    obscureText: obscureText,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
  );
}