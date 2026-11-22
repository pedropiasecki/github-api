import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// abre o banco SQLite e cria as tabelas
class LocalDatabase {
    static final LocalDatabase instance = LocalDatabase._();
    LocalDatabase._();

    Database? _db;

    Future<Database> get database async {
        _db ??= await _abrirBanco();
        return _db!;
    }

    Future<Database> _abrirBanco() async {
        final caminho = join(await getDatabasesPath(), 'favoritos.db');
        return openDatabase(
            caminho,
            version: 1,
            onCreate: (db, versao) async {
                await db.execute('''
                    CREATE TABLE favoritos (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        userId TEXT NOT NULL,
                        remoteId TEXT NOT NULL UNIQUE,
                        nome TEXT NOT NULL,
                        descricao TEXT,
                        linguagem TEXT,
                        estrelas INTEGER,
                        url TEXT,
                        anotacao TEXT,
                        dataEvento TEXT NOT NULL,
                        criadoEm TEXT NOT NULL,
                        updatedAt TEXT NOT NULL,
                        latitude REAL,
                        longitude REAL,
                        synced INTEGER NOT NULL DEFAULT 0,
                        deletedAt TEXT
                    )
                ''');
            },
        );
    }
}
