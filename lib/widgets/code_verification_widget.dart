import 'package:authentication_challenge/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

class CodeVerificationWidget extends ConsumerStatefulWidget {
  const CodeVerificationWidget({super.key});

  @override
  ConsumerState<CodeVerificationWidget> createState() =>
      _CodeVerificationWidgetState();
}

class _CodeVerificationWidgetState
    extends ConsumerState<CodeVerificationWidget> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final emailState = ref.watch(emailViewModelProvider);
    final emailViewModel = ref.read(emailViewModelProvider.notifier);
    final email = emailState.email;

    Future<bool> showExitConfirmationDialog() async {
      if (_isLoading) return false;
      return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Cancelar Verificación'),
              content: const Text(
                '¿Estás seguro de que quieres cancelar la verificación del código?',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () async {
                    if (_isLoading) return;
                    await emailViewModel.cancelVerification();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Verification cancelled.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      Navigator.of(context).pop(true);
                    }
                  },
                  child: const Text('Sí'),
                ),
              ],
            ),
          ) ??
          false;
    }

    return WillPopScope(
      onWillPop: showExitConfirmationDialog,
      child: Column(
        children: [
          Text('Enter the 6-digit code sent to $email.'),
          const SizedBox(height: 20),
          TextField(
            enabled: !_isLoading,
            decoration: InputDecoration(
              labelText: 'Código de verificación',
              hintText: 'Introduce el código de verificación',
              border: const OutlineInputBorder(),
              errorText: emailState.codeError,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: emailViewModel.setCode,
            maxLength: 6,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: (emailState.isCodeValid && !_isLoading)
                ? () async {
                    setState(() {
                      _isLoading = true;
                    });
                    try {
                      await emailViewModel.verifyCode(context);

                      if (context.mounted) {
                        final newState = ref.read(emailViewModelProvider);
                        final error = newState.codeError;
                        final bool success = error == null || error.isEmpty;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success ? 'Email verified successfully!' : error,
                            ),
                            backgroundColor:
                                success ? Colors.green : Colors.red,
                          ),
                        );

                        if (success) Navigator.of(context).pop();
                      }
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  }
                : null,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Verificar email'),
          ),
        ],
      ),
    );
  }
}
