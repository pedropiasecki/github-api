import 'package:flutter/material.dart';
import '../models/favorito_model.dart';
import '../service/sync_service.dart';
import 'favorito_form_page.dart';

class DetailsPage extends StatelessWidget {
    const DetailsPage({super.key, required this.favorito});

    final Favorito favorito;

    Future<void> editar(BuildContext context) async {
        final salvou = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
                builder: (_) => FavoritoFormPage(favorito: favorito),
            ),
        );
        if (salvou == true && context.mounted) Navigator.pop(context, true);
    }

    Future<void> excluir(BuildContext context) async {
        final confirmou = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
                title: const Text('Remover favorito'),
                content: Text('Deseja remover "${favorito.nome}" dos favoritos?'),
                actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('Cancelar'),
                    ),
                    FilledButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: const Text('Remover'),
                    ),
                ],
            ),
        );
        if (confirmou != true) return;

        try {
            await SyncService().excluirFavorito(favorito);
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Favorito removido.')),
            );
            Navigator.pop(context, true);
        } catch (_) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Erro ao remover o favorito.')),
            );
        }
    }

    Widget campo(String rotulo, String valor) {
        return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(rotulo, style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 4),
                    SelectableText(valor, style: const TextStyle(fontSize: 18)),
                ],
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text('Detalhes'),
                actions: [
                    IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Editar',
                        onPressed: () => editar(context),
                    ),
                    IconButton(
                        icon: const Icon(Icons.delete),
                        tooltip: 'Remover',
                        onPressed: () => excluir(context),
                    ),
                ],
            ),
            body: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        campo('Repositório', favorito.nome),
                        campo(
                            'Descrição',
                            favorito.descricao.isEmpty
                                ? 'Sem descrição'
                                : favorito.descricao,
                        ),
                        campo(
                            'Linguagem',
                            favorito.linguagem.isEmpty ? 'Não informada' : favorito.linguagem,
                        ),
                        campo('Estrelas', '${favorito.estrelas}'),
                        campo('Link', favorito.url),
                        campo('Anotação', favorito.anotacao),
                        campo('Favoritado em', Favorito.formatarData(favorito.criadoEm)),
                        campo(
                            'Situação',
                            favorito.synced
                                ? 'Sincronizado com o Firebase'
                                : 'Pendente de envio (salvo no aparelho)',
                        ),
                    ],
                ),
            ),
        );
    }
}
