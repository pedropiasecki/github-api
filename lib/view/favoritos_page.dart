import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../models/favorito_model.dart';
import '../service/auth_service.dart';
import '../service/sync_service.dart';
import 'details_page.dart';

// Lista dos repositórios favoritados pelo usuário.
class FavoritosPage extends StatefulWidget {
    const FavoritosPage({super.key});

    @override
    State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
    final syncService = SyncService();

    List<Favorito> favoritos = [];
    bool carregando = true;
    bool online = true;
    StreamSubscription? conexaoSub;

    @override
    void initState() {
        super.initState();
        carregar();
        // Quando a conexão mudar, sincroniza e atualiza a lista
        conexaoSub = Connectivity().onConnectivityChanged.listen((_) => carregar());
    }

    @override
    void dispose() {
        conexaoSub?.cancel();
        super.dispose();
    }

    Future<void> carregar() async {
        final userId = AuthService().usuario!.uid;
        await syncService.sincronizar(userId);
        final lista = await syncService.listarFavoritos(userId);
        final conectado = await syncService.temInternet();

        if (!mounted) return;
        setState(() {
            favoritos = lista;
            online = conectado;
            carregando = false;
        });
    }

    Future<void> abrirDetalhes(Favorito favorito) async {
        await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailsPage(favorito: favorito)),
        );
        carregar();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: const Text('Favoritos')),
            body: Column(
                children: [
                    if (!online)
                        Container(
                            width: double.infinity,
                            color: Colors.orange,
                            padding: const EdgeInsets.all(8),
                            child: const Text(
                                'Sem internet: modo offline',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black),
                            ),
                        ),
                    Expanded(
                        child: carregando
                            ? const Center(child: CircularProgressIndicator())
                            : RefreshIndicator(
                                onRefresh: carregar,
                                child: favoritos.isEmpty
                                    ? ListView(
                                        children: const [
                                            Padding(
                                                padding: EdgeInsets.all(30),
                                                child: Text(
                                                    'Nenhum favorito ainda. Busque um repositório e toque na estrela para favoritar.',
                                                    textAlign: TextAlign.center,
                                                ),
                                            ),
                                        ],
                                    )
                                    : ListView.builder(
                                        itemCount: favoritos.length,
                                        itemBuilder: (context, indice) {
                                            final favorito = favoritos[indice];
                                            return Card(
                                                margin: const EdgeInsets.symmetric(
                                                    horizontal: 12, vertical: 4),
                                                child: ListTile(
                                                    title: Text(favorito.nome),
                                                    subtitle: Text(
                                                        '${favorito.linguagem.isEmpty ? 'Sem linguagem' : favorito.linguagem} • ${favorito.estrelas} estrelas\n${Favorito.formatarData(favorito.criadoEm)} • ${favorito.synced ? 'Sincronizado' : 'Pendente de envio'}',
                                                    ),
                                                    isThreeLine: true,
                                                    trailing: Icon(favorito.synced
                                                        ? Icons.cloud_done
                                                        : Icons.cloud_off),
                                                    onTap: () => abrirDetalhes(favorito),
                                                ),
                                            );
                                        },
                                    ),
                            ),
                    ),
                ],
            ),
        );
    }
}
