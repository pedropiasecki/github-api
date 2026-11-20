import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/my_button.dart';
import 'buscas/busca_repositorios_page.dart';
import 'buscas/busca_perfis_page.dart';
import 'buscas/busca_issues_page.dart';

class HomePage extends StatelessWidget {
    const HomePage({super.key});
    @override
    Widget build(BuildContext context) {
        final user = FirebaseAuth.instance.currentUser!;
        return Scaffold(
        appBar: AppBar(
            title: const Text('Início'),
            actions: [
            IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => FirebaseAuth.instance.signOut(),
            ),
            ],
        ),
        body: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
            child: Column(
            children: [
                Text('Olá, ${user.email}', style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 20),
                MyButton(
                    text: 'Buscar repositórios',
                    icon: Icons.folder_special,
                    onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const BuscaRepositorios()),
                        );
                    },
                ),
                const SizedBox(height: 20),
                MyButton(
                    text: 'Buscar perfis',
                    icon: Icons.person_search,
                    onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const BuscaPerfis()),
                        );
                    },
                ),
                const SizedBox(height: 20),
                MyButton(
                    text: 'Buscar issues',
                    icon: Icons.bug_report,
                    onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const BuscaIssues()),
                        );
                    },
                ),
            ],
            ),
            ),
        ),
        );
    }
}
