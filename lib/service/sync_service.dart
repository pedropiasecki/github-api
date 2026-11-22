import 'package:connectivity_plus/connectivity_plus.dart';
import '../database/favorito_helper.dart';
import '../models/favorito_model.dart';
import 'firestore_service.dart';

class SyncService {
    final FavoritoHelper _helper = FavoritoHelper();
    final FirestoreService _firestore = FirestoreService();

    // verifica se o aparelho tem conexão
    Future<bool> temInternet() async {
        final resultado = await Connectivity().checkConnectivity();
        return !resultado.contains(ConnectivityResult.none);
    }

    // lista os favoritos na nuvem se houver internet + pendentes do SQLite
    Future<List<Favorito>> listarFavoritos(String userId) async {
        final Map<String, Favorito> mapa = {};

        if (await temInternet()) {
            try {
                for (final favorito in await _firestore.listar(userId)) {
                    mapa[favorito.remoteId] = favorito;
                }
            } catch (_) {
                // se a nuvem falhar, mostra só os favoritos locais
            }
        }

        for (final local in await _helper.listar(userId)) {
            if (local.deletedAt != null) {
                mapa.remove(local.remoteId); // foi removido e falta avisar a nuvem
            } else {
                mapa[local.remoteId] = local;
            }
        }

        final lista = mapa.values.toList();
        lista.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
        return lista;
    }

    Future<bool> salvarFavorito(Favorito favorito) async {
        favorito.synced = false;
        favorito.deletedAt = null;
        favorito.atualizadoEm = DateTime.now();
        await _gravarLocal(favorito);
        await sincronizar(favorito.userId);
        return (await _helper.buscarPorRemoteId(favorito.remoteId)) == null;
    }

    Future<void> excluirFavorito(Favorito favorito) async {
        favorito.synced = false;
        favorito.deletedAt = DateTime.now();
        await _gravarLocal(favorito);
        await sincronizar(favorito.userId);
    }

    Future<void> _gravarLocal(Favorito favorito) async {
        final existente = await _helper.buscarPorRemoteId(favorito.remoteId);
        if (existente == null) {
            await _helper.inserir(favorito);
        } else {
            favorito.id = existente.id;
            await _helper.atualizar(favorito);
        }
    }

    Future<int> sincronizar(String userId) async {
        if (!await temInternet()) return 0;

        int enviados = 0;
        final pendentes = await _helper.listarPendentes(userId);

        for (final favorito in pendentes) {
            try {
                if (favorito.deletedAt != null) {
                    await _firestore.excluir(userId, favorito.remoteId);
                    await _helper.excluir(favorito.id!);
                } else {
                    await _firestore.salvar(favorito);
                    await _helper.marcarSincronizado(favorito.id!);
                }
                enviados++;
            } catch (_) {
                // continua pendente para a próxima tentativa
            }
        }

        await _helper.limparSincronizados(userId);
        return enviados;
    }
}
