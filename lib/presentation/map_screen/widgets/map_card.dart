// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../../../config/typography.dart';

class MapCard extends StatelessWidget {
  final List<String> addressList;
  final ScrollController scrollController;
  const MapCard({
    super.key,
    required this.addressList,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    List<Icon> leadingMarker = [
      Icon(
        Icons.location_on,
        color: Colors.blue,
      ),
      Icon(
        Icons.location_on,
        color: Colors.yellow,
      ),
      Icon(
        Icons.location_on,
        color: Colors.green,
      ),
      Icon(
        Icons.location_on,
        color: Colors.red,
      )
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 16.0, 12.0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Route Recommendation",
              style: AppTypography(context: context).title3),
          Expanded(
            child: ListView.separated(
              itemCount: 4,
              separatorBuilder: (context, index) => const SizedBox(
                height: 8,
              ),
              controller: scrollController,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    leadingMarker[index],
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: Text(
                        addressList[index],
                        style: AppTypography(context: context)
                            .bodyText
                            .copyWith(fontSize: 14.0),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
