import 'package:authentication_challenge/src/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/code_validation_widget.dart';
import '../widgets/email_verification_widget.dart';

class EmailVerificationScreen extends ConsumerWidget {
  const EmailVerificationScreen({super.key});

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
            EmailVerificationWidget()
          else
            CodeValidationWidget()
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
