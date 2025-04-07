import 'package:authentication_challenge/widgets/code_verification_widget.dart';
import 'package:authentication_challenge/widgets/email_validation_widget.dart';
import 'package:authentication_challenge/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmailScreen extends ConsumerWidget {
  const EmailScreen({super.key});

  static const String routeName = 'verify-email';
  static const String routePath = '/verify-email';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verificationId = ref.watch(verificationIdProvider);

    final Widget body = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (verificationId == null)
            EmailValidationWidget()
          else
            CodeVerificationWidget()
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: body,
    );
  }
}
