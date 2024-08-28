import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatelessWidget {
  MainPage({super.key});

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formGlobalKey = GlobalKey<FormState>();

  Future<void> storeEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userEmail', email);
  }

  Future<void> _login(BuildContext context) async {
    if (_formGlobalKey.currentState!.validate()) {
      final email = _emailController.text;
      final password = _passwordController.text;

      final url = Uri.parse('http://10.0.2.2:8000/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['access_token'];
        final tokenType = data['token_type'];
        final userId = data['id'];

        print('Access Token: $accessToken');
        print('Token Type: $tokenType');
        print('User ID: $userId');

        Navigator.pushNamed(context, '/home', arguments: userId);
      } else {
        print('Login failed: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        toolbarHeight: 50,
        backgroundColor: Colors.blue[200],
        title: Text("Login", textAlign: TextAlign.center),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Container(
            height: 450,
            width: 300,
            decoration: BoxDecoration(
              color: Colors.blue[200]?.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Form(
              key: _formGlobalKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _title(),
                  SizedBox(height: 20),
                  _emailField(),
                  SizedBox(height: 20),
                  _passwordField(),
                  SizedBox(height: 20),
                  _divider(),
                  SizedBox(height: 20),
                  _buttonsField(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding _buttonsField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () => _login(context),
            child: Text("Login"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/registration');
            },
            child: Text("Register"),
          ),
        ],
      ),
    );
  }

  Container _divider() {
    return Container(
      width: 250,
      margin: EdgeInsets.all(8.0),
      child: Divider(
        color: Colors.black.withOpacity(0.3),
        height: 5,
      ),
    );
  }

  Padding _title() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        "Welcome to Text App",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
    );
  }

  Padding _passwordField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: _passwordController,
        obscureText: true,
        decoration: InputDecoration(
          labelText: "Password",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter your password";
          }
          return null;
        },
      ),
    );
  }

  Padding _emailField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: "E-Mail",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter your email";
          }
          final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
          if (!regex.hasMatch(value)) {
            return "Please enter a valid email";
          }
          storeEmail(value);
          return null;
        },
      ),
    );
  }
}
