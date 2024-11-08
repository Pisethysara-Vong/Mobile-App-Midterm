import 'package:ch7_animation_controller/widgets/animated_clouds.dart';
import 'package:flutter/material.dart';
import '../widgets/animated_balloon.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(title: const Text('Animations')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Row(
            children: [
              Column(
                children: [
                  CloudWidget(verticalPosition: 10.0),
                  const Row(
                    children: [
                      AnimatedBalloonWidget(float: Curves.bounceIn, size: Curves.elasticInOut, delay: 3,),
                      AnimatedBalloonWidget(float: Curves.linearToEaseOut, size: Curves.easeInOutBack, delay: 2,),
                      AnimatedBalloonWidget(float: Curves.ease, size: Curves.ease, delay: 1,),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}