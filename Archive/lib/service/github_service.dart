import 'package:http/http.dart' as http;
import 'dart:convert';

class GithubService {
    final String _baseUrl = "https://api.github.com";

    final Map<String, String> _headers = {
        'Accept': 'application/vnd.github.v3+json',
    };

    Future<Map<String, dynamic>> getRepositories(String search, int page) async {
        final query = search.isEmpty ? 'stars:>1' : search;
        final url = Uri.parse("$_baseUrl/search/repositories").replace(
            queryParameters: {
                'q': query,
                'sort': 'stars',
                'order': 'desc',
                'per_page': '20',
                'page': '$page',
            },
        );

        final response = await http.get(url, headers: _headers);
        if (response.statusCode != 200) {
            throw Exception('Erro ao buscar os dados do GitHub.');
        }
        return json.decode(response.body);
    }

    Future<Map<String, dynamic>> getUsers(String search, int page) async {
        final query = search.isEmpty ? 'followers:>1000' : search;
        final url = Uri.parse("$_baseUrl/search/users").replace(
            queryParameters: {
                'q': query,
                'per_page': '20',
                'page': '$page',
            },
        );

        final response = await http.get(url, headers: _headers);
        if (response.statusCode != 200) {
            throw Exception('Erro ao buscar os dados do GitHub.');
        }
        return json.decode(response.body);
    }

    Future<Map<String, dynamic>> getIssuesAndPRs(String search, int page) async {
        final query = search.isEmpty ? 'state:open' : search;
        final url = Uri.parse("$_baseUrl/search/issues").replace(
            queryParameters: {
                'q': query,
                'sort': 'created',
                'order': 'desc',
                'per_page': '20',
                'page': '$page',
            },
        );

        final response = await http.get(url, headers: _headers);
        if (response.statusCode != 200) {
            throw Exception('Erro ao buscar os dados do GitHub.');
        }
        return json.decode(response.body);
    }
}
