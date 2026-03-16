import 'package:flutter/material.dart';

class GlassTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPassword;

  const GlassTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.isPassword = false,
  });

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField> {
  bool obscure = true;
  bool isFocus = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (value) {
        setState(() {
          isFocus = value;
        });
      },
      child: TextField(
        controller: widget.controller,
        obscureText: widget.isPassword ? obscure : false,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(widget.icon, color: Colors.white),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      obscure = !obscure;
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: isFocus
              ? const Color(0xff00c6ff).withOpacity(0.25)
              : Colors.white.withOpacity(0.08),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
