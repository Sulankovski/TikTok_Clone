import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerItem extends StatefulWidget {
  final String videoURL;

  const VideoPlayerItem({
    super.key,
    required this.videoURL,
  });

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController videoController;
  bool isPlaying = true;

  @override
  void initState() {
    super.initState();
    videoController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoURL))
          ..initialize().then((value) {
            videoController.play();
            videoController.setVolume(1);
          });

    videoController.addListener(() {
      if (videoController.value.position == videoController.value.duration) {
        // Seek the video back to the beginning to make it repeat
        videoController.seekTo(Duration.zero);
        videoController.play();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    videoController.dataSource;
  }

  void togglePlayPause() {
    if (isPlaying) {
      videoController.pause();
    } else {
      videoController.play();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height,
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: GestureDetector(
        onTap: togglePlayPause,
        child: VideoPlayer(videoController),
      ),
    );
  }
}
