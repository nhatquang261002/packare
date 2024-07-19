import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:packare_shipper/blocs/account_bloc/account_bloc.dart';
import 'package:packare_shipper/blocs/shipper_bloc/shipper_bloc.dart';
import 'package:packare_shipper/config/typography.dart';

class ConfigMaxDistanceAllowanceScreen extends StatefulWidget {
  const ConfigMaxDistanceAllowanceScreen({Key? key}) : super(key: key);

  @override
  State<ConfigMaxDistanceAllowanceScreen> createState() =>
      _ConfigMaxDistanceAllowanceScreenState();
}

class _ConfigMaxDistanceAllowanceScreenState
    extends State<ConfigMaxDistanceAllowanceScreen> {
  double shipperMaxDistance = 0.0;
  double originalValue = 0.0;
  String shipperId = '';

  @override
  void initState() {
    super.initState();
    // Initialize shipperMaxDistance with the initial value
    shipperMaxDistance = context
        .read<AccountBloc>()
        .state
        .account!
        .shipper!
        .maxDistanceAllowance;
    originalValue = shipperMaxDistance;
    shipperId = context.read<AccountBloc>().state.account!.shipper!.shipperId;
  }

  @override
  Widget build(BuildContext context) {
    bool isChanged = shipperMaxDistance != originalValue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Config Expanding Distance'),
        actions: [
          TextButton(
            onPressed: isChanged
                ? () {
                    // Update the distance value in the Bloc
                    context.read<ShipperBloc>().add(
                          UpdateShipperMaxDistanceEvent(
                              shipperId, shipperMaxDistance),
                        );
                    // Disable the save button while loading
                    setState(() {
                      originalValue = shipperMaxDistance;
                    });
                  }
                : null,
            child: Text(
              'Save',
              style: TextStyle(
                color: isChanged
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<ShipperBloc, ShipperState>(
        listener: (context, state) {
          if (state.recommendOrdersStatus == RecommendOrdersStatus.success) {
            context.read<AccountBloc>().add(
                  UpdateShipperMaxDistanceInAccountEvent(shipperMaxDistance),
                );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Configuration saved successfully!'),
              ),
            );
          } else if (state.recommendOrdersStatus ==
              RecommendOrdersStatus.failed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error ?? 'Failed to save configuration.'),
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Maximum Distance: $shipperMaxDistance km',
                  style: AppTypography(context: context)
                      .bodyText
                      .copyWith(fontSize: 20.0),
                ),
                Slider(
                  value: shipperMaxDistance,
                  min: 1.0,
                  max: 10.0,
                  divisions: 90,
                  inactiveColor: Colors.grey,
                  onChanged: (newValue) {
                    setState(() {
                      shipperMaxDistance =
                          double.parse(newValue.toStringAsFixed(2));
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
