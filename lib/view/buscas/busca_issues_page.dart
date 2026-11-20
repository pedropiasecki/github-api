import 'package:flutter/material.dart';
import '../../service/github_service.dart';

class BuscaIssues extends StatefulWidget {
    const BuscaIssues({super.key});

    @override
    State<BuscaIssues> createState() => _BuscaIssuesState();
}

class _BuscaIssuesState extends State<BuscaIssues> {
    Future<Map<String, dynamic>>? resultado;
    final apiService = GithubService();

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text('Buscar issues'),
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
                                labelText: "Digite o termo da issue",
                                labelStyle: TextStyle(color: Colors.white),
                                border: OutlineInputBorder(),
                            ),
                            style: TextStyle(color: Colors.white, fontSize: 18),
                            onSubmitted: (value) {
                                setState(() {
                                    resultado = apiService.getIssuesAndPRs('${value.trim().isEmpty ? 'state:open' : value.trim()} is:issue', 1);
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
                                                        'Nenhuma issue encontrada.',
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
            children: items.map((issue) {
                String dados = "";
                dados += "Título: ${issue["title"] ?? ""}\n";
                dados += "Autor: ${issue["user"]?["login"] ?? ""}\n";
                dados += "Status: ${issue["state"] == "open" ? "Aberta" : "Fechada"}\n";
                dados += "Etiquetas: ${(issue["labels"] as List? ?? []).map((label) => label["name"]).join(", ")}\n";
                dados += "Link: ${issue["html_url"] ?? ""}\n\n";

                return Text(
                    dados,
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                );
            }).toList(),
        );
    }
}
