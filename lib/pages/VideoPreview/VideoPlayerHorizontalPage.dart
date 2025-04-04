import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:group_grit/utils/constants/size.dart';
import 'package:rxdart/rxdart.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerHorizontalPage extends StatefulWidget {
  final String videoUrl;
  final String imageUrl;
  final VideoPlayerController? controller;
  const VideoPlayerHorizontalPage({Key? key, required this.videoUrl, required this.imageUrl, required this.controller}) : super(key: key);

  @override
  State<VideoPlayerHorizontalPage> createState() => _VideoPlayerHorizontalPageState();
}

class _VideoPlayerHorizontalPageState extends State<VideoPlayerHorizontalPage> {

  bool _isInitialized = false;
  bool _loadingPlay = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Hero(
                tag: "videoHero",
                child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (widget.controller!.value.isPlaying) {
                              widget.controller!.pause();
                            } else {
                              widget.controller!.play();
                            }
                          });
                        },
                        child: SizedBox(
                          width: GGSize.screenWidth(context),
                          child: Stack(
                            children: [
                              AspectRatio(aspectRatio: 1920 / 1080, child: VideoPlayer(widget.controller!)),
                              Visibility(
                                visible: !widget.controller!.value.isPlaying,
                                child: Positioned.fill(
                                  child: Container(
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: buildPlay(),
                              ),
                              Positioned(
                                bottom: 3,
                                left: 10,
                                right: 10,
                                child: buildProgressIndicatorBar(context),
                              ),
                              Positioned(
                                top: 0,
                                left: 5,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 35,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ),
      ),
    );
  }

    Widget buildPlay() => widget.controller!.value.isPlaying
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
                  stream: widget.controller!.position.asStream().whereType<Duration>(),
                  builder: (context, snapshot) {
                    return ValueListenableBuilder(
                      valueListenable: widget.controller!,
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
                              widget.controller!.seekTo(
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
          CupertinoButton(onPressed: () {
            Navigator.pop(context);
          //  Navigator.pushNamed(context, '/VideoPlayerHorizontalPage', arguments: {widget.videoUrl, widget.imageUrl});
          }, padding: EdgeInsets.zero, child: Icon(Icons.fullscreen, color: Colors.white, size: 30)),
        ],
      );
}