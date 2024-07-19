import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:packare_shipper/blocs/map_bloc/map_bloc.dart';
import 'package:packare_shipper/data/repositories/map_repository_impl.dart';

import '../../data/models/route_model.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../data/repositories/shipper_repository_impl.dart';
import '../../data/models/order_model.dart';

import '../../data/repositories/user_repository_impl.dart';
import '../../data/services/websocket_service.dart';
import '../account_bloc/account_bloc.dart';

part 'shipper_event.dart';
part 'shipper_state.dart';

class ShipperBloc extends Bloc<ShipperEvent, ShipperState> {
  final ShipperRepositoryImpl shipperRepository;
  final MapRepositoryImpl mapRepository;
  final OrderRepositoryImpl orderRepository;
  final UserRepositoryImpl userRepository;
  final AccountBloc accountBloc;
  final WebSocketService webSocketService;

  ShipperBloc({
    required this.userRepository,
    required this.shipperRepository,
    required this.mapRepository,
    required this.orderRepository,
    required this.accountBloc,
    required this.webSocketService,
  }) : super(ShipperState(recommendedOrders: [], currentShippingOrders: [])) {
    on<UpdateShipperMaxDistanceEvent>(_onUpdateShipperMaxDistanceEvent);
    on<RecommendOrdersForShipperEvent>(_onRecommendOrdersForShipperEvent);
    on<AcceptOrderEvent>(_onAcceptOrderEvent);
    on<RemoveCurrentOrderEvent>(_onRemoveCurrentOrderEvent);
    on<GetCurrentOrdersEvent>(_onGetCurrentOrdersEvent);
  }

  void _onGetCurrentOrdersEvent(
      GetCurrentOrdersEvent event, Emitter<ShipperState> emit) async {
    emit(state.copyWith(shippingStatus: ShippingStatus.loading));
    try {
      List<OrderWithInfo> currentOrders =
          await shipperRepository.getCurrentOrders(event.shipperId);

      for (var order in currentOrders) {
        order.order.sender =
            await userRepository.getUserProfile(order.order.senderId);

        order.order.shipperRoute =
            await mapRepository.getRouteById(order.shipperRouteId);
        if (order.order.status == OrderStatus.startShipping ||
            order.order.status == OrderStatus.shipperPickedUp) {
          webSocketService.startLocationStream(
              order.order.orderId, order.order.shipperId!);
        } else if (order.order.status == OrderStatus.cancelled ||
            order.order.status == OrderStatus.delivered) {
          webSocketService.cancelLocationStream(
              order.order.orderId, order.order.shipperId!);
        }
      }

      emit(state.copyWith(
          currentShippingOrders: currentOrders,
          shippingStatus: currentOrders.isEmpty
              ? ShippingStatus.noOrder
              : ShippingStatus.haveOrder));
    } catch (error) {
      emit(state.copyWith(
          shippingStatus: ShippingStatus.error,
          error: (error is SocketException)
              ? 'Network error occurred. Please check your internet connection and try again.'
              : error.toString()));
    }
  }

  void _onAcceptOrderEvent(
    AcceptOrderEvent event,
    Emitter<ShipperState> emit,
  ) async {
    emit(state.copyWith(shippingStatus: ShippingStatus.loading));
    try {

      await orderRepository
          .acceptOrder(
            event.orderId,
            event.shipperId,
            event.shipperRouteId,
            event.orderGeometry,
            event.distance,
          )
          .timeout(const Duration(seconds: 30));

      // Add the accepted order to current shipping orders
      final updatedCurrentShippingOrders =
          List<OrderWithInfo>.from(state.currentShippingOrders ?? []);
      updatedCurrentShippingOrders
          .add(state.recommendedOrders![event.recommendedOrdersIndex]);
      print(updatedCurrentShippingOrders);
      final updatedRecommendedOrders = state.recommendedOrders!;
      updatedRecommendedOrders
          .removeWhere((order) => order.order.orderId == event.orderId);

      emit(state.copyWith(
        currentShippingOrders: updatedCurrentShippingOrders,
        recommendedOrders: updatedRecommendedOrders,
        shippingStatus: ShippingStatus.acceptOrder,
      ));
      emit(state.copyWith(shippingStatus: ShippingStatus.haveOrder));
    } catch (error) {
      emit(state.copyWith(
        shippingStatus: ShippingStatus.errorAccepting,
        acceptOrderError: (error is SocketException)
            ? 'Network error occurred. Please check your internet connection and try again.'
            : error.toString(),
      ));
    }
  }

  void _onRemoveCurrentOrderEvent(
      RemoveCurrentOrderEvent event, Emitter<ShipperState> emit) async {
    final updateCurrentShippingOrders = state.currentShippingOrders ?? [];
    updateCurrentShippingOrders
        .removeWhere((order) => order.order.orderId == event.orderId);
    emit(state.copyWith(
        shippingStatus: updateCurrentShippingOrders.isEmpty
            ? ShippingStatus.noOrder
            : ShippingStatus.haveOrder,
        currentShippingOrders: updateCurrentShippingOrders));
  }

  void _onUpdateShipperMaxDistanceEvent(
      UpdateShipperMaxDistanceEvent event, Emitter<ShipperState> emit) async {
    emit(state.copyWith(recommendOrdersStatus: RecommendOrdersStatus.loading));
    try {
      await shipperRepository
          .updateShipperMaxDistance(event.shipperId, event.maxDistance)
          .timeout(const Duration(seconds: 30));

      // Emit event to AccountBloc to update the account state
      accountBloc
          .add(UpdateShipperMaxDistanceInAccountEvent(event.maxDistance));

      emit(state.copyWith(
        recommendOrdersStatus: RecommendOrdersStatus.success,
        error: null,
      ));
    } catch (error) {
      emit(state.copyWith(
        recommendOrdersStatus: RecommendOrdersStatus.failed,
        error: (error is TimeoutException)
            ? 'The request timed out. Please check your internet connection and try again.'
            : (error is SocketException)
                ? 'Network error occurred. Please check your internet connection and try again.'
                : (error is PlatformException)
                    ? 'Failed to update shipper max distance. Please try again later.'
                    : 'An unexpected error occurred while updating shipper max distance. Please try again later.',
      ));
    }
  }

  void _onRecommendOrdersForShipperEvent(
      RecommendOrdersForShipperEvent event, Emitter<ShipperState> emit) async {
    emit(state.copyWith(recommendOrdersStatus: RecommendOrdersStatus.loading));
    try {
      final List<OrderWithInfo> allRecommendedOrders =
          await shipperRepository.recommendOrdersForShipper(
              event.shipperId, event.maxDistanceAllowance);

      for (var orderWithInfo in allRecommendedOrders) {
        final Route shipperRoute =
            await mapRepository.getRouteById(orderWithInfo.shipperRouteId);

        orderWithInfo.order.shipperRoute = shipperRoute;
      }

      emit(state.copyWith(
        recommendOrdersStatus: RecommendOrdersStatus.success,
        recommendedOrders: allRecommendedOrders,
        error: null,
      ));
    } catch (error) {
      emit(
        state.copyWith(
          recommendOrdersStatus: RecommendOrdersStatus.failed,
          error: (error is TimeoutException)
              ? 'The request timed out. Please check your internet connection and try again.'
              : (error is SocketException)
                  ? 'Network error occurred. Please check your internet connection and try again.'
                  : (error is PlatformException)
                      ? 'Failed to recommend orders for shipper. Please try again later.'
                      : 'An unexpected error occurred while recommending orders for shipper. Please try again later.',
        ),
      );
    }
  }
}
