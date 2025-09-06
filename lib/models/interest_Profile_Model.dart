class InterestedProfile {
  final int interestId;
  final String name;
  final int age;
  final String city;
  final String state;
  final String higherEducation;
  final String occupation;
  final String createdAt;
  final String profileImg;

  InterestedProfile({
    required this.interestId,
    required this.name,
    required this.age,
    required this.city,
    required this.state,
    required this.higherEducation,
    required this.occupation,
    required this.createdAt,
    required this.profileImg,
  });

  factory InterestedProfile.fromJson(Map<String, dynamic> json) {
    return InterestedProfile(
      interestId: int.parse(json['interest_id'].toString()),
      name: json['name'] ?? '',
      age: int.tryParse(json['age'].toString()) ?? 0,
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      higherEducation: json['higher_education'] ?? '',
      occupation: json['occupation'] ?? '',
      createdAt: json['created_at'] ?? '',
      profileImg: json['profile_img'] ?? '',
    );
  }
}
