final String tableUser = 'users';

class UserFields {
  static final List<String> values = [
    /// Add all fields
    id, phone
  ];

  static final String id = '_id';
  static final String phone = 'phone';
}

class User {
  final String id;
  final String phone;

  const User({
    required this.id,
    required this.phone,
  });

  User copy({
    String? id,
    String? phone,
  }) =>
      User(
        id: id ?? this.id,
        phone: phone ?? this.phone,
      );

  static User fromJson(Map<String, dynamic> json) => User(
        id: json[UserFields.id] as String,
        phone: json[UserFields.phone] as String,
      );

  Map<String, Object> toJson() => {
        UserFields.id: id,
        UserFields.phone: phone,
      };
}
