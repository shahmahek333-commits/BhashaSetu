import 'dart:convert';

/// Represents the primary role of the user within BhashaSetu.
enum UserRole {
  teacher,
  student;

  String get displayName {
    switch (this) {
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.student:
        return 'Student';
    }
  }

  /// The natural translation direction determined by role.
  /// Teacher: Hindi -> Santhali
  /// Student: Santhali -> Hindi
  String get sourceLanguage {
    switch (this) {
      case UserRole.teacher:
        return 'Hindi';
      case UserRole.student:
        return 'Santhali';
    }
  }

  String get targetLanguage {
    switch (this) {
      case UserRole.teacher:
        return 'Santhali';
      case UserRole.student:
        return 'Hindi';
    }
  }

  String get translationDirectionLabel {
    return '$sourceLanguage → $targetLanguage';
  }

  static UserRole fromString(String? role) {
    if (role == null) return UserRole.teacher;
    return role.toLowerCase() == 'student' ? UserRole.student : UserRole.teacher;
  }
}

/// User profile model for BhashaSetu storing essential identity,
/// institutional affiliation, and educational role.
class UserProfile {
  final String fullName;
  final UserRole role;
  final String grade;
  final String schoolName;
  final String? gender;

  const UserProfile({
    required this.fullName,
    required this.role,
    required this.grade,
    required this.schoolName,
    this.gender,
  });

  /// Translation direction helper based on role.
  String get sourceLanguage => role.sourceLanguage;
  String get targetLanguage => role.targetLanguage;
  String get translationDirectionLabel => role.translationDirectionLabel;

  UserProfile copyWith({
    String? fullName,
    UserRole? role,
    String? grade,
    String? schoolName,
    String? gender,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      grade: grade ?? this.grade,
      schoolName: schoolName ?? this.schoolName,
      gender: gender ?? this.gender,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'role': role.name,
      'grade': grade,
      'schoolName': schoolName,
      'gender': gender,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      fullName: map['fullName'] as String? ?? '',
      role: UserRole.fromString(map['role'] as String?),
      grade: map['grade'] as String? ?? 'Class 1',
      schoolName: map['schoolName'] as String? ?? '',
      gender: map['gender'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.fullName == fullName &&
        other.role == role &&
        other.grade == grade &&
        other.schoolName == schoolName &&
        other.gender == gender;
  }

  @override
  int get hashCode {
    return Object.hash(fullName, role, grade, schoolName, gender);
  }
}
