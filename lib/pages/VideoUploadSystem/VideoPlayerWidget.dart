import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:group_grit/utils/constants/size.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatelessWidget {
  final VideoPlayerController controller;

  const VideoPlayerWidget({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return controller.value.isInitialized
        ? Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: buildVideo(),
            ),
          )
        : Container(
            height: GGSize.screenHeight(context) * 0.2,
            child: CircularProgressIndicator(),
          );
  }

  Widget buildVideo() => buildVideoPlayer();

  Widget buildVideoPlayer() => Container(
    child: AspectRatio(aspectRatio: controller.value.aspectRatio, child: VideoPlayer(controller)));
}

class BasicOverlayWidget extends StatelessWidget {
  final VideoPlayerController controller;

  BasicOverlayWidget({required this.controller});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => controller.value.isPlaying ? controller.pause() : controller.play(),
        child: Container(
          child: Center(
            child: Stack(
              children: <Widget>[
                Center(child: VideoPlayerWidget(controller: controller)),
                Positioned.fill(
                  child: buildPlay(),
                ),
                //buildProgressIndicator(context)
                ],
            ),
          ),
        ),
      );

  Widget buildPlay() => controller.value.isPlaying
      ? Container()
      : Center(
          child: Container(
        color: Colors.transparent,
        child: Icon(FontAwesomeIcons.play, color: Colors.white, size: 40),
          ),
        );
  Widget buildProgressIndicator(BuildContext context) => Align(
        alignment: Alignment.bottomCenter,
        child: VideoProgressIndicator(
          colors: VideoProgressColors(playedColor: Colors.black.withOpacity(0.7), bufferedColor: Colors.white.withOpacity(0.5), backgroundColor: Colors.white.withOpacity(0.25)),
          controller,
          allowScrubbing: true,
          padding: EdgeInsets.only(left:GGSize.screenWidth(context)*0.21, right: GGSize.screenWidth(context)*0.21,bottom: GGSize.screenHeight(context)*0.00009),
        ),
      );
}
