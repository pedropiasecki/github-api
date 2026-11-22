import '../models/favorito_model.dart';
import 'local_database.dart';

// CRUD da tabela favoritos no SQLite.
// todas as consultas filtram pelo userId
class FavoritoHelper {
    // CREATE
    Future<void> inserir(Favorito favorito) async {
        final db = await LocalDatabase.instance.database;
        await db.insert('favoritos', favorito.toMap());
    }

    // READ: todos os favoritos locais do usuário
    Future<List<Favorito>> listar(String userId) async {
        final db = await LocalDatabase.instance.database;
        final linhas = await db.query(
            'favoritos',
            where: 'userId = ?',
            whereArgs: [userId],
        );
        return linhas.map((linha) => Favorito.fromMap(linha)).toList();
    }

    // READ: favoritos que ainda não foram enviados para a nuvem
    Future<List<Favorito>> listarPendentes(String userId) async {
        final db = await LocalDatabase.instance.database;
        final linhas = await db.query(
            'favoritos',
            where: 'userId = ? AND synced = 0',
            whereArgs: [userId],
        );
        return linhas.map((linha) => Favorito.fromMap(linha)).toList();
    }

    // READ: procura um favorito pelo id da nuvem
    Future<Favorito?> buscarPorRemoteId(String remoteId) async {
        final db = await LocalDatabase.instance.database;
        final linhas = await db.query(
            'favoritos',
            where: 'remoteId = ?',
            whereArgs: [remoteId],
        );
        if (linhas.isEmpty) return null;
        return Favorito.fromMap(linhas.first);
    }

    // UPDATE
    Future<void> atualizar(Favorito favorito) async {
        final db = await LocalDatabase.instance.database;
        await db.update(
            'favoritos',
            favorito.toMap(),
            where: 'id = ?',
            whereArgs: [favorito.id],
        );
    }

    // UPDATE: marca como sincronizado
    Future<void> marcarSincronizado(int id) async {
        final db = await LocalDatabase.instance.database;
        await db.update(
            'favoritos',
            {'synced': 1},
            where: 'id = ?',
            whereArgs: [id],
        );
    }

    // DELETE: remove uma linha do banco local
    Future<void> excluir(int id) async {
        final db = await LocalDatabase.instance.database;
        await db.delete('favoritos', where: 'id = ?', whereArgs: [id]);
    }

    // DELETE: limpa do banco local o que já foi sincronizado
    Future<void> limparSincronizados(String userId) async {
        final db = await LocalDatabase.instance.database;
        await db.delete(
            'favoritos',
            where: 'userId = ? AND synced = 1',
            whereArgs: [userId],
        );
    }
}
