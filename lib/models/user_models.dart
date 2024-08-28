class user {
  final String username;
  final String? email;

  user({required this.username, required this.email});

  factory user.fromJson(Map<String, dynamic> json) {
    return user(username: json['username'], email: json['email']);
  }
}

class Friends {
  final String? username;

  Friends({this.username});

  factory Friends.fromJson(Map<String, dynamic> json) {
    return Friends(
      username: json['username'],
    );
  }
}

class Add {
  final String username;
  final String email;

  Add({required this.username, required this.email});

  factory Add.fromJson(Map<String, dynamic> json) {
    return Add(username: json['username'], email: json['email']);
  }
}
