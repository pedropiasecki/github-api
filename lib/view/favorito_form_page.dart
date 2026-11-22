import 'package:flutter/material.dart';
import '../components/my_texfield.dart';
import '../models/favorito_model.dart';
import '../service/sync_service.dart';

class FavoritoFormPage extends StatefulWidget {
    const FavoritoFormPage({super.key, required this.favorito, this.novo = false});

    final Favorito favorito;
    final bool novo;

    @override
    State<FavoritoFormPage> createState() => _FavoritoFormPageState();
}

class _FavoritoFormPageState extends State<FavoritoFormPage> {
    final anotacaoController = TextEditingController();

    bool salvando = false;

    @override
    void initState() {
        super.initState();
        // Preenche os campos com os dados atuais do favorito
        final favorito = widget.favorito;
        anotacaoController.text = favorito.anotacao;
    }

    @override
    void dispose() {
        anotacaoController.dispose();
        super.dispose();
    }

    void aviso(String mensagem) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(mensagem)),
        );
    }

    Future<void> salvar() async {
        final anotacao = anotacaoController.text.trim();
        if (anotacao.isEmpty) {
            aviso('Escreva uma anotação sobre o repositório.');
            return;
        }

        setState(() => salvando = true);

        final favorito = widget.favorito;
        favorito.anotacao = anotacao;
        if (widget.novo) {
            final agora = DateTime.now();
            favorito.dataEvento = agora;
            favorito.criadoEm = agora;
        }

        try {
            final enviado = await SyncService().salvarFavorito(favorito);
            if (!mounted) return;
            aviso(enviado
                ? 'Salvo e enviado ao Firebase.'
                : 'Salvo no aparelho. Será enviado quando houver internet.');
            Navigator.pop(context, true);
        } catch (_) {
            if (!mounted) return;
            setState(() => salvando = false);
            aviso('Erro ao salvar o favorito.');
        }
    }

    Widget linha(Widget filho) {
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: SizedBox(width: double.infinity, child: filho),
        );
    }

    @override
    Widget build(BuildContext context) {
        final favorito = widget.favorito;
        return Scaffold(
            appBar: AppBar(
                title: Text(widget.novo ? 'Favoritar repositório' : 'Editar favorito'),
            ),
            body: SafeArea(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                        children: [
                            linha(Text(
                                favorito.nome,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                ),
                            )),
                            if (favorito.descricao.isNotEmpty)
                                Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: linha(Text(favorito.descricao)),
                                ),
                            const SizedBox(height: 20),
                            MyTextField(
                                controller: anotacaoController,
                                hintText: 'Anotação',
                                icon: Icons.edit_note,
                                maxLines: 3,
                                keyboardType: TextInputType.multiline,
                                textCapitalization: TextCapitalization.sentences,
                            ),
                            const SizedBox(height: 25),
                            linha(Row(
                                children: [
                                    Expanded(
                                        child: OutlinedButton(
                                            onPressed: salvando
                                                ? null
                                                : () => Navigator.pop(context),
                                            child: const Text('Cancelar'),
                                        ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                        child: FilledButton(
                                            onPressed: salvando ? null : salvar,
                                            child: const Text('Salvar'),
                                        ),
                                    ),
                                ],
                            )),
                        ],
                    ),
                ),
            ),
        );
    }
}
