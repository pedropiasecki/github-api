import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/favorito_model.dart';

// users/{userId}/favoritos/{idDoRepositorio}
class FirestoreService {
    final FirebaseFirestore _db = FirebaseFirestore.instance;

    // timeout evita travar o app quando esta sem internet
    final Duration _limite = const Duration(seconds: 10);

    CollectionReference<Map<String, dynamic>> _colecao(String userId) {
        return _db.collection('users').doc(userId).collection('favoritos');
    }

    // ria o documento ou sobrescreve se já existir
    Future<void> salvar(Favorito favorito) async {
        await _colecao(favorito.userId)
            .doc(favorito.remoteId)
            .set(favorito.toFirestore())
            .timeout(_limite);
    }

    // DELETE
    Future<void> excluir(String userId, String remoteId) async {
        await _colecao(userId).doc(remoteId).delete().timeout(_limite);
    }

    // READ
    Future<List<Favorito>> listar(String userId) async {
        final resultado = await _colecao(userId).get().timeout(_limite);
        return resultado.docs
            .map((doc) => Favorito.fromFirestore(doc.data(), doc.id))
            .toList();
    }
}
