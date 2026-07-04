import 'package:flutter/material.dart';
import '../tokens/colors.dart';

class ValidsSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ValidsSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 4,
  });

  @override
  State<ValidsSkeleton> createState() => _ValidsSkeletonState();
}

class _ValidsSkeletonState extends State<ValidsSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: const [
                ValidsColors.grey200,
                ValidsColors.grey100,
                ValidsColors.grey200,
              ],
            ),
          ),
        );
      },
    );
  }
}
