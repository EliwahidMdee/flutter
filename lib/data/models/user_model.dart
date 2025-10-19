import 'package:json_annotation/json_annotation.dart';
import '../../config/app_config.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int id;
  final String name;
  final String email;
  @JsonKey(name: 'profile_picture')
  final String? profilePicture;
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  final String? phone;
  final List<RoleModel>? roles;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    this.firstName,
    this.lastName,
    this.phone,
    this.roles,
    this.createdAt,
    this.updatedAt,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
  
  // Computed properties
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return name;
  }
  
  String? get primaryRole => roles?.first.name;
  
  bool hasRole(String roleName) {
    return roles?.any((role) => role.name.toLowerCase() == roleName.toLowerCase()) ?? false;
  }
  
  bool get isAdmin => hasRole('admin');
  bool get isLandlord => hasRole('landlord');
  bool get isTenant => hasRole('tenant');
  
  String? get profileImageUrl {
    if (profilePicture == null) return null;
    // Remove /api from base URL and add storage path
    final baseUrl = AppConfig.apiBaseUrl.replaceAll('/api', '');
    return '$baseUrl/storage/$profilePicture';
  }
}

@JsonSerializable()
class RoleModel {
  final int id;
  final String name;
  @JsonKey(name: 'display_name')
  final String? displayName;
  
  RoleModel({
    required this.id,
    required this.name,
    this.displayName,
  });
  
  factory RoleModel.fromJson(Map<String, dynamic> json) =>
      _$RoleModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$RoleModelToJson(this);
  
  String get displayNameOrDefault => displayName ?? name.toUpperCase();
}
