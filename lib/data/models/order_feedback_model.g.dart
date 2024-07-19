// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_feedback_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderFeedback _$OrderFeedbackFromJson(Map<String, dynamic> json) =>
    OrderFeedback(
      rating: json['rating'] as int,
      comment: json['comment'] as String,
    );

Map<String, dynamic> _$OrderFeedbackToJson(OrderFeedback instance) =>
    <String, dynamic>{
      'rating': instance.rating,
      'comment': instance.comment,
    };
