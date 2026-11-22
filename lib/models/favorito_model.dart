// representa um repositório favoritado do GitHub.
// é a mesma para local e nuvem
class Favorito {
    Favorito({
        this.id,
        required this.userId,
        required this.remoteId,
        required this.nome,
        this.descricao = '',
        this.linguagem = '',
        this.estrelas = 0,
        this.url = '',
        this.anotacao = '',
        required this.dataEvento,
        required this.criadoEm,
        required this.atualizadoEm,
        this.latitude,
        this.longitude,
        this.synced = false,
        this.deletedAt,
    });

    int? id; // id local sqlite
    String userId; // dono do favorito, é o uid do firebase auth
    String remoteId; // identificador na nuvem (= id do repositório no GitHub)
    String nome; // nome completo do repositório (dono/repositório)
    String descricao; // descrição do repositório no GitHub
    String linguagem;
    int estrelas;
    String url;
    String anotacao; // anotação do usuário sobre o repositório
    DateTime dataEvento; // data do salvamento
    DateTime criadoEm;
    DateTime atualizadoEm;
    double? latitude;
    double? longitude;
    bool synced; // true = já está na nuvem
    DateTime? deletedAt; // preenchido quando foi excluído e falta avisar a nuvem

    // dd/mm/aaaa
    static String formatarData(DateTime data) {
        final dia = data.day.toString().padLeft(2, '0');
        final mes = data.month.toString().padLeft(2, '0');
        return '$dia/$mes/${data.year}';
    }

    // cria um favorito a partir de um repositório retornado pela API do GitHub.
    // usar o id do repositório como remoteId impede favoritos duplicados.
    factory Favorito.fromGithub(
        Map<String, dynamic> repo,
        String userId,
    ) {
        final agora = DateTime.now();
        return Favorito(
            userId: userId,
            remoteId: repo['id'].toString(),
            nome: repo['full_name'] ?? repo['name'] ?? '',
            descricao: repo['description'] ?? '',
            linguagem: repo['language'] ?? '',
            estrelas: repo['stargazers_count'] ?? 0,
            url: repo['html_url'] ?? '',
            dataEvento: agora,
            criadoEm: agora,
            atualizadoEm: agora,
        );
    }

    // conversão para o formato do SQLite
    Map<String, dynamic> toMap() {
        return {
            if (id != null) 'id': id,
            'userId': userId,
            'remoteId': remoteId,
            'nome': nome,
            'descricao': descricao,
            'linguagem': linguagem,
            'estrelas': estrelas,
            'url': url,
            'anotacao': anotacao,
            'dataEvento': dataEvento.toIso8601String(),
            'criadoEm': criadoEm.toIso8601String(),
            'updatedAt': atualizadoEm.toIso8601String(),
            'latitude': latitude,
            'longitude': longitude,
            'synced': synced ? 1 : 0,
            'deletedAt': deletedAt?.toIso8601String(),
        };
    }

    // cria um favorito a partir de uma linha do SQLite
    factory Favorito.fromMap(Map<String, dynamic> map) {
        return Favorito(
            id: map['id'],
            userId: map['userId'],
            remoteId: map['remoteId'],
            nome: map['nome'],
            descricao: map['descricao'] ?? '',
            linguagem: map['linguagem'] ?? '',
            estrelas: map['estrelas'] ?? 0,
            url: map['url'] ?? '',
            anotacao: map['anotacao'] ?? '',
            dataEvento: DateTime.parse(map['dataEvento']),
            criadoEm: DateTime.parse(map['criadoEm']),
            atualizadoEm: DateTime.parse(map['updatedAt']),
            latitude: map['latitude'],
            longitude: map['longitude'],
            synced: map['synced'] == 1,
            deletedAt: map['deletedAt'] == null
                ? null
                : DateTime.parse(map['deletedAt']),
        );
    }

    // converao para o formato do Firestore
    Map<String, dynamic> toFirestore() {
        return {
            'id': remoteId,
            'userId': userId,
            'nome': nome,
            'descricao': descricao,
            'linguagem': linguagem,
            'estrelas': estrelas,
            'url': url,
            'anotacao': anotacao,
            'dataEvento': dataEvento.toIso8601String(),
            'criadoEm': criadoEm.toIso8601String(),
            'updatedAt': atualizadoEm.toIso8601String(),
            'latitude': latitude,
            'longitude': longitude,
            'synced': true,
        };
    }

    // cria um Favorito a partir de um documento do Firestore
    factory Favorito.fromFirestore(Map<String, dynamic> map, String docId) {
        return Favorito(
            userId: map['userId'],
            remoteId: docId,
            nome: map['nome'],
            descricao: map['descricao'] ?? '',
            linguagem: map['linguagem'] ?? '',
            estrelas: (map['estrelas'] as num?)?.toInt() ?? 0,
            url: map['url'] ?? '',
            anotacao: map['anotacao'] ?? '',
            dataEvento: DateTime.parse(map['dataEvento']),
            criadoEm: DateTime.parse(map['criadoEm']),
            atualizadoEm: DateTime.parse(map['updatedAt']),
            latitude: (map['latitude'] as num?)?.toDouble(),
            longitude: (map['longitude'] as num?)?.toDouble(),
            synced: true,
        );
    }
}
