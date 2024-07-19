import 'package:json_annotation/json_annotation.dart';

part 'order_feedback_model.g.dart';

@JsonSerializable()
class OrderFeedback {
  final int rating;
  final String comment;

  OrderFeedback({
    required this.rating,
    required this.comment,
  });

  factory OrderFeedback.fromJson(Map<String, dynamic> json) => _$OrderFeedbackFromJson(json);
  Map<String, dynamic> toJson() => _$OrderFeedbackToJson(this);
}
