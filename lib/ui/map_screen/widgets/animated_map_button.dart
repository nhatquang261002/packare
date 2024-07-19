import 'package:flutter/material.dart';

class AnimatedMapButton extends StatefulWidget {
  @override
  _AnimatedMapButtonState createState() => _AnimatedMapButtonState();
}

class _AnimatedMapButtonState extends State<AnimatedMapButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isCenter = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return IconButton(
          iconSize: 28,
          visualDensity: VisualDensity.comfortable,
          style: IconButton.styleFrom(
            elevation: 2,
            backgroundColor: Colors.white,
            fixedSize: const Size.fromRadius(26),
            shape: const CircleBorder(),
          ),
          onPressed: () {
            setState(() {
              isCenter = !isCenter;
              if (isCenter) {
                _controller.reverse();
              } else {
                _controller.forward();
              }
            });
          },
          icon: _controller.value == 0
              ? const Icon(
                  Icons.my_location,
                  color: Colors.blue,
                )
              : const Icon(
                  Icons.explore_outlined,
                  color: Colors.blue,
                ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
