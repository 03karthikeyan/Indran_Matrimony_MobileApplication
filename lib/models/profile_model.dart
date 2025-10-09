class Profile {
  final int userId;
  final String name;
  final int age;
  final String profileImg;
  final String? occupation;
  final String? city;
  final String? caste;
  final String? higherEducation;
  final String? aboutYourself;
  final String? contactNo;
  final String? state;
  final String? religion;
  final String? subCaste;
  final String? gothram;
  final String? employeeIn;
  final String? annualIncome;
  final int? totalViews;

  Profile({
    required this.userId,
    required this.name,
    required this.age,
    required this.profileImg,
    this.occupation,
    this.city,
    this.caste,
    this.higherEducation,
    this.aboutYourself,
    this.contactNo,
    this.state,
    this.religion,
    this.subCaste,
    this.gothram,
    this.employeeIn,
    this.annualIncome,
    this.totalViews,
  });

  /// ✅ Create Profile from API response
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      userId: int.tryParse(json['user_id'].toString()) ?? 0,
      name: json['name'] ?? '',
      age: int.tryParse(json['age'].toString()) ?? 0,
      profileImg: json['profile_img'] ?? '',
      occupation: json['occupation'],
      city: json['city'],
      caste: json['caste'],
      higherEducation: json['higher_education'],
      aboutYourself: json['about_yourself'],
      contactNo: json['contact_no'],
      state: json['state'],
      religion: json['religion'],
      subCaste: json['sub_caste'],
      gothram: json['Gothram'],
      employeeIn: json['employee_in'],
      annualIncome: json['income_range'],
      totalViews: int.tryParse(json['totalViews']?.toString() ?? '0'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'age': age,
      'profile_img': profileImg,
      'occupation': occupation,
      'city': city,
      'caste': caste,
      'higher_education': higherEducation,
      'about_yourself': aboutYourself,
      'contact_no': contactNo,
      'state': state,
      'religion': religion,
      'sub_caste': subCaste,
      'Gothram': gothram,
      'employee_in': employeeIn,
      'income_range': annualIncome,
      'totalViews': totalViews,
    };
  }
}
