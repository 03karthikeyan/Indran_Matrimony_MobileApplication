class Profile {
  final int userId;
  final String name;
  final int age;
  final String profileImg;

  Profile({
    required this.userId,
    required this.name,
    required this.age,
    required this.profileImg,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      userId: int.parse(json['user_id'].toString()),
      name: json['name'] ?? '',
      age: int.tryParse(json['age'].toString()) ?? 0,
      profileImg: json['profile_img'] ?? '',
    );
  }
}
