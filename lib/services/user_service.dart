import 'package:flutter/foundation.dart';

class UserService {
  UserService._();
  static final UserService instance = UserService._();

  final ValueNotifier<String> nome = ValueNotifier<String>('Felipe');
  final ValueNotifier<String> email = ValueNotifier<String>('felipe@email.com');

  void atualizar({required String novoNome, required String novoEmail}) {
    nome.value = novoNome;
    email.value = novoEmail;
  }

  void reset() {
    nome.value = 'Felipe';
    email.value = 'felipe@email.com';
  }
}