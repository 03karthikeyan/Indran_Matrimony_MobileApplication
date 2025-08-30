class UserData {
  String? name;
  String? contactNo;
  String? dob;
  String? age;
  String? emailId;
  String? gender;
  String? religion;
  String? interCaste;
  String? caste;
  String? subCaste;
  String? dosham;
  String? higherEducation;
  String? employeeIn;
  String? occupation;
  String? annualIncome;
  String? workLocation;
  String? state;
  String? city;
  String? aboutYourself;
  String? profileImg;

  UserData();

  Map<String, String> toMap() {
    return {
      'name': name ?? '',
      'contact_no': contactNo ?? '',
      'dob': dob ?? '',
      'age': age ?? '',
      'email_id': emailId ?? '',
      'gender': gender ?? '',
      'religion': religion ?? '',
      'inter_caste': interCaste ?? '',
      'caste': caste ?? '',
      'sub_caste': subCaste ?? '',
      'dosham': dosham ?? '',
      'higher_education': higherEducation ?? '',
      'employee_in': employeeIn ?? '',
      'occupation': occupation ?? '',
      'annual_income': annualIncome ?? '',
      'work_location': workLocation ?? '',
      'state': state ?? '',
      'city': city ?? '',
      'about_yourself': aboutYourself ?? '',
      'profile_img': profileImg ?? 'profile.jpg',
    };
  }
}

//User profile

class UserProfile {
  final String name;
  final String profileImg;

  UserProfile({required this.name, required this.profileImg});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      profileImg: json['profile_img'] ?? '',
    );
  }
}
