import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final TextEditingController _email = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  final GlobalKey<FormState> _formGlobalKey = GlobalKey<FormState>();

  Future<void> _register(BuildContext context) async {
    if (_formGlobalKey.currentState!.validate()) {
      final email = _email.text;
      final username = _username.text;
      final password = _password.text;
      final confirmPassword = _confirmPassword.text;

      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }

      final url = Uri.parse('http://10.0.2.2:8000/register');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // Handle successful registration
        print('Registration successful: $responseData');
        Navigator.pushNamed(context, '/login');
      } else {
        // Handle registration error
        print('Registration failed: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: Colors.blue[200],
        title: Text("Register", textAlign: TextAlign.center),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Container(
              height: 570,
              width: 300,
              decoration: BoxDecoration(
                color: Colors.blue[200]?.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Form(
                key: _formGlobalKey,
                child: Column(
                  children: [
                    _title(),
                    SizedBox(height: 25),
                    _emailField(),
                    SizedBox(height: 25),
                    _usernameField(),
                    SizedBox(height: 25),
                    _passwordField(),
                    SizedBox(height: 25),
                    _passwordConfirmField(),
                    SizedBox(height: 15),
                    _divider(),
                    SizedBox(height: 15),
                    _buttonsField(context),
                  ],
                ),
              ),
            ),
          ),
        ),
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
      child: Container(
        width: 200,
        child: Text(
          "Registration",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Padding _passwordField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 250,
        child: TextFormField(
          controller: _password,
          obscureText: true,
          decoration: InputDecoration(
            labelText: "Password",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            return null;
          },
        ),
      ),
    );
  }

  Padding _passwordConfirmField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 250,
        child: TextFormField(
          controller: _confirmPassword,
          obscureText: true,
          decoration: InputDecoration(
            labelText: "Confirm Password",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _password.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ),
    );
  }

  Padding _emailField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 250,
        child: TextFormField(
          controller: _email,
          decoration: InputDecoration(
            labelText: "E-Mail",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
            if (!regex.hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
      ),
    );
  }

  Padding _usernameField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 250,
        child: TextFormField(
          controller: _username,
          decoration: InputDecoration(
            labelText: "Username",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your username';
            }
            return null;
          },
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
          Expanded(
            child: ElevatedButton(
              onPressed: () => _register(context),
              child: Text("Done"),
            ),
          ),
        ],
      ),
    );
  }
}
