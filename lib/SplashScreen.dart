import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:recipe_generator/Authantication/Login.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    // Initialize video player
    _controller = VideoPlayerController.asset("assets/images/spalsh.mp4")
      ..initialize().then((_) {
        setState(() {}); // Refresh UI when the video is initialized
      });

    // Play video and navigate after video ends
    _controller.setLooping(false);
    _controller.play();

    _controller.addListener(() {
      if (!_controller.value.isPlaying && _controller.value.duration == _controller.value.position) {
        _navigateToHome();
      }
    });

    // Hide system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _navigateToHome() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: _controller.value.isInitialized
                ? VideoPlayer(_controller)
                : Center(child: CircularProgressIndicator()), // Show loading until video is ready
          ),
        ],
      ),
    );
  }
}
