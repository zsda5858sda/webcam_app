final String tableClerk = 'clerk';

class ClerkFields {
  static final List<String> values = [
    /// Add all fields
    id, account, password
  ];

  static final String id = '_id';
  static final String account = 'account';
  static final String password = 'password';
}

class Clerk {
  final int? id;
  final String account;
  final String password;

  const Clerk({
    this.id,
    required this.account,
    required this.password,
  });

  Clerk copy({
    int? id,
    String? account,
    String? password,
  }) =>
      Clerk(
        id: id ?? this.id,
        account: account ?? this.account,
        password: password ?? this.password,
      );

  static Clerk fromJson(Map<String, Object?> json) => Clerk(
        id: json[ClerkFields.id] as int?,
        account: json[ClerkFields.account] as String,
        password: json[ClerkFields.password] as String,
      );

  Map<String, Object?> toJson() => {
        ClerkFields.id: id,
        ClerkFields.account: account,
        ClerkFields.password: password,
      };
}
