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

    // Step 1: Identify sender and receiver IDs
    String senderId =
        json['profile_id']?.toString() ??
        json['sender_id']?.toString() ??
        json['from_user_id']?.toString() ??
        "";
    String receiverId = json['user_id']?.toString() ?? "";

    // Step 2: Determine which is the logged-in user
    String profileId = senderId; // other person
    String userId = receiverId; // logged-in user

    if (senderId == loggedInUserId) {
      // sender is the logged-in user → swap
      profileId = receiverId; // other person
      userId = loggedInUserId; // logged-in user
    }

    // Step 3: Fallbacks
    if (profileId.isEmpty) profileId = loggedInUserId;

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
