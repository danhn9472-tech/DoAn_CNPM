import 'package:flutter/material.dart';
import '../views/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String? label; // Made label optional
  final String hint;
  final TextEditingController controller;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator; // Add validator property

  const CustomTextField({
    super.key,
    this.label, // No longer required
    required this.hint,
    required this.controller,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.validator, // Initialize validator
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && label!.isNotEmpty) ...[ // Conditionally render label
          Text(label!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
          const SizedBox(height: 8),
        ],
        
        TextFormField(
          controller: controller,
          validator: validator, // Pass validator to TextFormField
          obscureText: obscureText,
          decoration: InputDecoration(
            prefixIcon: Icon(prefixIcon, color: AppColors.textMuted),
            suffixIcon: suffixIcon,
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          ),
        ),
      ],
    );
  }
}