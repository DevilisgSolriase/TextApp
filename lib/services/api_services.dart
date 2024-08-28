import 'dart:convert';

import 'package:app/models/user_models.dart';
import 'package:http/http.dart' as http;


Future<List<Friends>> fetchFriends(int userId) async {
  final response = await http.get(Uri.parse('http://10.0.2.2:8000/friends/?id=$userId'));
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((item) => Friends.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load friends');
  }
}


Future<List<Friends>> search(String search) async {
  final url = Uri.parse('http://10.0.2.2:8000/search?username=$search');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    print('Fetched friends: $data');
    return data.map((item) => Friends.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load friends');
  }
}


void addFriend(String username, int userId) async {
  try {
    print(username);
    final url = Uri.parse('http://10.0.2.2:8000/add_user'); // Ensure this is the correct endpoint
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'user_id': userId}),
    );

    if (response.statusCode == 200) {
      // Handle successful addition
      print('User added successfully');
    } else {
      // Handle error
      print('Failed to add user: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

