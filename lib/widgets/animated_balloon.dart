import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // Import audioplayers

class AnimatedBalloonWidget extends StatefulWidget {
  final String balloonImagePath; // Path to the balloon image
  final String inflateSoundPath; // Path to the balloon inflation sound
  final String popSoundPath; // Path to the balloon pop sound
  final Duration floatUpDuration; // Duration for the float-up animation
  final Duration sizeChangeDuration; // Duration for the size change animation
  final Duration burstDuration; // Duration for the burst animation
  final double balloonHeightFactor; // Balloon height factor based on screen size
  final double balloonWidthFactor; // Balloon width factor based on screen size
  final Curve float;
  final Curve size;
  final int delay;

  // Constructor to take parameters
  const AnimatedBalloonWidget({
    Key? key,
    this.balloonImagePath = 'assets/images/BeginningGoogleFlutter-Balloon.png',
    this.inflateSoundPath = 'sounds/balloon-inflation-85039.mp3',
    this.popSoundPath = 'sounds/balloon-pop-48030.mp3',
    this.floatUpDuration = const Duration(seconds: 10),
    this.sizeChangeDuration = const Duration(seconds: 9),
    this.burstDuration = const Duration(seconds: 0),
    this.balloonHeightFactor = 2,
    this.balloonWidthFactor = 3,
    required this.float,
    required this.size,
    required this.delay
  }) : super(key: key);

  @override
  _AnimatedBalloonWidgetState createState() => _AnimatedBalloonWidgetState();
}

class _AnimatedBalloonWidgetState extends State<AnimatedBalloonWidget> with TickerProviderStateMixin {
  late AnimationController _controllerFloatUp;
  late AnimationController _controllerChangeSize;
  late AnimationController _controllerBurst;
  late Animation<double> _animationFloatUp;
  late Animation<double> _animationChangeSize;
  late Animation<double> _animationBurst;

  bool _isBurst = false;
  late AudioCache _audioCache; // Using AudioCache to load assets

  @override
  void initState() {
    super.initState();

    _audioCache = AudioCache(); // Initialize the audio cache
    _audioCache.load(widget.popSoundPath); // Initialize the audio player

    _controllerFloatUp = AnimationController(
      duration: widget.floatUpDuration,
      vsync: this,
    );

    _controllerChangeSize = AnimationController(
      duration: widget.sizeChangeDuration,
      vsync: this,
    );

    _controllerBurst = AnimationController(
      duration: widget.burstDuration,
      vsync: this,
    );

    _controllerFloatUp.addStatusListener((status) {
      if (status != AnimationStatus.completed) {
        Future.delayed(Duration(seconds: widget.delay), () {
          _playAirSound();
        });
      }
      else if (status == AnimationStatus.completed) {
        _controllerBurst.forward();
      }
    });

    _controllerBurst.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isBurst = true;
          _playPopSound();
        });
      }
    });

  }

  @override
  void dispose() {
    _controllerFloatUp.dispose();
    _controllerChangeSize.dispose();
    _controllerBurst.dispose();
    super.dispose();
  }

  void _playAirSound() async {
    // Ensure the audio plays when the balloon inflates
    await _audioCache.play(widget.inflateSoundPath);
  }

  void _playPopSound() async {
    // Ensure the audio plays when the balloon bursts
    await _audioCache.play(widget.popSoundPath);
  }

  @override
  Widget build(BuildContext context) {
    double _balloonHeight = MediaQuery.of(context).size.height / widget.balloonHeightFactor;
    double _balloonWidth = MediaQuery.of(context).size.height / widget.balloonWidthFactor;
    double _balloonBottomLocation = MediaQuery.of(context).size.height - _balloonHeight;

    // Initialize animations here with updated context values
    _animationFloatUp = Tween(begin: _balloonBottomLocation, end: 0.0).animate(
      CurvedAnimation(parent: _controllerFloatUp, curve: widget.float),
    );

    _animationChangeSize = Tween(begin: 50.0, end: _balloonWidth).animate(
      CurvedAnimation(parent: _controllerChangeSize, curve: widget.size),
    );

    _animationBurst = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controllerBurst, curve: Curves.easeOut),
    );

    _controllerFloatUp.forward();
    _controllerChangeSize.forward();

    return AnimatedBuilder(
      animation: _animationFloatUp,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Shadow below the balloon, controlled by the burst animation
            Positioned(
              bottom: _animationFloatUp.value / 3, // Adjust shadow position as balloon floats
              child: Opacity(
                opacity: _animationBurst.value, // Fade shadow with balloon burst
                child: Container(
                  width: _animationChangeSize.value * 3.0, // Shadow width adjusts to balloon growth
                  height: _animationChangeSize.value * 0.4, // Shadow height adjusts to balloon growth
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            // Balloon Image
            if (!_isBurst)
              Container(
                margin: EdgeInsets.only(
                  top: _animationFloatUp.value,
                ),
                width: _animationChangeSize.value,
                child: child,
              ),
          ],
        );
      },
      child: Image.asset(
        widget.balloonImagePath,
        height: _balloonHeight,
        width: _balloonWidth,
      ),
    );
  }
}
