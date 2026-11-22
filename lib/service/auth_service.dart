import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User? get usuario => _auth.currentUser;
    Stream<User?> get mudancas => _auth.userChanges();

    Future<void> entrar(String email, String senha) async {
        await _auth.signInWithEmailAndPassword(email: email, password: senha);
    }

    Future<void> cadastrar(String nome, String email, String senha) async {
        final credencial = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: senha,
        );
        // Guarda o nome completo no perfil do Firebase
        await credencial.user?.updateDisplayName(nome);
    }

    Future<void> recuperarSenha(String email) async {
        await _auth.sendPasswordResetEmail(email: email);
    }

    Future<void> sair() async {
        await _auth.signOut();
    }
}
