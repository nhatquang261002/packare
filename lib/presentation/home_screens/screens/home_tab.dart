import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../blocs/account_bloc/account_bloc.dart';

import '../../../blocs/shipper_bloc/shipper_bloc.dart';
import '../../../config/path.dart';
import '../../home_screens/widgets/home_app_bar.dart';

import '../../order_screens/screens/order_detail_screen.dart';
import '../../../config/typography.dart';

import '../widgets/shipper_home_order_list_item.dart';

class HomeTab extends StatelessWidget {
  final VoidCallback navigateToOrdersTab;
  const HomeTab({super.key, required this.navigateToOrdersTab});

  @override
  Widget build(BuildContext context) {
    final shipperAccount = context.read<AccountBloc>().state.account;
    return Scaffold(
      body: BlocConsumer<ShipperBloc, ShipperState>(
        listener: (context, state) {
          if (state.shippingStatus == ShippingStatus.acceptOrder) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Order accepted')),
            );
            navigateToOrdersTab();
          } else if (state.shippingStatus == ShippingStatus.errorAccepting) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error accepting order')),
            );
          }
        },
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // app bar
              const HomeAppBar(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                child: Text(
                  'Available Orders',
                  style: AppTypography(context: context).bodyText.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                        fontSize: 14.0,
                      ),
                ),
              ),
              Expanded(
                child: state.recommendOrdersStatus ==
                            RecommendOrdersStatus.loading ||
                        state.recommendOrdersStatus ==
                            RecommendOrdersStatus.initial
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : state.recommendedOrders!.isEmpty ||
                            state.recommendOrdersStatus ==
                                RecommendOrdersStatus.failed
                        ? RefreshIndicator(
                            onRefresh: () async {
                              final account =
                                  context.read<AccountBloc>().state.account;

                              if (account != null) {
                                context.read<ShipperBloc>().add(
                                    RecommendOrdersForShipperEvent(
                                        account.shipper!.shipperId,
                                        account.shipper!.maxDistanceAllowance));
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Text(
                                        'Cannot find your information, please login again',
                                        style: AppTypography(context: context)
                                            .bodyText,
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
                                height:
                                    MediaQuery.of(context).size.height * 0.6,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: SizedBox(
                                        height: 150,
                                        width: 150,
                                        child: SvgPicture.asset(
                                          packare_logo_path,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    Text(
                                      'No Order Available',
                                      style: AppTypography(context: context)
                                          .title3
                                          .copyWith(
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
                              final account =
                                  context.read<AccountBloc>().state.account;

                              if (account != null) {
                                context.read<ShipperBloc>().add(
                                    RecommendOrdersForShipperEvent(
                                        account.shipper!.shipperId,
                                        account.shipper!.maxDistanceAllowance));
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Text(
                                        'Cannot find your information, please login again',
                                        style: AppTypography(context: context)
                                            .bodyText,
                                      ),
                                    );
                                  },
                                );
                                context.read<AccountBloc>().add(LogoutEvent());
                              }
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                //  itemCount: state.orders!.length,
                                itemCount: state.recommendedOrders!.length,
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return const SizedBox(height: 12.0);
                                },
                                itemBuilder: (BuildContext context, int index) {
                                  return InkWell(
                                    onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                OrderDetailScreen(
                                                    //                      orderId: state.orders![index]
                                                    orderId: state
                                                        .recommendedOrders![
                                                            index]
                                                        .order
                                                        .orderId))),
                                    child:
                                        // shipper Order Item
                                        ShipperHomeOrderListItem(
                                            order: state
                                                .recommendedOrders![index]
                                                .order,
                                            shipperRouteId: state
                                                .recommendedOrders![index]
                                                .shipperRouteId,
                                            orderGeometry: state
                                                .recommendedOrders![index]
                                                .orderGeometry,
                                            shipperId: shipperAccount!
                                                .shipper!.shipperId,
                                            recommendedOrdersIndex: index,
                                            distance: state
                                                .recommendedOrders![index]
                                                .distance),

                                    // User Order Item
                                  );
                                },
                              ),
                            ),
                          ),
              ),
              const SizedBox(
                height: 16,
              ),
            ],
          );
        },
      ),
    );
  }
}
