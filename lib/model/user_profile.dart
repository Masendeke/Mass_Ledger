class UserProfile {
  final String name;
  final String email;
  final String currency;

  const UserProfile({
    required this.name,
    required this.email,
    required this.currency,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? currency,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      currency: currency ?? this.currency,
    );
  }
}