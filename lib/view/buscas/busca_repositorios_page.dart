import 'package:flutter/material.dart';
import '../../service/github_service.dart';

class BuscaRepositorios extends StatefulWidget {
    const BuscaRepositorios({super.key});

    @override
    State<BuscaRepositorios> createState() => _BuscaRepositoriosState();
}

class _BuscaRepositoriosState extends State<BuscaRepositorios> {
    Future<Map<String, dynamic>>? resultado;
    final apiService = GithubService();

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text('Buscar repositórios'),
                centerTitle: true,
                leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                        Navigator.pop(context);
                    },
                ),
            ),
            body: Padding(
                padding: EdgeInsets.all(10.0),
                child: SingleChildScrollView(
                    child: Column(children: [
                        TextField(
                            decoration: InputDecoration(
                                labelText: "Digite o nome do repositório",
                                labelStyle: TextStyle(color: Colors.white),
                                border: OutlineInputBorder(),
                            ),
                            style: TextStyle(color: Colors.white, fontSize: 18),
                            onSubmitted: (value) {
                                setState(() {
                                    resultado = apiService.getRepositories(value.trim(), 1);
                                });
                            },
                        ),
                        if (resultado != null)
                            FutureBuilder<Map<String, dynamic>>(
                                future: resultado,
                                builder: (context, snapshot) {
                                    switch (snapshot.connectionState) {
                                        case ConnectionState.waiting:
                                        case ConnectionState.none:
                                            return CircularProgressIndicator(
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                strokeWidth: 5.0,
                                            );
                                        default:
                                            if (snapshot.hasError) {
                                                return Center(
                                                    child: Text(
                                                        'Erro ao buscar os dados.',
                                                        style: TextStyle(color: Colors.white),
                                                    ),
                                                );
                                            }

                                            var items = snapshot.data?["items"];

                                            if (items == null || (items as List).isEmpty) {
                                                return Center(
                                                    child: Text(
                                                        'Nenhum repositório encontrado.',
                                                        style: TextStyle(color: Colors.white),
                                                    ),
                                                );
                                            }

                                            return Column(
                                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                                children: [
                                                    exibeResultado(context, items),
                                                ],
                                            );
                                    }
                                },
                            ),
                    ]),
                ),
            ),
        );
    }

    Widget exibeResultado(BuildContext context, List items) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: items.map((repo) {
                String dados = "";
                dados += "Nome: ${repo["name"] ?? ""}\n";
                dados += "Dono: ${repo["owner"]?["login"] ?? ""}\n";
                dados += "Descrição: ${repo["description"] ?? ""}\n";
                dados += "Linguagem: ${repo["language"] ?? ""}\n";
                dados += "Estrelas: ${repo["stargazers_count"] ?? 0}\n\n";

                return Text(
                    dados,
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                );
            }).toList(),
        );
    }
}
