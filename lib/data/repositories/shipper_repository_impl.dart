import 'dart:io';
import 'package:flutter/services.dart';
import '../models/account_model.dart';
import '../models/order_model.dart';
import '../repositories/shipper_repository.dart';
import '../services/shared_preferences_service.dart';
import '../services/shipper_service.dart';

class ShipperRepositoryImpl implements ShipperRepository {
  final ShipperService _shipperService;
  final SharedPreferencesService _sharedPreferencesService;

  ShipperRepositoryImpl({
    required ShipperService shipperService,
    required SharedPreferencesService sharedPreferencesService,
  })  : _shipperService = shipperService,
        _sharedPreferencesService = sharedPreferencesService;

  Future<String?> _getToken() async {
    final token = _sharedPreferencesService.getStringValue('token');
    if (token == null) {
      throw Exception('Token not found');
    }
    return token;
  }

  @override
  Future<List<OrderWithInfo>> getCurrentOrders(String shipperId) async {
    try {
      final token = await _getToken();

      final response =
          await _shipperService.getCurrentOrders(token!, shipperId);

      // Parse JSON response
      final List<dynamic> jsonOrders =
          response['currentOrders']; // Ensure it's a list

      // Map JSON orders to OrderWithInfo objects
      final List<OrderWithInfo> ordersWithInfo = [];
      for (var jsonOrder in jsonOrders) {
        // Parse JSON order data
        final order = Order.fromJson(jsonOrder);
        final distance = double.parse(jsonOrder['distance'].toString());
        final List<List<double>> orderGeometry =
            (jsonOrder['order_geometry'] as List<dynamic>)
                .map<List<double>>((dynamic e) => (e as List<dynamic>)
                    .map<double>((dynamic e) => e.toDouble())
                    .toList())
                .toList();
        final shipperRouteId = jsonOrder['shipper_route_id'];

        // Create OrderWithInfo object
        final orderWithInfo = OrderWithInfo(
          order: order,
          distance: distance,
          orderGeometry: orderGeometry,
          shipperRouteId: shipperRouteId,
        );

        // Add order to the list
        ordersWithInfo.add(orderWithInfo);
      }

      return ordersWithInfo;
    } on SocketException catch (_) {
      throw PlatformException(
          code: 'NETWORK_ERROR', message: 'Network error occurred.');
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Account> updateShipperMaxDistance(
      String shipperId, double maxDistanceAllowance) async {
    try {
      final token = await _getToken();

      final response = await _shipperService.updateShipperMaxDistance(
          token!, shipperId, maxDistanceAllowance);

      return Account.fromJson(response['shipper']);
    } on SocketException catch (_) {
      throw PlatformException(
          code: 'NETWORK_ERROR', message: 'Network error occurred.');
    } catch (error) {
      print('Error updating shipper max distance: $error');
      rethrow;
    }
  }

  @override
  Future<List<OrderWithInfo>> recommendOrdersForShipper(
      String shipperId, double maxDistanceAllowance) async {
    try {
      final token = await _getToken();

      final response = await _shipperService.recommendOrdersForShipper(
          token!, shipperId, maxDistanceAllowance);

      final List<OrderWithInfo> orderWithInfo = [];
      // Check if response contains the key 'recommendedOrders'
      if (response.containsKey('recommendedOrders')) {
        final List<dynamic> orderData = response['recommendedOrders'];
        for (var orderJson in orderData) {
          final Order order = Order.fromJson(orderJson['order']);
          final double distance =
              double.parse(orderJson['distance'].toString());
          final List<List<double>> orderGeometry = List<List<double>>.from(
              orderJson['orderGeometry'].map((item) => List<double>.from(
                  item.map((subItem) => subItem.toDouble()))));
          final String routeId = orderJson['orderRouteId'];

          orderWithInfo.add(OrderWithInfo(
              order: order,
              distance: distance,
              orderGeometry: orderGeometry,
              shipperRouteId: routeId));
        }
      } else {
        throw Exception('Invalid response format');
      }

      return orderWithInfo;
    } on SocketException catch (_) {
      throw PlatformException(
          code: 'NETWORK_ERROR', message: 'Network error occurred.');
    } catch (error) {
      print('Error recommending orders for shipper: $error');
      rethrow;
    }
  }
}
