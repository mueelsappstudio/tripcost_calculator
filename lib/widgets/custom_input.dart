import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class CustomInput extends StatelessWidget {
  final String label;
  final String? placeholder;
  final IconData? icon;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final String? initialValue;

  const CustomInput({
    super.key,
    required this.label,
    this.placeholder,
    this.icon,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.controller,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: controller,
            initialValue: controller == null ? initialValue : null,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textMain,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
              prefixIcon: icon != null
                  ? Icon(icon, color: AppColors.textSecondary, size: 20)
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: onChanged,
            inputFormatters: keyboardType == TextInputType.number
                ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
                : null,
          ),
        ),
      ],
    );
  }
}