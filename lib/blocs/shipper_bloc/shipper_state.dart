part of 'shipper_bloc.dart';

enum RecommendOrdersStatus { initial, loading, success, failed }

enum ShippingStatus {
  haveOrder,
  acceptOrder,
  noOrder,
  error,
  loading,
  errorAccepting
}

class ShipperState {
  RecommendOrdersStatus recommendOrdersStatus;
  List<OrderWithInfo>? recommendedOrders;
  List<OrderWithInfo>? currentShippingOrders;
  ShippingStatus shippingStatus;
  String? error;
  String? acceptOrderError;

  ShipperState({
    this.recommendOrdersStatus = RecommendOrdersStatus.initial,
    this.recommendedOrders,
    this.currentShippingOrders,
    this.shippingStatus = ShippingStatus.noOrder,
    this.error,
    this.acceptOrderError,
  });

  ShipperState copyWith({
    RecommendOrdersStatus? recommendOrdersStatus,
    List<OrderWithInfo>? recommendedOrders,
    List<OrderWithInfo>? currentShippingOrders,
    ShippingStatus? shippingStatus,
    String? error,
    String? acceptOrderError,
  }) {
    return ShipperState(
      recommendOrdersStatus:
          recommendOrdersStatus ?? this.recommendOrdersStatus,
      recommendedOrders: recommendedOrders ?? this.recommendedOrders,
      currentShippingOrders:
          currentShippingOrders ?? this.currentShippingOrders,
      shippingStatus: shippingStatus ?? this.shippingStatus,
      error: error ?? this.error,
      acceptOrderError: acceptOrderError ?? this.acceptOrderError,
    );
  }
}
