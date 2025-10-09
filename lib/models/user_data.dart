class UserData {
  int? userId;
  String? userCode;
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
  String? profileFor;
  String? profileImgPath;
  bool? isActive;

  // ✅ New fields
  String? maritalStatus;
  String? skinColor;
  String? height;
  String? weight;
  String? physicalStatus;
  String? financialStatus;
  String? district;
  String? addressLane1;
  String? addressLane2;
  String? pincode;
  String? aadharImgPath;
  String? communityCertificatePath;
  String? jathakamPath;
  String? badge;

  String? diet;
  String? hobbies;
  String? interests;
  String? fatherName;
  String? motherName;
  String? siblings;
  String? nativePlace;
  String? motherTongue;

  UserData();

  Map<String, String> toMap() {
    return {
      'user_id': userId?.toString() ?? '',
      'user_code': userCode ?? '',
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
      'profile_img': profileImg ?? '',
      'profile_img_path': profileImgPath ?? '',
      'marital_status': maritalStatus ?? '',
      'skin_color': skinColor ?? '',
      'height': height ?? '',
      'weight': weight ?? '',
      'physical_status': physicalStatus ?? '',
      'financial_status': financialStatus ?? '',
      'district': district ?? '',
      'address_lane1': addressLane1 ?? '',
      'address_lane2': addressLane2 ?? '',
      'pincode': pincode ?? '',
      'profileFor': profileFor ?? '',
      'diet': diet ?? '',
      'hobbies': hobbies ?? '',
      'interests': interests ?? '',
      'father_name': fatherName ?? '',
      'mother_name': motherName ?? '',
      'siblings': siblings ?? '',
      'native_place': nativePlace ?? '',
      'mother_tongue': motherTongue ?? '',
    };
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData()
      ..userId = int.tryParse(json['user_id']?.toString() ?? '')
      ..userCode = json['user_code']?.toString()
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
      ..profileImgPath = json['profile_img_path']?.toString()
      ..isActive = (json['user_sts']?.toString() == "0")
      ..maritalStatus = json['marital_status']?.toString()
      ..skinColor = json['skin_color']?.toString()
      ..height = json['height']?.toString()
      ..weight = json['weight']?.toString()
      ..physicalStatus = json['physical_status']?.toString()
      ..financialStatus = json['financial_status']?.toString()
      ..district = json['district']?.toString()
      ..addressLane1 = json['address_lane1']?.toString()
      ..addressLane2 = json['address_lane2']?.toString()
      ..pincode = json['pincode']?.toString()
      ..diet = json['diet']?.toString()
      ..hobbies = json['hobbies']?.toString()
      ..interests = json['interests']?.toString()
      ..fatherName = json['father_name']?.toString()
      ..motherName = json['mother_name']?.toString()
      ..siblings = json['siblings']?.toString()
      ..nativePlace = json['native_place']?.toString()
      ..motherTongue = json['mother_tongue']?.toString()
      ..profileFor = json['profileFor']?.toString()
      ..aadharImgPath = json['aadhar_img_path']?.toString()
      ..communityCertificatePath =
          json['community_certificate_path']?.toString()
      ..jathakamPath = json['jathakam_path']?.toString()
      ..badge = json['badge']?.toString();
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
      profileImg: json['profile_img_path'] ?? '',
    );
  }
}

// annual income class

class AnnualIncome {
  final String id;
  final String income;
  final String? minIncome;
  final String? maxIncome;

  AnnualIncome({
    required this.id,
    required this.income,
    this.minIncome,
    this.maxIncome,
  });

  factory AnnualIncome.fromJson(Map<String, dynamic> json) {
    return AnnualIncome(
      id: json['id'],
      income: json['income'],
      minIncome: json['min_income'],
      maxIncome: json['max_income'],
    );
  }
}
