import 'package:authentication_challenge/src/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _codeProvider = StateProvider<String>((ref) => '');

class CodeValidationWidget extends ConsumerWidget {
  const CodeValidationWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(emailProvider);

    return Column(
      children: [
        Text('Enter the 6-digit code sent to $email.'),
        const SizedBox(height: 20),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Código de verificación',
            hintText: 'Introduce el código de verificación',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          // TODO: Add input formatters for 6 digits
          onChanged: (value) => ref.read(_codeProvider.notifier).state = value,
          maxLength: 6,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          // Changed to ElevatedButton
          onPressed: () {
            // TODO: Implement verification logic via ViewModel
            final code = ref.read(_codeProvider);
            print('Verifying code: $code for email: $email');
            // TODO: Navigate on success or show error
          },
          child: const Text('Verificar email'),
        ),
      ],
    );
  }
}
