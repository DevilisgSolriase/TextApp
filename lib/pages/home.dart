import 'package:app/pages/chat.dart';
import 'package:app/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/models/user_models.dart';

import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

final GlobalKey<FormState> _formGlobalKey = GlobalKey<FormState>();

class _HomePageState extends State<HomePage> {
  //Variables
  late int userId;
  List<Friends> friends = [];
  bool _isMenuVisible = false;
  late Widget _currentWidget;

  @override
  void initState() {
    super.initState();
    
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set up userId from route arguments
    final args = ModalRoute.of(context)?.settings.arguments as int?;
    if (args != null) {
      userId = args;
      _currentWidget = HomeWidget(fetchFriends: fetchFriends(userId), userId: userId);
    } else {
      // Provide a default widget to avoid LateInitializationError
      _currentWidget = Center(child: Text('No user ID provided'));
    }
  }
  //General fucntions for the page

  Future<String?> getStoredEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail');
  }

  void _logout() async {
    final email = await getStoredEmail();

    final url = Uri.parse('http://10.0.2.2:8000/logout');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      Navigator.pushNamed(context, '');
    } else {
      throw Exception('Failed to log out');
    }
  }

  //widget related functions

  void _toggleMenu() {
    setState(() {
      _isMenuVisible = !_isMenuVisible;
    });
  }

  void _changeWidget(Widget newWidget) {
    setState(() {
      _currentWidget = newWidget;
    });
  }

  void _closeMenu() {
    if (_isMenuVisible) {
      setState(() {
        _isMenuVisible = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: Colors.blue[200],
        title: Text("Home", textAlign: TextAlign.center),
        centerTitle: true,
        leading: GestureDetector(
          onTap: _toggleMenu,
          child: Container(
            child: SvgPicture.asset(
              "assets/svg/menu-svgrepo-com.svg",
              fit: BoxFit.contain,
            ),
          ),
        ),
        actions: [
          FilledButton(
            child: SvgPicture.asset(
              "assets/svg/logout-svgrepo-com.svg",
            ),
            onPressed: () => _logout(),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.transparent,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content with proper constraints
          Positioned.fill(
            child: SingleChildScrollView(
              child: _currentWidget, // Display the current widget
            ),
          ),
          // Bottom toolbar
          _toolBar(context),
          // Sliding menu
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            curve: Curves.linear,
            left: _isMenuVisible ? 0 : -250, // Adjust the offset here
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: _closeMenu, // Close menu on tap
              child: Container(
                width: 250, // Set the width of the sliding menu
                color: Colors.blue[200],
                child: Column(
                  children: [
                    ListTile(
                      title: Text('Menu Item 1',
                          style: TextStyle(color: Colors.white)),
                    ),
                    ListTile(
                      title: Text('Menu Item 2',
                          style: TextStyle(color: Colors.white)),
                    ),
                    ListTile(
                      title: Text('Menu Item 3',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Align _toolBar(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white, // Background color of the toolbar
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(0.3), // Shadow color with opacity
                  offset: Offset(0, -4), // Horizontal and vertical offset
                  blurRadius: 4, // Blur radius
                  spreadRadius: 2, // Spread radius
                ),
              ],
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  child: Container(
                    height: 30,
                    width: 85,
                    child: SvgPicture.asset("assets/svg/home-svgrepo-com.svg"),
                  ),
                  onTap: () =>
                      _changeWidget(HomeWidget(fetchFriends: fetchFriends(userId), userId: userId,)),
                ),
                GestureDetector(
                  child: Container(
                    height: 30,
                    width: 85,
                    child: SvgPicture.asset(
                        "assets/svg/search-alt-2-svgrepo-com.svg"),
                  ),
                  onTap: () => _changeWidget(SearchWidget()),
                ),
                SizedBox(
                  width: 71.4,
                ),
                GestureDetector(
                  child: Container(
                    height: 30,
                    width: 85,
                    child: SvgPicture.asset(
                        "assets/svg/notification-unread-svgrepo-com.svg"),
                  ),
                  onTap: () => _changeWidget(NotificationWidget()),
                ),
                GestureDetector(
                  child: Container(
                    height: 30,
                    width: 85,
                    child:
                        SvgPicture.asset("assets/svg/settings-svgrepo-com.svg"),
                  ),
                  onTap: () => _changeWidget(SettingsWidget()),
                ),
              ],
            ),
          ),
          Positioned(
            child: SizedBox(
              height: 80,
              width: 80,
              child: FilledButton(
                onPressed: () => _changeWidget(Addwidget(id:userId)),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.blue[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Container(
                  child: SvgPicture.asset('assets/svg/plus-svgrepo-com.svg'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeWidget extends StatelessWidget {
  final Future<List<Friends>> fetchFriends;
  final int userId;

  HomeWidget({required this.fetchFriends, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<List<Friends>>(
        future: fetchFriends,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Text('No friends found');
          } else {
            List<Friends> friends = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final friend = friends[index];
                return ListTile(
                  title: Text(friend.username!),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => chatPage(
                          chatTitle: friend.username!,
                          userId: userId,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}


class SearchWidget extends StatefulWidget {
  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  Future<List<Friends>>? _searchResults;
  bool _hasSearched = false;

  void _performSearch() {
    setState(() {
      _searchResults = search(_searchController.text);
      _hasSearched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: "Search",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                _performSearch();
              } else {
                setState(() {
                  _hasSearched = false;
                  _searchResults = null;
                });
              }
            },
          ),
        ),
        if (_hasSearched) ...[
          FutureBuilder<List<Friends>>(
            future: _searchResults,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('No friends found');
              } else {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final friend = snapshot.data![index];
                    return ListTile(
                      title: Text(friend.username!),
                    );
                  },
                );
              }
            },
          ),
        ],
      ],
    );
  }
}


class NotificationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Notifications Screen'));
  }
}

class SettingsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Settings Screen'));
  }
}


class Add extends StatelessWidget {
  final String username;
  final String email;

  Add({required this.username, required this.email});

  factory Add.fromJson(Map<String, dynamic> json) {
    return Add(
      username: json['username'],
      email: json['email'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(username),
      subtitle: Text(email),
    );
  }
}

// ignore: must_be_immutable
class Addwidget extends StatefulWidget {

  int id;

  Addwidget({required this.id});

  @override
  _AddwidgetState createState() => _AddwidgetState(UserId: id);
}

class _AddwidgetState extends State<Addwidget> {
  final int UserId;
  String? username;

  _AddwidgetState({required this.UserId});

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  Future<List<Add>>? _searchResults;
  bool _hasSearched = false;

  Future<List<Add>> add(String username, String email) async {
    final url = Uri.parse('http://10.0.2.2:8000/add?username=$username&email=$email');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Add.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load friends');
    }
  }

  void _userSearch() {
    setState(() {
      _searchResults = add(_usernameController.text, _emailController.text);
      _hasSearched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              "Add a Friend",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),onChanged: (value) {
              if (value.isNotEmpty) {
                _userSearch();
              } else {
                setState(() {
                  _hasSearched = false;
                  _searchResults = null;
                });
              }
            },
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "E-mail",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 50,
              width: 90,
              decoration: BoxDecoration(
                color: Colors.blue[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: FilledButton(
                onPressed: _userSearch,
                child: Text("Add"),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
            SizedBox(height: 20),
              GestureDetector(
                child: FutureBuilder<List<Add>>(
                  future: _searchResults,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No results found'));
                    } else {
                      List<Add> results = snapshot.data!;
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final addItem = results[index];
                            return ListTile(
                              title: Text(addItem.username),
                              onTap: () {
                          addFriend(addItem.username, UserId);
                          },
                        );
                      },
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
