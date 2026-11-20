import 'package:flutter/material.dart';
import '../../service/github_service.dart';

class BuscaPerfis extends StatefulWidget {
    const BuscaPerfis({super.key});

    @override
    State<BuscaPerfis> createState() => _BuscaPerfisState();
}

class _BuscaPerfisState extends State<BuscaPerfis> {
    Future<Map<String, dynamic>>? resultado;
    final apiService = GithubService();

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text('Buscar perfis'),
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
                                labelText: "Digite o nome do perfil",
                                labelStyle: TextStyle(color: Colors.white),
                                border: OutlineInputBorder(),
                            ),
                            style: TextStyle(color: Colors.white, fontSize: 18),
                            onSubmitted: (value) {
                                setState(() {
                                    resultado = apiService.getUsers(value.trim(), 1);
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
                                                        'Nenhum perfil encontrado.',
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
            children: items.map((perfil) {
                String dados = "";
                dados += "Usuário: ${perfil["login"] ?? ""}\n";
                dados += "Perfil: ${perfil["html_url"] ?? ""}\n\n";

                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        if (perfil["avatar_url"] != null)
                            Image.network(
                                perfil["avatar_url"],
                                width: 80.0,
                                height: 80.0,
                                fit: BoxFit.cover,
                            ),
                        Text(
                            dados,
                            textAlign: TextAlign.left,
                            style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                    ],
                );
            }).toList(),
        );
    }
}
