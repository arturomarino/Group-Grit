import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:group_grit/utils/constants/colors.dart';
import 'package:group_grit/utils/constants/size.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerPage extends StatefulWidget {
  final String imageUrl;
  final String videoUrl;

  const VideoPlayerPage({super.key, required this.imageUrl, required this.videoUrl});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _loadingPlay = false;

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.blue, // Cambia con il colore desiderato
        statusBarIconBrightness: Brightness.dark, // o dark
      ),
    );
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        Future.delayed(Duration(seconds: 2), () {
          setState(() {
            _loadingPlay = true;
            _controller.play();
          });
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GGColors.backgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: kBottomNavigationBarHeight,
            left: 0,
            child: Hero(
                tag: "videoHero",
                child: _isInitialized && _loadingPlay == true
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_controller.value.isPlaying) {
                              _controller.pause();
                            } else {
                              _controller.play();
                            }
                          });
                        },
                        child: SizedBox(
                          width: GGSize.screenWidth(context),
                          height: GGSize.screenHeight(context) * 0.22,
                          child: Stack(
                            children: [
                              VideoPlayer(_controller),
                              Positioned.fill(child: buildPlay()),
                            ],
                          ),
                        ),
                      )
                    : Stack(
                        children: [
                          Image.network(
                            widget.imageUrl,
                            width: GGSize.screenWidth(context),
                            height: GGSize.screenHeight(context) * 0.22,
                            fit: BoxFit.cover,
                          ),
                          Positioned.fill(
                              child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ))
                        ],
                      )),
          ),
          Positioned(
            top: 0,
            left: 5,
            child: SafeArea(
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          // Qui puoi integrare un video player come `video_player` o `chewie`
        ],
      ),
    );
  }

  Widget buildPlay() => _controller.value.isPlaying
      ? Container(
          color: Colors.transparent,
        )
      : Center(
          child: Container(
            color: Colors.transparent,
            child: Icon(FontAwesomeIcons.play, color: Colors.red, size: 40),
          ),
        );
}
