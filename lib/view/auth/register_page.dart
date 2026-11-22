import 'package:apk_auth/components/my_texfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../components/my_button.dart';
import '../../service/auth_service.dart';

class RegisterPage extends StatefulWidget {
    const RegisterPage({super.key});

    @override
    State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    final authService = AuthService();

    @override
    void dispose() {
        nameController.dispose();
        emailController.dispose();
        passwordController.dispose();
        confirmController.dispose();
        super.dispose();
    }

    void showAlert(String message) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(content: Text(message)),
        );
    }

    Future<void> register() async {
        final name = nameController.text.trim();

        if (name.isEmpty ||
            emailController.text.trim().isEmpty ||
            passwordController.text.isEmpty ||
            confirmController.text.isEmpty) {
            showAlert('Preencha todos os campos.');
            return;
        }

        if (passwordController.text != confirmController.text) {
            showAlert('Senhas não conferem!');
            return;
        }

        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(
                child: CircularProgressIndicator(),
            ),
        );

        try {
            await authService.cadastrar(
                name,
                emailController.text.trim(),
                passwordController.text,
            );

            if (!mounted) return;
            Navigator.pop(context); // fecha o loading
            Navigator.pop(context); // fecha a RegisterPage
        } on FirebaseAuthException catch (e) {
            if (!mounted) return;
            Navigator.pop(context);
            showAlert(switch (e.code) {
                'email-already-in-use' => 'Já existe um usuário com esse email!',
                'weak-password' => 'Escolha uma senha mais forte.',
                'invalid-email' => 'Email inválido.',
                'network-request-failed' => 'Sem conexão com a internet.',
                _ => 'Não foi possível cadastrar. Tente novamente.',
            });
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                leading: const BackButton(),
                title: const Text('Crie sua conta'),
            ),
            body: Center(
                child: SingleChildScrollView(
                    child: Column(
                        children: [
                            MyTextField(
                                controller: nameController,
                                hintText: 'Nome completo',
                                icon: Icons.person_outline,
                                keyboardType: TextInputType.name,
                                textCapitalization: TextCapitalization.words,
                            ),
                            const SizedBox(height: 15),
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
                            const SizedBox(height: 15),
                            MyTextField(
                                controller: confirmController,
                                hintText: 'Confirmar senha',
                                icon: Icons.lock_outline,
                                isPassword: true,
                            ),
                            const SizedBox(height: 25),
                            MyButton(
                                onTap: register,
                                text: 'Registrar',
                                icon: Icons.person_add,
                            ),
                        ],
                    ),
                ),
            ),
        );
    }
}
