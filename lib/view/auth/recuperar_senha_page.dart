import 'package:apk_auth/components/my_texfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../components/my_button.dart';
import '../../service/auth_service.dart';

class RecuperarSenhaPage extends StatefulWidget {
    const RecuperarSenhaPage({super.key});

    @override
    State<RecuperarSenhaPage> createState() => _RecuperarSenhaPageState();
}

class _RecuperarSenhaPageState extends State<RecuperarSenhaPage> {
    final emailController = TextEditingController();
    final authService = AuthService();

    @override
    void dispose() {
        emailController.dispose();
        super.dispose();
    }

    void showAlert(String message) {
        showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
                content: Text(message),
                actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('OK'),
                    ),
                ],
            ),
        );
    }

    Future<void> enviar() async {
        final email = emailController.text.trim();
        if (email.isEmpty) {
            showAlert('Digite seu email.');
            return;
        }

        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
        );
        try {
            await authService.recuperarSenha(email);
            if (!mounted) return;
            Navigator.pop(context); // fecha o loading
            showAlert('Se o email estiver cadastrado, enviamos um link para redefinir a senha.');
        } on FirebaseAuthException catch (e) {
            if (!mounted) return;
            Navigator.pop(context); // fecha o loading
            showAlert(switch (e.code) {
                'invalid-email' => 'Email inválido.',
                'network-request-failed' => 'Sem conexão com a internet.',
                _ => 'Não foi possível enviar o email. Tente novamente.',
            });
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: const Text('Recuperar senha')),
            body: Center(
                child: SingleChildScrollView(
                    child: Column(
                        children: [
                            const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 25),
                                child: Text(
                                    'Informe o email da sua conta para receber o link de redefinição de senha.',
                                    textAlign: TextAlign.center,
                                ),
                            ),
                            const SizedBox(height: 20),
                            MyTextField(
                                controller: emailController,
                                hintText: 'Email',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 25),
                            MyButton(
                                onTap: enviar,
                                text: 'Enviar link',
                                icon: Icons.send,
                            ),
                        ],
                    ),
                ),
            ),
        );
    }
}
