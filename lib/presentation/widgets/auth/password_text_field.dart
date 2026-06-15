import 'package:flutter/material.dart';

class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;

  const PasswordTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.prefixIcon,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      style: const TextStyle(overflow: TextOverflow.ellipsis),
      decoration: InputDecoration(
        isDense: true,
        hintText: widget.hint,
        prefixIcon: Icon(widget.prefixIcon, color: const Color(0xFFB9AA97)),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}
