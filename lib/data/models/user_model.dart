// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  @JsonKey(name: 'user_id')
  String userId;

  @JsonKey(name: 'first_name')
  String firstName;

  @JsonKey(name: 'last_name')
  String lastName;

  @JsonKey(name: 'phone_number')
  String phoneNumber;

  @JsonKey(name: 'order_history')
  List<String> orderHistory;

  User({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.orderHistory,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? userId,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    List<String>? orderHistory,
  }) {
    return User(
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      orderHistory: orderHistory ?? this.orderHistory,
    );
  }
}
