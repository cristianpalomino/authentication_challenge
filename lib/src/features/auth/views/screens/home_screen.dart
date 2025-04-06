import 'email_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../view_models/home_view_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = 'home';
  static const String routePath = '/';

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(homeViewModelProvider.notifier).callCloudFunction();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Welcome to the Auth Challenge!'),
              const SizedBox(height: 20),
              if (homeState.isLoading) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
              ] else if (homeState.error != null) ...[
                Text('Error: ${homeState.error}',
                    style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 20),
              ] else if (homeState.response != null) ...[
                Text(homeState.response!,
                    style: const TextStyle(color: Colors.green)),
                const SizedBox(height: 20),
              ],
              ElevatedButton(
                onPressed: () {
                  context.push(EmailVerificationScreen.routePath);
                },
                child: const Text('Comenzar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
