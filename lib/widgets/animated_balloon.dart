import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AnimatedBalloonWidget extends StatefulWidget {
  final String balloonImagePath;
  final String inflateSoundPath;
  final String popSoundPath;
  final Duration floatUpDuration;
  final Duration sizeChangeDuration;
  final Duration burstDuration;
  final double balloonHeightFactor;
  final double balloonWidthFactor;
  final Curve float;
  final Curve size;
  final int delay;

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
    required this.delay,
  }) : super(key: key);

  @override
  _AnimatedBalloonWidgetState createState() => _AnimatedBalloonWidgetState();
}

class _AnimatedBalloonWidgetState extends State<AnimatedBalloonWidget>
    with TickerProviderStateMixin {
  late AnimationController _controllerFloatUp;
  late AnimationController _controllerChangeSize;
  late AnimationController _controllerBurst;
  late Animation<double> _animationFloatUp;
  late Animation<double> _animationChangeSize;
  late Animation<double> _animationBurst;

  bool _isBurst = false;
  late AudioCache _audioCache;

  @override
  void initState() {
    super.initState();

    _audioCache = AudioCache();
    _audioCache.load(widget.popSoundPath);

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
      if (status == AnimationStatus.forward) {
        Future.delayed(Duration(seconds: widget.delay), _playAirSound);
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
    await _audioCache.play(widget.inflateSoundPath);
  }

  void _playPopSound() async {
    await _audioCache.play(widget.popSoundPath);
  }

  @override
  Widget build(BuildContext context) {
    double _balloonHeight =
        MediaQuery.of(context).size.height / widget.balloonHeightFactor;
    double _balloonWidth =
        MediaQuery.of(context).size.height / widget.balloonWidthFactor;
    double _balloonBottomLocation =
        MediaQuery.of(context).size.height - _balloonHeight;

    _animationFloatUp = Tween(begin: _balloonBottomLocation, end: 0.0).animate(
      CurvedAnimation(parent: _controllerFloatUp, curve: widget.float),
    );

    _animationChangeSize =
        Tween(begin: 50.0, end: _balloonWidth).animate(
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
            // Shadow below the balloon, only disappears when the balloon bursts
            if (!_isBurst)
              Positioned(
                bottom: _animationFloatUp.value / 3,
                child: Opacity(
                  opacity: _isBurst ? 0.0 : 1.0, // Shadow fades on burst
                  child: Container(
                    width: _animationChangeSize.value * 3.0,
                    height: _animationChangeSize.value * 0.4,
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
      child: GestureDetector(
        onTap: () {
          if (_controllerFloatUp.isCompleted) {
            setState(() {
              _isBurst = true;
            });
            _playPopSound();
            _controllerBurst.forward(); // Trigger burst animation
          }
        },
        child: Image.asset(
          widget.balloonImagePath,
          height: _balloonHeight,
          width: _balloonWidth,
        ),
      ),
    );
  }
}
