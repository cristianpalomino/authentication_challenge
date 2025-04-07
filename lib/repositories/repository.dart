import 'package:cloud_functions/cloud_functions.dart';

abstract class AuthRepository {
  Future<String?> callHelloWorld();
  Future<Map<String, dynamic>?> sendAuthCode(String email);
  Future<void> deleteAuthCode(String verificationId);
  Future<Map<String, dynamic>?> verifyAuthCode(
      String verificationId, String code);
}

class FirebaseRepository implements AuthRepository {
  final _functions = FirebaseFunctions.instance;

  @override
  Future<String?> callHelloWorld() async {
    final callable = _functions.httpsCallable('hello_world');
    final result = await callable.call();
    return result.data as String?;
  }

  @override
  Future<Map<String, dynamic>?> sendAuthCode(String email) async {
    final callable = _functions.httpsCallable('send_auth_code_on_call');
    final result = await callable.call({
      'email': email,
      'service': 'sengrid',
    });
    return result.data as Map<String, dynamic>?;
  }

  @override
  Future<void> deleteAuthCode(String verificationId) async {
    final callable = _functions.httpsCallable('delete_auth_code_on_call');
    await callable.call({'verification_id': verificationId});
  }

  @override
  Future<Map<String, dynamic>?> verifyAuthCode(
      String verificationId, String code) async {
    final callable = _functions.httpsCallable('verify_auth_code_on_call');
    final result = await callable.call({
      'verification_id': verificationId,
      'code': code,
    });
    return result.data as Map<String, dynamic>?;
  }
}
