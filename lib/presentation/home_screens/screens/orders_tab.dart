import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../blocs/shipper_bloc/shipper_bloc.dart';
import '../../../config/typography.dart';
import '../../../data/models/order_model.dart';
import '../..//home_screens/widgets/orders_list_item.dart';

import '../../../blocs/account_bloc/account_bloc.dart';
import '../../../blocs/order_bloc/order_bloc.dart';
import '../../../config/path.dart';

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {

  @override
  void initState() {
    final shipper = context.read<AccountBloc>().state.account!.shipper!;
    context.read<ShipperBloc>().add(GetCurrentOrdersEvent(shipper.shipperId));
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    

    final tabLabelTextStyle = AppTypography(context: context)
        .footnote
        .copyWith(fontWeight: FontWeight.normal);
    final colorScheme = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Orders",
            style: AppTypography(context: context).title3,
          ),
        ),
        body: Column(
          children: [
            TabBar(
              isScrollable: true,
              physics: const AlwaysScrollableScrollPhysics(),
              labelPadding: const EdgeInsets.all(16.0),
              unselectedLabelStyle: tabLabelTextStyle,
              labelStyle: tabLabelTextStyle,
              labelColor: colorScheme.primary,
              tabs: const [
                Text("Available Order"),
                Text("Picking Up Order"),
                Text("On Delivery"),
                Text("Delivery Successful"),
                Text("Completed"),
              ],
            ),
            Expanded(
              child: BlocBuilder<ShipperBloc, ShipperState>(
                builder: (context, state) {
        
                  if (state.shippingStatus == ShippingStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    if (state.shippingStatus == ShippingStatus.error) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.error!)));
                      });
                    }
                    return TabBarView(
                      children: [
                        orderTab(
                          context: context,
                          status: OrderStatus.shipperAccepted,
                          orders: state.currentShippingOrders!
                              .where((o) =>
                                  o.order.status == OrderStatus.shipperAccepted)
                              .toList(),
                          haveCancelButton: true,
                          functionButtonString: 'Start Shipping',
                          functionButtonIcon: Icons.check,
                        ),
                        orderTab(
                          context: context,
                          status: OrderStatus.startShipping,
                          orders: state.currentShippingOrders!
                              .where((o) =>
                                  o.order.status == OrderStatus.startShipping)
                              .toList(),
                          haveCancelButton: false,
                          functionButtonString: 'Confirm Picked Up',
                          functionButtonIcon: Icons.check,
                        ),
                        orderTab(
                          context: context,
                          status: OrderStatus.shipperPickedUp,
                          orders: state.currentShippingOrders!
                              .where((o) =>
                                  o.order.status == OrderStatus.shipperPickedUp)
                              .toList(),
                          functionButtonString: 'Confirm Delivered',
                          functionButtonIcon: Icons.check,
                        ),
                        orderTab(
                            context: context,
                            status: OrderStatus.delivered,
                            orders: state.currentShippingOrders!
                                .where((o) =>
                                    o.order.status == OrderStatus.delivered)
                                .toList()),
                        orderTab(
                            context: context,
                            status: OrderStatus.completed,
                            orders: state.currentShippingOrders!
                                .where((o) =>
                                    o.order.status == OrderStatus.completed)
                                .toList()),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget orderTab({
  required BuildContext context,
  required OrderStatus status,
  required List<OrderWithInfo> orders,
  String? functionButtonString,
  IconData? functionButtonIcon,
  bool haveCancelButton = false,
}) {
  VoidCallback functionButtonCallback = () {};
  bool haveFunctionButton = false;
  TabController tabController = DefaultTabController.of(context);

  return orders.isEmpty
      ? RefreshIndicator(
          onRefresh: () async {
            final account = context.read<AccountBloc>().state.account;

            if (account != null) {
              context
                  .read<ShipperBloc>()
                  .add(GetCurrentOrdersEvent(account.shipper!.shipperId));
            } else {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: Text(
                      'Cannot find your information, please login again',
                      style: AppTypography(context: context).bodyText,
                    ),
                  );
                },
              );
              context.read<AccountBloc>().add(LogoutEvent());
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: SizedBox(
                      height: 150,
                      width: 150,
                      child: SvgPicture.asset(
                        orders_empty,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Order',
                    style: AppTypography(context: context).title3.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            ),
          ),
        )
      : RefreshIndicator(
          onRefresh: () async {
            final account = context.read<AccountBloc>().state.account;

            if (account != null) {
              context
                  .read<ShipperBloc>()
                  .add(GetCurrentOrdersEvent(account.shipper!.shipperId));
            } else {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: Text(
                      'Cannot find your information, please login again',
                      style: AppTypography(context: context).bodyText,
                    ),
                  );
                },
              );
              context.read<AccountBloc>().add(LogoutEvent());
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: orders.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 12.0),
              itemBuilder: (context, index) {
                if (functionButtonString == 'Start Shipping') {
                  haveFunctionButton = true;
                  functionButtonCallback = () {
                    // Show a confirmation dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Start Shipping Order"),
                          content: Text(
                              "Your location will be shared to the sender of the order"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                // Dispatch ConfirmPickupEvent
                                context.read<OrderBloc>().add(
                                    StartShippingEvent(
                                        orderId: orders[index].order.orderId));
                                Navigator.of(context).pop(); // Close the dialog
                                final shipper = context
                                    .read<AccountBloc>()
                                    .state
                                    .account!
                                    .shipper!;
                                context.read<ShipperBloc>().add(
                                    GetCurrentOrdersEvent(shipper.shipperId));


                                tabController.animateTo(1);
                              },
                              child: Text("Confirm"),
                            ),
                          ],
                        );
                      },
                    );
                  };
                } else if (functionButtonString == 'Confirm Picked Up') {
                  haveFunctionButton = true;
                  functionButtonCallback = () {
                    // Show a confirmation dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Confirm Pickup"),
                          content: Text("Are you sure the order is picked up?"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                // Dispatch ConfirmPickupEvent
                                context
                                    .read<OrderBloc>()
                                    .add(ConfirmPickupEvent(
                                      orderId: orders[index].order.orderId,
                                    ));
                                Navigator.of(context).pop(); // Close the dialog
                                final shipper = context
                                    .read<AccountBloc>()
                                    .state
                                    .account!
                                    .shipper!;
                                context.read<ShipperBloc>().add(
                                    GetCurrentOrdersEvent(shipper.shipperId));

                                tabController.animateTo(2);
                              },
                              child: Text("Confirm"),
                            ),
                          ],
                        );
                      },
                    );
                  };
                } else if (functionButtonString == 'Confirm Delivered') {
                  haveFunctionButton = true;
                  functionButtonCallback = () {
                    // Show a confirmation dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Confirm Delivery"),
                          content: Text("Are you sure the order is delivered?"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                // Dispatch ConfirmDeliveredEvent
                                context
                                    .read<OrderBloc>()
                                    .add(ConfirmDeliveredEvent(
                                      orderId: orders[index].order.orderId,
                                    ));
                                Navigator.of(context).pop(); // Close the dialog

                                final shipper = context
                                    .read<AccountBloc>()
                                    .state
                                    .account!
                                    .shipper!;
                                context.read<ShipperBloc>().add(
                                    GetCurrentOrdersEvent(shipper.shipperId));

                                tabController.animateTo(3);
                              },
                              child: Text("Confirm"),
                            ),
                          ],
                        );
                      },
                    );
                  };
                }

                return OrdersListItem(
                  order: orders[index],
                  haveCancelButton: haveCancelButton,
                  functionButtonString: functionButtonString ?? '',
                  functionButtonCallback: functionButtonCallback,
                  functionButtonIconData: functionButtonIcon ?? Icons.map,
                  haveFunctionButton: haveFunctionButton,
                );
              },
            ),
          ),
        );
}
