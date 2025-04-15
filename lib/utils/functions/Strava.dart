import 'dart:convert';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;

const String stravaClientId = '154433';
const String stravaClientSecret = '06b918cf460799328b862cfea4ace2876d201499';
const String stravaRedirectUri = 'https://groupgrit.io/auth/callback';
const String stravaScope = 'activity:read,activity:read_all';
const String accessToken = '0c77598f8d668a96f11296724cb40fc03b908f82';

Future<String> authenticateWithStrava() async {
  final url =
      'https://www.strava.com/oauth/authorize?client_id=$stravaClientId&response_type=code&redirect_uri=$stravaRedirectUri&approval_prompt=auto&scope=${Uri.encodeComponent(stravaScope)}';

  final result = await FlutterWebAuth2.authenticate(
    url: url,
    callbackUrlScheme: 'groupgrit',
  );

  final code = Uri.parse(result).queryParameters['code'];
  if (code == null) {
    throw Exception('Authorization code not found');
  }

  return code;
}

Future<Map<String, dynamic>> exchangeToken(String code) async {
  final response = await http.post(
    Uri.parse('https://www.strava.com/oauth/token'),
    body: {
      'client_id': stravaClientId,
      'client_secret': stravaClientSecret,
      'code': code,
      'grant_type': 'authorization_code',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to exchange token: ${response.body}');
  }

  return json.decode(response.body);
}

Future<List<dynamic>> fetchActivities(String accessToken) async {
  final response = await http.get(
    Uri.parse('https://www.strava.com/api/v3/athlete/activities'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to fetch activities: ${response.body}');
  }

  return json.decode(response.body);
}

Future<void> connectToStrava() async {
  try {
    final code = await authenticateWithStrava();
    final tokenData = await exchangeToken(code);
    final activities = await fetchActivities(tokenData['access_token']);

    print('User activities: $activities');
  } catch (e) {
    print('Error connecting to Strava: $e');
  }
}

Future<bool> isUserAuthenticated() async {
  final response = await http.get(
    Uri.parse('https://www.strava.com/api/v3/athlete'),
    headers: {
      'Authorization': 'Bearer 0c77598f8d668a96f11296724cb40fc03b908f82',
    },
  );

  if (response.statusCode == 200) {
    print(json.decode(response.body));
    return true; // L'utente è autenticato
  } else {
    print('Authentication check failed: ${response.body}');
    return false; // L'utente non è autenticato
  }
}

Future<void> disconnectFromStrava() async {
  try {
    final response = await http.post(
      Uri.parse('https://www.strava.com/oauth/deauthorize'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      print('Successfully disconnected from Strava');
    } else {
      throw Exception('Failed to disconnect from Strava: ${response.body}');
    }
  } catch (e) {
    print('Error disconnecting from Strava: $e');
  }
}