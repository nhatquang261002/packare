// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:packare_shipper/config/typography.dart';
import 'package:packare_shipper/data/models/order_model.dart';
import 'package:packare_shipper/presentation/map_screen/widgets/map_card.dart';
import 'package:packare_shipper/presentation/map_screen/widgets/map_widget.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MapScreen extends StatefulWidget {
  final OrderWithInfo? currentOrder;
  const MapScreen({
    Key? key,
    this.currentOrder,
  }) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool isCenter = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    bool haveOrder = widget.currentOrder != null;

    List<LatLng>? waypoints = [
      LatLng(widget.currentOrder?.order.sendCoordinates.coordinates[1] ?? 0,
          widget.currentOrder?.order.sendCoordinates.coordinates[0] ?? 0),
      LatLng(widget.currentOrder?.order.deliveryCoordinates.coordinates[1] ?? 0,
          widget.currentOrder?.order.deliveryCoordinates.coordinates[0] ?? 0)
    ];

    List<List<double>>? geometry = widget.currentOrder?.orderGeometry;
    LatLng? startCoords = LatLng(
        widget.currentOrder?.order.shipperRoute?.startCoordinates
                .coordinates[1] ??
            0,
        widget.currentOrder?.order.shipperRoute?.startCoordinates
                .coordinates[0] ??
            0);
    LatLng? endCoords = LatLng(
        widget.currentOrder?.order.shipperRoute?.endCoordinates
                .coordinates[1] ??
            0,
        widget.currentOrder?.order.shipperRoute?.endCoordinates
                .coordinates[0] ??
            0);
    OrderStatus? orderStatus = widget.currentOrder?.order.status;

    return Scaffold(
      body: SafeArea(
        child: SlidingUpPanel(
          minHeight: haveOrder ? size.height * 0.15 : 0,
          maxHeight: haveOrder ? size.height * 0.25 : 0,
          borderRadius: BorderRadius.circular(12.0),
          color: Theme.of(context).colorScheme.background,
          boxShadow: const [
            BoxShadow(
              blurRadius: 20.0,
              color: Colors.grey,
            ),
          ],
          margin: const EdgeInsets.all(24.0),
          panelBuilder: (sc) => haveOrder ? MapCard(addressList:  [
      widget.currentOrder!.order.shipperRoute!.startLocation,
      widget.currentOrder!.order.sendAddress,
      widget.currentOrder!.order.deliveryAddress,
      widget.currentOrder!.order.shipperRoute!.endLocation
    ], scrollController: sc)
           : const SizedBox.shrink()   ,
          body: Stack(
            children: [
              haveOrder
                  ? MapWidget(
                      startCoords: startCoords,
                      endCoords: endCoords,
                      geometry: geometry,
                      waypoints: waypoints,
                    )
                  : MapWidget(),
              haveOrder
                  ? _buildStatusBar(context, orderStatus!)
                  : const SizedBox.shrink(),
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar(BuildContext context, OrderStatus orderStatus) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(45.0),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 2.0,
                  color: Colors.grey,
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 16,
                ),
                Text(
                  orderStatusMapping(orderStatus),
                  style: AppTypography(context: context).bodyText,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.02,
                ),
                CircleAvatar(
                  backgroundColor: Colors.blue[600],
                  radius: 4,
                ),
                const SizedBox(
                  width: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
