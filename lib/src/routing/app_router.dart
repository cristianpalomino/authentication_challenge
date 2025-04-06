import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/views/screens/home_screen.dart';
import '../features/auth/views/screens/email_verification_screen.dart';

final goRouterProvider = Provider<GoRouter>(
  (ref) {
    return GoRouter(
      initialLocation: HomeScreen.routePath,
      routes: [
        GoRoute(
          path: HomeScreen.routePath,
          name: HomeScreen.routeName,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: EmailVerificationScreen.routePath,
          name: EmailVerificationScreen.routeName,
          builder: (context, state) => const EmailVerificationScreen(),
        ),
      ],
    );
  },
);
