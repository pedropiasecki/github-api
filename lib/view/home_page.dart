import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/my_button.dart';
import '../service/auth_service.dart';
import '../service/sync_service.dart';
import 'buscas/busca_repositorios_page.dart';
import 'buscas/busca_perfis_page.dart';
import 'buscas/busca_issues_page.dart';
import 'calendar_page.dart';
import 'favoritos_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
    const HomePage({super.key});

    @override
    State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
    final authService = AuthService();
    final syncService = SyncService();
    StreamSubscription? conexaoSub;

    @override
    void initState() {
        super.initState();
        sincronizar(); // sincroniza sempre que a conexão volta
        conexaoSub = Connectivity().onConnectivityChanged.listen((_) => sincronizar());
    }

    @override
    void dispose() {
        conexaoSub?.cancel();
        super.dispose();
    }

    Future<void> sincronizar() async {
        final userId = authService.usuario?.uid;
        if (userId == null) return;

        final enviados = await syncService.sincronizar(userId);
        if (enviados > 0 && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('$enviados favorito(s) sincronizado(s) com o Firebase.'),
                ),
            );
        }
    }

    void abrir(Widget pagina) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => pagina));
    }

    @override
    Widget build(BuildContext context) {
        return StreamBuilder<User?>(
            stream: authService.mudancas,
            initialData: authService.usuario,
            builder: (context, snapshot) {
                final user = snapshot.data;
                final displayName = user?.displayName?.trim() ?? '';
                final name = displayName.isNotEmpty ? displayName : (user?.email ?? '');
                return Scaffold(
                    appBar: AppBar(
                        title: const Text('Github API'),
                        actions: [
                            IconButton(
                                icon: const Icon(Icons.star),
                                tooltip: 'Favoritos',
                                onPressed: () => abrir(const FavoritosPage()),
                            ),
                            IconButton(
                                icon: const Icon(Icons.calendar_month),
                                tooltip: 'Calendário',
                                onPressed: () => abrir(const CalendarPage()),
                            ),
                            IconButton(
                                icon: const Icon(Icons.account_circle),
                                tooltip: 'Meu perfil',
                                onPressed: () => abrir(const ProfilePage()),
                            ),
                            IconButton(
                                icon: const Icon(Icons.logout),
                                tooltip: 'Sair',
                                onPressed: () => authService.sair(),
                            ),
                        ],
                    ),
                    body: Padding(
                        padding: const EdgeInsets.all(20),
                        child: SingleChildScrollView(
                            child: Column(
                                children: [
                                    Text('Olá, $name', style: const TextStyle(fontSize: 20)),
                                    const SizedBox(height: 20),
                                    MyButton(
                                        text: 'Buscar repositórios',
                                        icon: Icons.folder_special,
                                        onTap: () => abrir(const BuscaRepositorios()),
                                    ),
                                    const SizedBox(height: 20),
                                    MyButton(
                                        text: 'Buscar perfis',
                                        icon: Icons.person_search,
                                        onTap: () => abrir(const BuscaPerfis()),
                                    ),
                                    const SizedBox(height: 20),
                                    MyButton(
                                        text: 'Buscar issues',
                                        icon: Icons.bug_report,
                                        onTap: () => abrir(const BuscaIssues()),
                                    ),
                                ],
                            ),
                        ),
                    ),
                );
            },
        );
    }
}
