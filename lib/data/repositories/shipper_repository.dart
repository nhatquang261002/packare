import '../models/account_model.dart';
import '../models/order_model.dart';

abstract class ShipperRepository {
  Future<List<OrderWithInfo>> getCurrentOrders(String shipperId);
  Future<Account> updateShipperMaxDistance(
      String shipperId, double maxDistanceAllowance);
  Future<List<OrderWithInfo>> recommendOrdersForShipper(
      String shipperId, double maxDistanceAllowance);
}
