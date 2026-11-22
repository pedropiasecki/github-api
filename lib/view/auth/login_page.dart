import 'package:apk_auth/components/my_texfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../components/my_button.dart';
import '../../service/auth_service.dart';
import 'recuperar_senha_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
    const LoginPage({super.key});
    @override
    State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final authService = AuthService();

    @override
    void dispose() {
        emailController.dispose();
        passwordController.dispose();
        super.dispose();
    }

    void showAlert(String message) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                content: Text(message),
                actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                    ),
                ],
            ),
        );
    }

    Future<void> signIn() async {
        final email = emailController.text.trim();
        final senha = passwordController.text;

        if (email.isEmpty || senha.isEmpty) {
            showAlert('Preencha o email e a senha.');
            return;
        }

        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
        );
        try {
            await authService.entrar(email, senha);
            if (!mounted) return;
            Navigator.pop(context); // fecha o loading
        } on FirebaseAuthException catch (e) {
            if (!mounted) return;
            Navigator.pop(context); // fecha o loading
            showAlert(switch (e.code) {
                'invalid-credential' ||
                'wrong-password' ||
                'user-not-found' => 'Email ou senha incorretos.',
                'invalid-email' => 'Email inválido.',
                'network-request-failed' => 'Sem conexão com a internet.',
                'too-many-requests' =>
                    'Muitas tentativas. Aguarde um pouco e tente de novo.',
                _ => 'Não foi possível entrar. Tente novamente.',
            });
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: SafeArea(
                child: Center(
                    child: SingleChildScrollView(
                        child: Column(
                            children: [
                                Image.asset('assets/logo-auth.png', height: 100),
                                const SizedBox(height: 20),
                                const Text(
                                    'Bem-vindo de volta!',
                                    style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                    ),
                                ),
                                const SizedBox(height: 25),
                                MyTextField(
                                    controller: emailController,
                                    hintText: 'Email',
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 15),
                                MyTextField(
                                    controller: passwordController,
                                    hintText: 'Senha',
                                    icon: Icons.lock_outline,
                                    isPassword: true,
                                ),
                                TextButton(
                                    onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => const RecuperarSenhaPage(),
                                        ),
                                    ),
                                    child: const Text('Recuperar senha'),
                                ),
                                MyButton(
                                    onTap: signIn,
                                    text: 'Entrar',
                                    icon: Icons.login,
                                ),
                                const SizedBox(height: 15),
                                TextButton(
                                    onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => const RegisterPage(),
                                        ),
                                    ),
                                    child: const Text('Cadastre-se aqui'),
                                ),
                            ],
                        ),
                    ),
                ),
            ),
        );
    }
}
