import 'package:flutter_riverpod/flutter_riverpod.dart';

final verificationIdProvider = StateProvider<String?>(
  (ref) => null,
);

final emailProvider = StateProvider<String>(
  (ref) => '',
);
