import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/core.dart';

class AuthIdentifierField extends StatelessWidget {
  const AuthIdentifierField({
    super.key, 
    required this.controller,
    this.onSubmitted,
    this.passwordFocusNode,
  });
  
  final dynamic controller; // LoginController
  final VoidCallback? onSubmitted;
  final FocusNode? passwordFocusNode;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isReg = controller.isRegisterMode.value;

      String labelText;
      IconData prefixIcon;
      TextInputType keyboardType;
      List<TextInputFormatter> inputFormatters;

      if (isReg) {
        labelText = 'Email';
        prefixIcon = Icons.email_outlined;
        keyboardType = TextInputType.emailAddress;
        inputFormatters = [
          InputFormatterHelper.noSpacesFormatter,
          LengthLimitingTextInputFormatter(64),
        ];
      } else {
        labelText = 'Email';
        prefixIcon = Icons.email_outlined;
        keyboardType = TextInputType.emailAddress;
        inputFormatters = [
          InputFormatterHelper.noSpacesFormatter,
          LengthLimitingTextInputFormatter(64),
        ];
      }

      return TextFormField(
        controller: controller.emailController,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        inputFormatters: inputFormatters,
        onFieldSubmitted: (_) {
          // Фокусируемся на поле пароля при нажатии Enter
          if (passwordFocusNode != null) {
            passwordFocusNode!.requestFocus();
          } else {
            FocusScope.of(context).nextFocus();
          }
        },
        decoration: InputDecoration(
          labelText: labelText,
          hintText: isReg ? 'Введите email' : 'Введите email',
          prefixIcon: Icon(prefixIcon),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller.emailController,
            builder: (context, value, _) {
              final txt = value.text;
              if (txt.isEmpty) return const SizedBox.shrink();

              String? err;
              if (isReg) {
                err = ValidationHelper.email(txt);
              } else {
                err = ValidationHelper.requiredField(txt);
              }

              final ok = err == null;
              return Icon(
                ok ? Icons.check_circle : Icons.error_outline,
                color: ok
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.error,
              );
            },
          ),
        ),
        onChanged: (raw) {
          final formatted = raw.replaceAll(' ', '');
          if (formatted != raw) {
            controller.emailController.value = TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(
                offset: formatted.length,
              ),
            );
          }
          // Уведомляем контроллер об изменении
          controller.onEmailChanged(formatted);
        },
        validator: (v) {
          if (!isReg) return ValidationHelper.requiredField(v);
          return ValidationHelper.email(v);
        },
      );
    });
  }
}
