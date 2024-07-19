// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:packare_shipper/blocs/order_bloc/order_bloc.dart';
import 'package:packare_shipper/blocs/shipper_bloc/shipper_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:packare_shipper/config/path.dart';
import 'package:packare_shipper/config/typography.dart';
import 'package:packare_shipper/data/models/order_model.dart';
import 'package:packare_shipper/presentation/global_widgets/image_screen.dart';

import '../../map_screen/screen/map_screen.dart';
import 'location_icon_column.dart';

class OrdersListItem extends StatelessWidget {
  final OrderWithInfo order;
  final bool haveCancelButton;
  final String functionButtonString;
  final VoidCallback functionButtonCallback;
  final IconData functionButtonIconData;
  final bool haveFunctionButton;
  const OrdersListItem({
    Key? key,
    required this.order,
    required this.haveCancelButton,
    required this.functionButtonString,
    required this.functionButtonCallback,
    required this.functionButtonIconData,
    required this.haveFunctionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> packagesWithImages = order.order.packages
        .where((package) =>
            package.packageImageUrl != null &&
            package.packageImageUrl!.isNotEmpty)
        .map((package) => package.packageImageUrl!)
        .toList();

    List<String> packageNamesWithImages = order.order.packages
        .where((package) =>
            package.packageImageUrl != null &&
            package.packageImageUrl!.isNotEmpty)
        .map((package) => package.packageName)
        .toList();

    List<String> packagesName = [];
    double holdingFee = 0;
    for (var e in order.order.packages) {
      holdingFee += e.packagePrice;
      packagesName.add(e.packageName);
    }

    final cardTextStyle = AppTypography(context: context).bodyText.copyWith(
          fontSize: 14.0,
        );

    bool isShipping = (order.order.status == OrderStatus.startShipping ||
        order.order.status == OrderStatus.shipperAccepted ||
        order.order.status == OrderStatus.shipperPickedUp ||
        order.order.status == OrderStatus.delivered);

    bool haveFeedback = order.order.feedback != null;

    return Material(
      elevation: 2.0,
      color: Theme.of(context).colorScheme.background,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: isShipping
            ? haveFunctionButton
                ? 500
                : 435
            : 370,
        padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isShipping)
              Row(
                children: [
                  CircleAvatar(
                    radius: 18.0,
                    child: SvgPicture.asset(user_avatar),
                  ),
                  const SizedBox(
                    width: 15.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Sender",
                          style: cardTextStyle.copyWith(
                              fontWeight: FontWeight.w600)),
                      Text(
                          "${order.order.sender?.user.firstName ?? ""} ${order.order.sender?.user.lastName ?? ""}",
                          style: cardTextStyle),
                      Text(order.order.sender?.user.phoneNumber ?? "",
                          style: cardTextStyle),
                    ],
                  ),
                  const Spacer(),
                  !haveFeedback ? IconButton(
                    onPressed: () {
                      String phoneNumber = order.order.sender!.user.phoneNumber;
                      String uri = "tel:$phoneNumber";
                      launchUrl(Uri.parse(uri));
                    },
                    icon: Icon(
                      Icons.phone,
                      color: Colors.blue[800],
                    ),
                  ) :  Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              Text("Feedback",
                          style: cardTextStyle.copyWith(
                              fontWeight: FontWeight.w600)),
                             Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 1; i <= 5; i++)
                   Icon(
                        i <= order.order.feedback!.rating ? Icons.star : Icons.star_border,
                        color: Colors.orange[400],
                      ),
                 
                ],
              ),
              Text(order.order.feedback!.comment,
                          style: cardTextStyle),
                          ],
                        ) 
                    ,
                ],
              ),
            const SizedBox(
              height: 8.0,
            ),
            Row(
              children: [
                CircleAvatar(
                  radius: 18.0,
                  child: SvgPicture.asset(user_avatar),
                ),
                const SizedBox(
                  width: 15.0,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Receiver",
                        style: cardTextStyle.copyWith(
                            fontWeight: FontWeight.w600)),
                    Text("${order.order.receiverName}", style: cardTextStyle),
                    Text(order.order.receiverPhone, style: cardTextStyle),
                  ],
                ),
                const Spacer(),
                !haveFeedback ? IconButton(
                  onPressed: () {
                    String phoneNumber = order.order.receiverPhone;
                    String uri = "tel:$phoneNumber";
                    launchUrl(Uri.parse(uri));
                  },
                  icon: Icon(
                    Icons.phone,
                    color: Colors.blue[800],
                  ),
                ) : const SizedBox.shrink(),
              ],
            ),
            if (isShipping) const Divider(),

            // Apart from shipper part
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    width: 52,
                    child: SvgPicture.asset(
                      packare_logo_path,
                      height: 24,
                      width: 24,
                    ),
                  ),
                  SelectableText(
                    order.order.orderId,
                    style: AppTypography(context: context)
                        .title1
                        .copyWith(fontSize: 18),
                  ),
                  IconButton(
                    onPressed: () {
                      // Copy order.order ID to clipboard
                      Clipboard.setData(
                          ClipboardData(text: order.order.orderId));
                      // Show a snackbar or toast to indicate that the order.order ID is copied
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Order ID copied to clipboard'),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.copy,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    iconSize: 16,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            locationIconColumn(
              context,
              order.order.sendAddress,
              order.order.deliveryAddress,
            ),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 52.0),
              child: Text(
                "Packages: ${packagesName.join(', ')}",
                style: cardTextStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 52.0),
              child: Text(
                "Status: ${orderStatusMapping(order.order.status)}",
                style: cardTextStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 52.0),
              child: Text(
                "Shipping Price: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(order.order.shippingPrice)}",
                style: cardTextStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 52.0),
              child: Text(
                "Holding Fee: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(holdingFee)}",
                style: cardTextStyle,
              ),
            ),
            const SizedBox(
              height: 12.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: packagesWithImages.isNotEmpty
                      ? () {
                          // Open PackageImageScreen when button is pressed
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PackageImageScreen(
                                imageUrls: packagesWithImages,
                                packageNames: packageNamesWithImages,
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.blue[300]),
                  ),
                  icon: Icon(
                    Icons.picture_in_picture_alt,
                    color: Colors.blue[900],
                    size: 16.0,
                  ),
                  label: Text(
                    "Packages Picture",
                    style: cardTextStyle.copyWith(color: Colors.blue[900]),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                MapScreen(currentOrder: order)));
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.blue[300]),
                  ),
                  icon: Icon(
                    Icons.map,
                    color: Colors.blue[900],
                    size: 16.0,
                  ),
                  label: Text(
                    "Route",
                    style: cardTextStyle.copyWith(color: Colors.blue[900]),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),

            // If the order.order status is these, the order.order cannot be cancelled
            order.order.status == OrderStatus.delivered ||
                    order.order.status == OrderStatus.cancelled ||
                    order.order.status == OrderStatus.completed
                ? const SizedBox.shrink()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (haveCancelButton)
                        TextButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Cancel Order"),
                                  content: Text(
                                      "Are you sure you want to cancel this order.order?"),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                      },
                                      child: Text(
                                        "No",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        // Close the dialog
                                        Navigator.of(context).pop();

                                        // Cover backend cancel
                                        context.read<OrderBloc>().add(
                                            CancelOrderEvent(
                                                orderId: order.order.orderId));

                                        // Wait for the cancellation process
                                        await Future.delayed(
                                            Duration(seconds: 1));

                                        // Check the cancellation status
                                        if (context
                                                .read<OrderBloc>()
                                                .state
                                                .status ==
                                            OrderBlocStatus.success) {
                                          // Cover current shipping order.order of shipper UI
                                          context.read<ShipperBloc>().add(
                                              RemoveCurrentOrderEvent(
                                                  order.order.orderId));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            content: Text(
                                                'Successfully Canceled Order'),
                                          ));
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            content:
                                                Text('Cancel Order Failed'),
                                          ));
                                        }
                                      },
                                      child: Text(
                                        "Yes",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.red[200]),
                          ),
                          icon: Icon(
                            Icons.cancel,
                            color: Colors.red[900],
                            size: 16.0,
                          ),
                          label: Text(
                            "Cancel",
                            style:
                                cardTextStyle.copyWith(color: Colors.red[900]),
                          ),
                        ),
                      const SizedBox(width: 8),
                      haveFunctionButton
                          ? TextButton.icon(
                              onPressed: functionButtonCallback,
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStatePropertyAll(Colors.blue[300]),
                              ),
                              icon: Icon(
                                functionButtonIconData,
                                color: Colors.blue[900],
                                size: 16.0,
                              ),
                              label: Text(
                                functionButtonString,
                                style: cardTextStyle.copyWith(
                                    color: Colors.blue[900]),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
