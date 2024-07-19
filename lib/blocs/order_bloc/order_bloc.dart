import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:packare_shipper/data/repositories/map_repository_impl.dart';
import 'package:packare_shipper/data/services/websocket_service.dart';
import '../../data/models/route_model.dart';
import '../../data/repositories/user_repository_impl.dart';

import '../../data/models/order_feedback_model.dart';
import '../../data/models/package_model.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../data/models/order_model.dart';
import '../../data/services/image_service.dart';
import '../shipper_bloc/shipper_bloc.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepositoryImpl orderRepository;
  final ImageService imageService;
  final UserRepositoryImpl userRepository;

  OrderBloc({
    required this.orderRepository,
    required this.imageService,
    required this.userRepository,
  }) : super(OrderState(
          status: OrderBlocStatus.initial,
          orders: [],
        )) {
    on<CreateOrderEvent>(_onCreateOrder);
    on<GetOrderByIdEvent>(_onGetOrderById);
    on<GetOrdersByUserEvent>(_onGetOrdersByUser);
    on<ProvideOrderFeedbackEvent>(_onProvideOrderFeedback);

    on<VerifyOrderEvent>(_onVerifyOrder);
    on<DeclineOrderEvent>(_onDeclineOrder);
    on<ConfirmPickupEvent>(_onConfirmPickup);
    on<ConfirmDeliveredEvent>(_onConfirmDelivered);
    on<CompleteOrderEvent>(_onCompleteOrder);
    on<CancelOrderEvent>(_onCancelOrder);
    on<ViewOrderHistory>(_onViewOrderHistory);
    on<GetOrderPackages>(_onGetOrderPackages);
    on<UpdatePackageEvent>(_onUpdatePackage);
    on<DeletePackageEvent>(_onDeletePackage);
    on<OrderStateLoadingEvent>(_onOrderStateLoadingEvent);
    on<StartShippingEvent>(_onStartShippingEvent);
  }

  void _onOrderStateLoadingEvent(
      OrderStateLoadingEvent event, Emitter<OrderState> emit) {
    emit(state.copyWith(status: OrderBlocStatus.loading));
  }

  void _onCreateOrder(CreateOrderEvent event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderBlocStatus.loading));
    try {
      final orderInfo = event.order;
      final List<Package> updatedPackages = [];

      for (final package in orderInfo.packages) {
        if (package.packageImageUrl != null &&
            package.packageImageUrl!.isNotEmpty) {
          // Upload each package image and get the download URL
          final downloadUrl = await imageService
              .uploadPackageImage(package.packageImageUrl!)
              .timeout(const Duration(seconds: 30));

          // Create a new Package instance with the updated packageImageUrl
          final updatedPackage = package.copyWith(packageImageUrl: downloadUrl);

          // Add the updated package to the list of packages
          updatedPackages.add(updatedPackage);
        } else {
          // If packageImageUrl is null, add the original package to the list of packages
          updatedPackages.add(package);
        }
      }
      await orderRepository
          .createOrder(orderInfo.copyWith(packages: updatedPackages))
          .timeout(const Duration(seconds: 30));
      emit(state.copyWith(status: OrderBlocStatus.success));
    } catch (error) {
      emit(state.copyWith(
          status: OrderBlocStatus.failure,
          error: (error is SocketException)
              ? 'Network error occurred. Please check your internet connection and try again.'
              : error.toString()));
    }
  }

  void _onGetOrderById(
      GetOrderByIdEvent event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderBlocStatus.loading));
    try {
      final currentOrder = await orderRepository
          .getOrderById(event.orderId)
          .timeout(const Duration(seconds: 30));
      emit(state.copyWith(
          status: OrderBlocStatus.success, currentOrder: currentOrder));
    } catch (error) {
      emit(state.copyWith(
          status: OrderBlocStatus.failure,
          error: (error is SocketException)
              ? 'Network error occurred. Please check your internet connection and try again.'
              : error.toString()));
    }
  }

  void _onGetOrdersByUser(
      GetOrdersByUserEvent event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderBlocStatus.loading));
    try {
      // Call the getUncompletedOrdersByUser method from OrderRepository
      final List<Order> orders = await orderRepository
          .getOrdersByUser(event.userId)
          .timeout(const Duration(seconds: 30));

      // Fetch shipper and sender data for each order asynchronously
      final List<Future<Order>> updatedOrders = orders.map((order) async {
        if (order.shipperId != null && order.shipperId!.isNotEmpty) {
          // Fetch shipper and sender data for the order
          final shipper = await userRepository.getUserProfile(order.shipperId!);
          final sender = await userRepository.getUserProfile(order.senderId);
          // Update the order with shipper data
          return order.copyWith(shipper: shipper, sender: sender);
        } else {
          return order;
        }
      }).toList();

      // Wait for all asynchronous fetches to complete
      final List<Order> updatedOrdersWithShipperData =
          await Future.wait(updatedOrders);

      emit(state.copyWith(
          status: OrderBlocStatus.success,
          orders: updatedOrdersWithShipperData));
    } catch (error) {
      emit(state.copyWith(
          status: OrderBlocStatus.failure,
          error: (error is SocketException)
              ? 'Network error occurred. Please check your internet connection and try again.'
              : error.toString()));
    }
  }

  void _onProvideOrderFeedback(
      ProvideOrderFeedbackEvent event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderBlocStatus.loading));
    try {
      await orderRepository
          .orderFeedback(event.orderId, event.feedback)
          .timeout(const Duration(seconds: 30));
      emit(state.copyWith(status: OrderBlocStatus.success));
    } catch (error) {
      emit(state.copyWith(
          status: OrderBlocStatus.failure,
          error: (error is SocketException)
              ? 'Network error occurred. Please check your internet connection and try again.'
              : error.toString()));
    }
  }

  void _onVerifyOrder(VerifyOrderEvent event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderBlocStatus.loading));
    try {
      await orderRepository
          .verifyOrder(event.orderId)
          .timeout(const Duration(seconds: 30));
      emit(state.copyWith(status: OrderBlocStatus.success));
    } catch (error) {
      emit(state.copyWith(
          status: OrderBlocStatus.failure,
          error: (error is SocketException)
              ? 'Network error occurred. Please check your internet connection and try again.'
              : error.toString()));
    }
  }

  void _onDeclineOrder(
      DeclineOrderEvent event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderBlocStatus.loading));
    try {
      await orderRepository
          .declineOrder(event.orderId)
          .timeout(const Duration(seconds: 30));
      emit(state.copyWith(status: OrderBlocStatus.success));
    } catch (error) {
      emit(state.copyWith(
          status: OrderBlocStatus.failure,
          error: (error is SocketException)
              ? 'Network error occurred. Please check your internet connection and try again.'
              : error.toString()));
    }
  }

  void _onConfirmPickup(
      ConfirmPickupEvent event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderBlocStatus.loading));
    try {
      await orderRepository
          .confirmPickup(event.orderId)
          .timeout(const Duration(seconds: 30));
      emit(state.copyWith(status: OrderBlocStatus.success));
    } catch (error) {
      emit(state.copyWith(
          status: OrderBlocStatus.failure,
          error: (error is SocketException)
              ? 'Network error occurred. Please check your internet connection and try again.'
              : error.toString()));
    }
  }

  void _onConfirmDelivered(
      ConfirmDeliveredEvent event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderBlocStatus.loading));
    try {
      await orderRepository
          .confirmDelivered(event.orderId)
          .timeout(const Duration(seconds: 30));
      
      emit(state.copyWith(status: OrderBlocStatus.success));
    } catch (error) {
      emit(state.copyWith(
          status: OrderBlocStatus.failure,
          error: (error is SocketException)
              ? 'Network error occurred. Please check your internet connection and try again.'
              : 'An unexpected error occurred while confirming delivered. Please try again later.'));
    }
  }

  void _onCompleteOrder(
      CompleteOrderEvent event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderBlocStatus.loading));
    try {
      await orderRepository
          .completeOrder(event.orderId)
          .timeout(const Duration(seconds: 30));
      emit(state.copyWith(status: OrderBlocStatus.success));
    } catch (error) {
      emit(state.copyWith(
          status: OrderBlocStatus.failure,
          error: (error is SocketException)
              ? 'Network error occurred. Please check your internet connection and try again.'
              : error.toString()));
    }
  }

  void _onCancelOrder(CancelOrderEvent event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderBlocStatus.loading));
    try {
      await orderRepository
          .cancelOrder(event.orderId)
          .timeout(const Duration(seconds: 30));
      emit(state.copyWith(status: OrderBlocStatus.success));
    } catch (error) {
      emit(state.copyWith(
          status: OrderBlocStatus.failure,
          error: (error is SocketException)
              ? 'Network error occurred. Please check your internet connection and try again.'
              : error.toString()));
    }
  }

  void _onStartShippingEvent(
      StartShippingEvent event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderBlocStatus.loading));
    try {
      await orderRepository
          .startShipping(event.orderId)
          .timeout(const Duration(seconds: 30));

      
      emit(state.copyWith(status: OrderBlocStatus.success));
    } catch (error) {
      emit(state.copyWith(
          status: OrderBlocStatus.failure,
          error: (error is SocketException)
              ? 'Network error occurred. Please check your internet connection and try again.'
              : error.toString()));
    }
  }

  void _onViewOrderHistory(
      ViewOrderHistory event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderBlocStatus.loading));
    try {
      final orderHistory = await orderRepository
          .viewOrderHistory()
          .timeout(const Duration(seconds: 30));
      emit(state.copyWith(
          status: OrderBlocStatus.success, orders: orderHistory));
    } catch (error) {
      emit(state.copyWith(
          status: OrderBlocStatus.failure,
          error: (error is SocketException)
              ? 'Network error occurred. Please check your internet connection and try again.'
              : error.toString()));
    }
  }

  void _onGetOrderPackages(
      GetOrderPackages event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderBlocStatus.loading));
    try {
      final packages = await orderRepository
          .getOrderPackages(event.orderId)
          .timeout(const Duration(seconds: 30));
      if (state.currentOrder != null) {
        emit(state.copyWith(
            status: OrderBlocStatus.success,
            currentOrder: state.currentOrder!.copyWith(packages: packages)));
      } else {
        throw ('Current order not found, please try again');
      }
    } catch (error) {
      emit(state.copyWith(
          status: OrderBlocStatus.failure,
          error: (error is SocketException)
              ? 'Network error occurred. Please check your internet connection and try again.'
              : error.toString()));
    }
  }

  void _onUpdatePackage(
      UpdatePackageEvent event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderBlocStatus.loading));
    try {
      await orderRepository
          .updatePackage(event.orderId, event.packageId, event.package)
          .timeout(const Duration(seconds: 30));
      emit(state.copyWith(status: OrderBlocStatus.success));
    } catch (error) {
      emit(state.copyWith(
          status: OrderBlocStatus.failure,
          error: (error is SocketException)
              ? 'Network error occurred. Please check your internet connection and try again.'
              : error.toString()));
    }
  }

  void _onDeletePackage(
      DeletePackageEvent event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderBlocStatus.loading));
    try {
      await orderRepository
          .deletePackage(event.orderId, event.packageId)
          .timeout(const Duration(seconds: 30));
      emit(state.copyWith(status: OrderBlocStatus.success));
    } catch (error) {
      emit(state.copyWith(
          status: OrderBlocStatus.failure,
          error: (error is SocketException)
              ? 'Network error occurred. Please check your internet connection and try again.'
              : error.toString()));
    }
  }
}
