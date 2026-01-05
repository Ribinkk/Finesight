class UserModel {
  final String name;
  final String email;
  final String? pictureUrl;

  UserModel({
    required this.name,
    required this.email,
    this.pictureUrl,
  });
}
