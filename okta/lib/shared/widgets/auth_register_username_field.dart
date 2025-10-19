import 'package:flutter/material.dart';

import '../../core/core.dart';

class AuthRegisterUsernameField extends StatelessWidget {
  const AuthRegisterUsernameField({
    super.key, 
    required this.controller,
    this.isVisible = true,
  });
  
  final TextEditingController controller;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: UIConstants.mediumAnimation,
      transitionBuilder: (child, animation) => SizeTransition(
        sizeFactor: animation,
        axisAlignment: -1.0,
        child: child,
      ),
      child: isVisible
          ? Padding(
              key: const ValueKey('username'),
              padding: const EdgeInsets.only(bottom: UIConstants.spacing12),
              child: TextFormField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Полное имя',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: ValidationHelper.requiredField,
              ),
            )
          : const SizedBox(key: ValueKey('no_username')),
    );
  }
}
