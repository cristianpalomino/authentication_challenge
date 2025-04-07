import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

class EmailValidationWidget extends ConsumerWidget {
  const EmailValidationWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailState = ref.watch(emailViewModelProvider);
    final emailViewModel = ref.read(emailViewModelProvider.notifier);

    return Column(
      children: [
        const Text('Enter your email address to receive a verification code.'),
        const SizedBox(height: 20),
        TextField(
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Enter your email',
            border: const OutlineInputBorder(),
            errorText: emailState.error,
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) => emailViewModel.setEmail(value),
          autocorrect: false,
          textCapitalization: TextCapitalization.none,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: emailState.isValid && !emailState.isLoading
              ? () {
                  emailViewModel.sendVerificationCode();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Verification code sent!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              : null,
          child: emailState.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Send Verification Code'),
        ),
      ],
    );
  }
}
