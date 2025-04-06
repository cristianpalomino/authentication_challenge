import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:authentication_challenge/src/providers.dart';

class EmailVerificationWidget extends ConsumerWidget {
  const EmailVerificationWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(emailProvider);

    return Column(
      children: [
        const Text('Enter your email address to receive a verification code.'),
        const SizedBox(height: 20),
        TextField(
          // Changed to TextField
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'Enter your email',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) => ref.read(emailProvider.notifier).state = value,
          autocorrect: false,
          textCapitalization: TextCapitalization.none,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            print('Sending code to: $email');
            // Simulate code sent - replace with actual logic
            ref.read(verificationIdProvider.notifier).state =
                'dummy-verification-id';
          },
          child: const Text('Enviar código de verificación'),
        ),
      ],
    );
  }
}
