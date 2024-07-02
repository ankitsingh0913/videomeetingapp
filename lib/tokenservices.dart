import 'package:http/http.dart' as http;
import 'dart:convert';

class TokenService {
  static Future<String> getToken() async {
    final response = await http.post(
      Uri.parse('https://api.videosdk.live/v2/rooms'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'e42c6584-5a36-4399-9d26-88b2a1fd67cf',
      },
      body: json.encode({
        'permissions': ['allow_join'],
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data['token']);
      return data['token'];
    } else {
      print('Error: ${response.statusCode} ${response.reasonPhrase}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load token');
    }
  }
}


//e42c6584-5a36-4399-9d26-88b2a1fd67cf
