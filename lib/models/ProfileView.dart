class ProfileView {
  final String id;
  final String name;
  final String? gender;
  final String? city;
  final String? state;
  final String? occupation;
  final String? image;
  final String? profileId;
  final String? userId;
  final String? lastViewedAt;
  final int? totalViews;

  ProfileView({
    required this.id,
    required this.name,
    this.gender,
    this.city,
    this.state,
    this.occupation,
    this.image,
    this.lastViewedAt,
    this.profileId,
    this.totalViews,
    this.userId,
  });

  factory ProfileView.fromJson(Map<String, dynamic> json) {
    return ProfileView(
      id: json['profile_id']?.toString() ?? '',
      name: json['name'] ?? '',
      gender: json['gender'],
      city: json['city'],
      state: json['state'],
      occupation: json['occupation'],
      image: json['profile_img'] ?? '',
      profileId: json['profile_id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      lastViewedAt: json['last_viewed_at'] ?? '',
      totalViews: int.tryParse(json['total_views'].toString()) ?? 0,
    );
  }

  /// 🔹 Add this to fix your error
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'city': city,
      'state': state,
      'occupation': occupation,
      'profile_img': image,
      'profile_id': profileId,
      'user_id': userId,
      'last_viewed_at': lastViewedAt,
      'total_views': totalViews,
    };
  }
}
