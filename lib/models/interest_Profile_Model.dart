class InterestedProfile {
  final String profileId; // interest sender (the other person)
  final String userId; // logged-in user (receiverId)
  final int interestId; // interest row id
  final String status; // pending / accepted / declined
  final String name;
  final int age;
  final String profileImg;
  final String time;
  final String city;
  final List<String> tags;

  InterestedProfile({
    required this.profileId,
    required this.userId,
    required this.interestId,
    required this.status,
    required this.name,
    required this.age,
    required this.time,
    required this.city,
    required this.tags,
    required this.profileImg,
  });

  factory InterestedProfile.fromJson(
    Map<String, dynamic> json, {
    required String loggedInUserId,
  }) {
    print("📥 Parsing InterestedProfile: $json");

    // Logged-in user always
    String userId = loggedInUserId;

    // Try to get other person's id safely
    String profileId = json['user_id']?.toString() ?? "";

    if (profileId == loggedInUserId) {
      // 👀 API gave same id as logged in user
      // Try alternate field
      profileId = json['profile_id']?.toString() ?? "";
    }

    return InterestedProfile(
      profileId: profileId,
      userId: userId,
      interestId: int.tryParse(json['interest_id'].toString()) ?? 0,
      name: json['name'] ?? '',
      age: int.tryParse(json['age'].toString()) ?? 0,
      city: "${json['city'] ?? ''}, ${json['state'] ?? ''}",
      profileImg: json['profile_img'] ?? '',
      time: json['created_at'] ?? '',
      status: (json['status'] ?? 'pending').toString().toLowerCase(),
      tags: [json['higher_education'] ?? '', json['occupation'] ?? ''],
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'profile_id': profileId,
      'user_id': userId,
      'interest_id': interestId,
      'name': name,
      'age': age,
      'city': city,
      'profile_img': profileImg,
      'created_at': time,
      'status': status,
      'tags': tags,
    };

    // ✅ Debug log outgoing JSON
    print("📤 Serializing InterestedProfile: $map");

    return map;
  }
}
