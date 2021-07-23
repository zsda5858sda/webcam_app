final String tableUser = 'users';

class UserFields {
  static final List<String> values = [
    /// Add all fields
    id, phone, webviewUrl
  ];

  static final String id = '_id';
  static final String phone = 'phone';
  static final String webviewUrl = 'webviewUrl';
}

class User {
  final String id;
  final String phone;
  final String webviewUrl;
  const User({required this.id, required this.phone, required this.webviewUrl});

  User copy({String? id, String? phone, String? webviewUrl}) => User(
        id: id ?? this.id,
        phone: phone ?? this.phone,
        webviewUrl: webviewUrl ?? this.webviewUrl,
      );

  static User fromJson(Map<String, dynamic> json) => User(
        id: json[UserFields.id] as String,
        phone: json[UserFields.phone] as String,
        webviewUrl: json[UserFields.webviewUrl] as String,
      );

  Map<String, Object> toJson() => {
        UserFields.id: id,
        UserFields.phone: phone,
        UserFields.webviewUrl: webviewUrl
      };
}
