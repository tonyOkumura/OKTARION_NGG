import 'package:flutter/material.dart';
import 'dart:ui';

class GlassTextField extends StatelessWidget {
  const GlassTextField({
    super.key,
    required this.controller,
    required this.label,
    this.prefixIcon,
    this.keyboardType,
    this.maxLines = 1,
    this.hintText,
    this.onChanged,
    this.suffix,
    this.obscureText = false,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final Widget? suffix;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(
              color: cs.surface.withOpacity(0.35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: cs.primary.withOpacity(0.25),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                if (prefixIcon != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: Icon(prefixIcon, color: cs.primary),
                  ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    maxLines: maxLines,
                    obscureText: obscureText,
                    textInputAction: textInputAction,
                    onSubmitted: onSubmitted,
                    onChanged: onChanged,
                    decoration: InputDecoration(
                      labelText: label,
                      hintText: hintText,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                    ),
                  ),
                ),
                if (suffix != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: suffix!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


