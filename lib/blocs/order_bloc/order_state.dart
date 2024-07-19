// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'order_bloc.dart';

enum OrderBlocStatus {
  initial,
  loading,
  success,
  failure,
}

class OrderState {
  OrderBlocStatus status;

  Order? currentOrder;

  List<Order>? orders;
  String? error;

  OrderState({
    this.status = OrderBlocStatus.initial,
    this.currentOrder,
    this.orders,
    this.error,
  });

  OrderState copyWith({
    OrderBlocStatus? status,
    Order? currentOrder,
    List<Order>? orders,
    String? error,
  }) {
    return OrderState(
      status: status ?? this.status,
      currentOrder: currentOrder ?? this.currentOrder,
      orders: orders ?? this.orders,
      error: error ?? this.error,
    );
  }
}
