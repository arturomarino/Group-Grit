import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:group_grit/pages/VideoUploadSystem/VideoPlayerWidget.dart';
import 'package:group_grit/pages/VideoUploadSystem/WatchVideoPage.dart';
import 'package:group_grit/utils/constants/colors.dart';
import 'package:group_grit/utils/constants/size.dart';
import 'package:video_player/video_player.dart';

class ShowVideoPage extends StatefulWidget {
  final Uri videoUrl;

  ShowVideoPage({required this.videoUrl});

  @override
  _ShowVideoPageState createState() => _ShowVideoPageState();
}

class _ShowVideoPageState extends State<ShowVideoPage> {
  VideoPlayerController? controller;

  // Uri path = Uri.parse('https://vod.api.video/vod/vi4cOevqSzQvlQjWWG2CIt2z/mp4/source.mp4');





  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.networkUrl(widget.videoUrl)
      ..addListener(() => setState(() {}))
      ..setLooping(false)
      ..initialize().then((_) {
        controller!.play();
      });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.transparent,
          actionsPadding: EdgeInsets.only(right: 15),
          actions: [
            CupertinoButton(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black54,
                ),
                padding: EdgeInsets.all(8),
                child: Icon(
                  controller!.value.volume > 0 ? Icons.volume_up : Icons.volume_off,
                  color: Colors.white,
                  size: 23,
                ),
              ),
              onPressed: () {
                controller!.setVolume(controller!.value.volume > 0 ? 0 : 1);
              },
              padding: EdgeInsets.zero,
            ),
            CupertinoButton(
                onPressed: () {
                  // Add functionality to speed up video playback
                  if (controller != null && controller!.value.isInitialized) {
                    final currentSpeed = controller!.value.playbackSpeed;
                    final newSpeed = currentSpeed == 1.0
                        ? 1.5
                        : currentSpeed == 1.5
                            ? 2.0
                            : currentSpeed == 2.0
                                ? 5.0
                                : 1.0;
                    controller!.setPlaybackSpeed(newSpeed);
                  }
                },
                padding: EdgeInsets.zero,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black54,
                  ),
                  padding: EdgeInsets.all(8),
                  child: Text(
                    "${controller!.value.playbackSpeed}x",
                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                )),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Space for the AppBar
            if (controller != null)
              Column(
                children: [
                  if (controller != null)
                    Container(
                        child: controller != null && controller!.value.isInitialized
                            ? BasicOverlayWidgetWatch(controller: controller!)
                            : FutureBuilder(
                              future: Future.delayed(Duration(seconds: 1)),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                return Container();
                                } else {
                                return Center(
                                  child: Column(
                                  children: [
                                    Container(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                    ),
                                    SizedBox(height: 20),
                                    Container(
                                    width: GGSize.screenWidth(context) * 0.6,
                                    child: Text(
                                      'The video is being processed, come back in a few minutes',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    ),
                                  ],
                                  ),
                                );
                                }
                              },
                              ))
                  else
                    Center(
                        child: Container(
                      height: 40,
                      width: 40,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ))
                ],
              ),
          ],
        ));
  }
}
