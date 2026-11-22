import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
    const MyTextField({
        super.key,
        required this.controller,
        required this.hintText,
        required this.icon,
        this.isPassword = false,
        this.maxLines = 1,
        this.maxLength,
        this.keyboardType,
        this.textCapitalization = TextCapitalization.none,
    });
    final TextEditingController controller;
    final String hintText;
    final IconData icon;
    final bool isPassword;
    final int maxLines;
    final int? maxLength;
    final TextInputType? keyboardType;
    final TextCapitalization textCapitalization;
    @override
    State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
    bool hide = true;
    @override
    Widget build(BuildContext context) {
        return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: TextField(
            controller: widget.controller,
            obscureText: widget.isPassword && hide,
            maxLines: widget.isPassword ? 1 : widget.maxLines,
            maxLength: widget.maxLength,
            keyboardType: widget.keyboardType,
            textCapitalization: widget.textCapitalization,
            decoration: InputDecoration(
            prefixIcon: Icon(widget.icon),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(hide ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => hide = !hide),
                    )
                : null,
            hintText: widget.hintText,
            filled: true,
            fillColor: const Color(0xFF151E31),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
            ),
            ),
        ),
        );
    }
}
