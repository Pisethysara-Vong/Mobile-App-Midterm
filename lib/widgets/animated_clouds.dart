import 'package:flutter/material.dart';

class CloudWidget extends StatefulWidget {
  // Define the parameters that the widget will take
  final String cloudImagePath;
  final Duration animationDuration;
  final double cloudHeightFactor;
  final double cloudWidthFactor;
  final double verticalPosition; // New parameter for vertical position

  // Add a constructor to accept the parameters
  CloudWidget({
    Key? key,
    this.cloudImagePath = 'assets/images/cloud-outline-icon-22293.png', // Make sure to require a valid path for the image
    required this.verticalPosition,
    this.animationDuration = const Duration(seconds: 11), // Default animation duration
    this.cloudHeightFactor = 8, // Default factor for height
    this.cloudWidthFactor = 8, // Default factor for width
  }) : super(key: key);

  @override
  _CloudWidgetState createState() => _CloudWidgetState();
}

class _CloudWidgetState extends State<CloudWidget> with TickerProviderStateMixin {
  late AnimationController _controllerSlideRight;
  late Animation<double> _animationSlideRight;

  @override
  void initState() {
    super.initState();
    _controllerSlideRight = AnimationController(
      duration: widget.animationDuration, // Use passed animation duration
      vsync: this,
    );

  }

  @override
  void dispose() {
    _controllerSlideRight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _cloudHeight = MediaQuery.of(context).size.height / widget.cloudHeightFactor;
    double _cloudWidth = MediaQuery.of(context).size.width / widget.cloudWidthFactor;

    // Initialize the animation using screen width inside build method
    _animationSlideRight = Tween(
      begin: 0.0,
      end: MediaQuery.of(context).size.width - _cloudWidth,
    ).animate(CurvedAnimation(parent: _controllerSlideRight, curve: Curves.linear));

    _controllerSlideRight.forward();

    return AnimatedBuilder(
      animation: _animationSlideRight,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.only(
            left: _animationSlideRight.value,
            top: widget.verticalPosition,
          ),
          width: _cloudWidth,
          height: _cloudHeight,
          child: child,
        );
      },
    child: GestureDetector(
      onTap: () {
      if (_controllerSlideRight.isAnimating) {
        _controllerSlideRight.stop();
      } else {
        _controllerSlideRight.repeat();
        }
      },
      child: Image.asset(
        widget.cloudImagePath,
        fit: BoxFit.contain,
        ),
      ),
    );
  }
}
