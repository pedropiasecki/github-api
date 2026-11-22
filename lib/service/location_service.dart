import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationService {
    // consulta a cidade e o país usando a posição atual do aparelho.
    Future<Map<String, String>> obterLocalizacao() async {
        final posicao = await obterPosicao().timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception(
                'Não foi possível obter a localização. Tente novamente.'),
        );
        final url = Uri.https('api.bigdatacloud.net', '/data/reverse-geocode-client', {
            'latitude': posicao.latitude.toString(),
            'longitude': posicao.longitude.toString(),
            'localityLanguage': 'pt',
        });

        final Map<String, dynamic> dados;
        try {
            final resposta = await http.get(url).timeout(const Duration(seconds: 15));
            if (resposta.statusCode != 200) {
                throw Exception('Erro ao consultar a localização.');
            }
            dados = json.decode(utf8.decode(resposta.bodyBytes));
        } catch (_) {
            throw Exception(
                'Não foi possível buscar a localização. Verifique sua conexão e tente novamente.');
        }

        final cidade = (dados['city'] as String?)?.trim() ?? '';
        final pais = (dados['countryName'] as String?)?.trim() ?? '';
        if (cidade.isEmpty && pais.isEmpty) {
            throw Exception('Não foi possível identificar sua cidade ou país.');
        }
        return {'city': cidade, 'country': pais};
    }

    Future<bool> permissaoConcedida() async {
        final permissao = await Geolocator.checkPermission();
        return permissao == LocationPermission.always ||
            permissao == LocationPermission.whileInUse;
    }

    Future<Position> obterPosicao() async {
        if (!await Geolocator.isLocationServiceEnabled()) {
            throw Exception('O GPS está desligado. Ative a localização.');
        }

        var permissao = await Geolocator.checkPermission();
        if (permissao == LocationPermission.denied) {
            permissao = await Geolocator.requestPermission();
        }
        if (permissao == LocationPermission.denied) {
            throw Exception('Permissão de localização negada.');
        }
        if (permissao == LocationPermission.deniedForever) {
            throw Exception(
                'Permissão bloqueada. Libere a localização nas configurações do aparelho.');
        }

        return Geolocator.getCurrentPosition();
    }
}
