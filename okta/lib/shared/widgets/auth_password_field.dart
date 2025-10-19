import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/core.dart';

class AuthPasswordField extends StatelessWidget {
  const AuthPasswordField({
    super.key, 
    required this.controller,
    this.onSubmitted,
    this.focusNode,
  });
  
  final dynamic controller; // LoginController
  final VoidCallback? onSubmitted;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => TextFormField(
        controller: controller.passwordController,
        focusNode: focusNode,
        obscureText: !controller.isPasswordVisible.value,
        onChanged: controller.evaluatePassword,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => onSubmitted?.call(),
        decoration: InputDecoration(
          labelText: 'Пароль',
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            onPressed: controller.togglePasswordVisibility,
            icon: Icon(
              controller.isPasswordVisible.value
                  ? Icons.visibility_off
                  : Icons.visibility,
            ),
          ),
        ),
        validator: ValidationHelper.password,
      ),
    );
  }
}
