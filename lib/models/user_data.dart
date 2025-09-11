class UserData {
  int? userId;
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
  bool? isActive; // ✅ Add if you want active/deactive status

  UserData();

  Map<String, String> toMap() {
    return {
      'user_id': userId?.toString() ?? '', // ✅ convert int → String
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

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData()
      ..userId = int.tryParse(json['user_id']?.toString() ?? '')
      ..name = json['name']?.toString()
      ..contactNo = json['contact_no']?.toString()
      ..dob = json['dob']?.toString()
      ..age = json['age']?.toString()
      ..emailId = json['email_id']?.toString()
      ..gender = json['gender']?.toString()
      ..religion = json['religion']?.toString()
      ..interCaste = json['inter_caste']?.toString()
      ..caste = json['caste']?.toString()
      ..subCaste = json['sub_caste']?.toString()
      ..dosham = json['dosham']?.toString()
      ..higherEducation = json['higher_education']?.toString()
      ..employeeIn = json['employee_in']?.toString()
      ..occupation = json['occupation']?.toString()
      ..annualIncome = json['annual_income']?.toString()
      ..workLocation = json['work_location']?.toString()
      ..state = json['state']?.toString()
      ..city = json['city']?.toString()
      ..aboutYourself = json['about_yourself']?.toString()
      ..profileImg = json['profile_img']?.toString()
      ..isActive = (json['user_sts']?.toString() == "0"); // optional
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
