// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../../../config/typography.dart';

class CollapsedCard extends StatelessWidget {
  const CollapsedCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 16.0, 12.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: 20,
              separatorBuilder: (context, index) => const SizedBox(
                height: 2,
              ),
              itemBuilder: (context, index) {
                return Text(
                  "${index + 1}. Address",
                  style: AppTypography(context: context).bodyText,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
