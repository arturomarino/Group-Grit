import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:group_grit/utils/constants/colors.dart';
import 'package:group_grit/utils/constants/size.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidgetWatch extends StatelessWidget {
  final VideoPlayerController controller;

  const VideoPlayerWidgetWatch({Key? key, required this.controller}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return controller.value.isInitialized
        ? Container(
            height: GGSize.screenHeight(context),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: buildVideo(),
            ),
          )
        : Center(
          child: Container(
              height: GGSize.screenHeight(context),
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
        );
  }

  Widget buildVideo() => buildVideoPlayer();

  Widget buildVideoPlayer() => Container(child: AspectRatio(aspectRatio: controller.value.aspectRatio, child: VideoPlayer(controller)));
}

class BasicOverlayWidgetWatch extends StatelessWidget {
  final VideoPlayerController controller;

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }

  BasicOverlayWidgetWatch({required this.controller});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => controller.value.isPlaying ? controller.pause() : controller.play(),
        child: Container(
          child: Center(
            child: Stack(
              children: <Widget>[
                Center(child: VideoPlayerWidgetWatch(controller: controller)),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: kToolbarHeight * 2.6), // Space for the AppBar
                    buildProgressIndicator(context),
                  ],
                ),
                Positioned.fill(child: buildPlay()),
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
  Widget buildProgressIndicator(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(horizontal:  GGSize.screenWidth(context) * 0.10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.black.withOpacity(0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Text(
                    formatDuration(controller.value.position),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: VideoProgressIndicator(
                      colors: VideoProgressColors(
                          playedColor: Colors.white, bufferedColor: Colors.white.withOpacity(0.5), backgroundColor: Colors.white.withOpacity(0.25)),
                      controller,
                      allowScrubbing: true,
                      padding: EdgeInsets.only(bottom: 0.0009),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    formatDuration(controller.value.duration),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
