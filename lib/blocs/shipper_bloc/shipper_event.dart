part of 'shipper_bloc.dart';

abstract class ShipperEvent extends Equatable {
  const ShipperEvent();

  @override
  List<Object> get props => [];
}

class AcceptOrderEvent extends ShipperEvent {
  final String orderId;
  final String shipperId;
  final int recommendedOrdersIndex;
  final String shipperRouteId;
  final List<List<double>> orderGeometry;
  final double distance;

  const AcceptOrderEvent(
    this.orderId,
    this.shipperId,
    this.recommendedOrdersIndex,
    this.shipperRouteId,
    this.orderGeometry,
    this.distance,
  );

  @override
  List<Object> get props => [
        orderId,
        shipperId,
        recommendedOrdersIndex,
        shipperRouteId,
        orderGeometry,
        distance,
      ];
}

class GetCurrentOrdersEvent extends ShipperEvent {
  final String shipperId;

  const GetCurrentOrdersEvent(this.shipperId);

  @override
  List<Object> get props => [shipperId];
}

class RemoveCurrentOrderEvent extends ShipperEvent {
  final String orderId;

  const RemoveCurrentOrderEvent(this.orderId);

  @override
  List<Object> get props => [orderId];
}

class UpdateShipperMaxDistanceEvent extends ShipperEvent {
  final String shipperId;
  final double maxDistance;

  const UpdateShipperMaxDistanceEvent(this.shipperId, this.maxDistance);

  @override
  List<Object> get props => [shipperId, maxDistance];
}

class RecommendOrdersForShipperEvent extends ShipperEvent {
  final String shipperId;
  final double maxDistanceAllowance;

  const RecommendOrdersForShipperEvent(
      this.shipperId, this.maxDistanceAllowance);

  @override
  List<Object> get props => [shipperId, maxDistanceAllowance];
}
