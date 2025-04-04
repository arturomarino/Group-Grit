import 'dart:ui';

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:group_grit/pages/VideoPreview/VideoPlayerHorizontalPage.dart';
import 'package:group_grit/utils/constants/colors.dart';
import 'package:group_grit/utils/constants/size.dart';
import 'package:rxdart/rxdart.dart';
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
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  bool _isInitialized = false;
  bool _loadingPlay = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );
    /*_videoPlayerController.initialize().then((_) {
      setState(() {
        _isInitialized = true;
      });
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _loadingPlay = true;
          _videoPlayerController.play();
        });
      });
    });*/
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      autoInitialize: true,
      looping: true,
      aspectRatio: 16 / 9,
    );
    setState(() {
        _isInitialized = true;
      });
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _loadingPlay = true;
          _videoPlayerController.play();
        });
      });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    //_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Orientation: ${MediaQuery.of(context).orientation}');
    return Scaffold(
      backgroundColor: GGColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: GGColors.backgroundColor,
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).orientation == Orientation.landscape ? 40.0 : 0),
          child: Column(
            children: [
              
              Hero(
                  tag: "videoHero",
                  child: _isInitialized && _loadingPlay == true
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_videoPlayerController.value.isPlaying) {
                                _videoPlayerController.pause();
                              } else {
                                _videoPlayerController.play();
                              }
                            });
                          },
                          child: SizedBox(
                            width: GGSize.screenWidth(context),
                            child: Stack(
                              children: [
                                AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Chewie(
                        controller: _chewieController,
                      ),
                    ),
                                Visibility(
                                  visible: !_videoPlayerController.value.isPlaying,
                                  child: Positioned.fill(
                                    child: Container(
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Stack(
                          children: [
                            SizedBox(
                              width: GGSize.screenWidth(context),
                              height: GGSize.screenWidth(context) * (1080 / 1920),
                              child: AspectRatio(
                                aspectRatio: 1920 / 1080,
                                child: Image.network(
                                  widget.imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned.fill(
                                child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )),
                          ],
                        )),
              Visibility(
                visible: MediaQuery.of(context).orientation == Orientation.portrait,
                child: Expanded(
                  child: Container(
                    child: Stack(
                      children: [
                        Positioned(
                          left: GGSize.screenWidth(context) * 0.05,
                          top: GGSize.screenHeight(context) * 0.03,
                          child: GlassTile(
                              containerWidth: GGSize.screenWidth(context) * 0.5,
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 10.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Football Team', style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold)),
                                      Text(
                                          'Stay connected with your squad, no matter where you are! Our app helps your football team stay organized with training schedules, match updates, and real-time communication.',
                                          style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w700, color: const Color.fromARGB(195, 58, 57, 57))),
                                    ],
                                  ))),
                        ),
                        Positioned(
                          right: GGSize.screenWidth(context) * 0.05,
                          top: GGSize.screenHeight(context) * 0.2,
                          child: GlassTile(
                              containerWidth: GGSize.screenWidth(context) * 0.55,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Yoga Group', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                                    Text(
                                        'Find balance and connection from anywhere in the world. Our app lets you join live yoga sessions, track your progress, and engage with a supportive community of like-minded practitioners.',
                                        style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w700, color: const Color.fromARGB(195, 58, 57, 57))),
                                  ],
                                ),
                              )),
                        ),
                        Positioned(
                          left: GGSize.screenWidth(context) * 0.05,
                          top: GGSize.screenHeight(context) * 0.37,
                          child: GlassTile(
                              containerWidth: GGSize.screenWidth(context) * 0.5,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Boxing Club', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                                    Text(
                                        'Train harder, fight smarter. Our app keeps your boxing club connected with workout plans, sparring schedules, and progress tracking.',
                                        style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w700, color: const Color.fromARGB(195, 58, 57, 57))),
                                  ],
                                ),
                              )),
                        ),
                        Positioned(
                          right: GGSize.screenWidth(context) * 0.05,
                          top: GGSize.screenHeight(context) * 0.1,
                          child: GlassTile2(
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 5.0),
                                  child: Text(
                                    '🏋' + ' Challenge',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ))),
                        ),
                        Positioned(
                          left: GGSize.screenWidth(context) * 0.05,
                          top: GGSize.screenHeight(context) * 0.25,
                          child: GlassTile2(
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 5.0),
                                  child: Text(
                                    '🔥' + ' Streak',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ))),
                        ),
                        Positioned(
                          right: GGSize.screenWidth(context) * 0.05,
                          top: GGSize.screenHeight(context) * 0.42,
                          child: GlassTile2(
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 5.0),
                                  child: Text(
                                    '🏆' + ' Rankings',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ))),
                        ),
                        // Aggiungi altri Positioned per ulteriori tile
                      ],
                    ),
                  ),
                ),
              ),

              // Qui puoi integrare un video player come `video_player` o `chewie`
            ],
          ),
        ),
      ),
    );
  }

  /*Widget buildPlay() => _controller.value.isPlaying
      ? Container(
          color: Colors.transparent,
        )
      : Center(
          child: Container(
            color: Colors.transparent,
            child: Icon(FontAwesomeIcons.play, color: Colors.white, size: 40),
          ),
        );

  Widget buildProgressIndicatorBar(BuildContext context) => Row(
        children: [
          Expanded(
            child: Container(
              height: 6,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: StreamBuilder<Duration>(
                  stream: _controller.position.asStream().whereType<Duration>(),
                  builder: (context, snapshot) {
                    return ValueListenableBuilder(
                      valueListenable: _controller,
                      builder: (context, VideoPlayerValue value, child) {
                        final position = value.position;
                        final duration = value.isInitialized ? value.duration : Duration.zero;
                        final progress = duration.inMilliseconds > 0 ? position.inMilliseconds / duration.inMilliseconds : 0.0;

                        return GestureDetector(
                          onTapDown: (details) {
                            if (value.isInitialized) {
                              final tapPosition = details.localPosition.dx;
                              final newProgress = tapPosition / GGSize.screenWidth(context);
                              final newPosition = Duration(milliseconds: (newProgress * duration.inMilliseconds).toInt());
                              _controller.seekTo(
                                newPosition < Duration.zero ? Duration.zero : (newPosition > duration ? duration : newPosition),
                              );
                            }
                          },
                          child: LinearProgressIndicator(
                            value: progress,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                            backgroundColor: Color(0xFFFFDAB8),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          CupertinoButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => VideoPlayerHorizontalPage(
                          videoUrl: widget.videoUrl,
                          imageUrl: widget.imageUrl,
                          controller: _controller,
                        )));
              },
              padding: EdgeInsets.zero,
              child: Icon(Icons.fullscreen, color: Colors.white, size: 30)),
        ],
      );*/
}

class GlassTile extends StatelessWidget {
  final Widget child;
  final double containerWidth;

  const GlassTile({Key? key, required this.child, required this.containerWidth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26.0), // Bordo arrotondato
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Effetto sfocatura
        child: Container(
          width: containerWidth,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 255, 55, 205).withOpacity(0.5),
                const Color.fromARGB(255, 13, 25, 255).withOpacity(0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ), // Gradiente lineare
            borderRadius: BorderRadius.circular(26.0),
            border: Border.all(
              color: Colors.black.withOpacity(0.3), // Bordo semi-trasparente
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
            child: child,
          ),
        ),
      ),
    );
  }
}

class GlassTile2 extends StatelessWidget {
  final Widget child;

  const GlassTile2({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26.0), // Bordo arrotondato
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Effetto sfocatura
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 255, 55, 55).withOpacity(0.5),
                const Color.fromARGB(255, 255, 69, 13).withOpacity(0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ), // Gradiente lineare
            borderRadius: BorderRadius.circular(26.0),
            border: Border.all(
              color: Colors.black.withOpacity(0.3), // Bordo semi-trasparente
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
            child: child,
          ),
        ),
      ),
    );
  }
}
