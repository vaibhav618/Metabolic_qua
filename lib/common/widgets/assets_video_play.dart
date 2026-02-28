import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AssetVideoWidget extends StatefulWidget {
  final String videoPath;
  final String thumbnailPath;
  final bool autoPlay;
  final bool looping;

  const AssetVideoWidget({
    super.key,
    required this.videoPath,
    this.autoPlay = true,
    this.looping = true,
    required this.thumbnailPath,
  });

  @override
  State<AssetVideoWidget> createState() => _AssetVideoWidgetState();
}

class _AssetVideoWidgetState extends State<AssetVideoWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        if (!mounted) return;
        if (widget.looping) _controller.setLooping(true);
        if (widget.autoPlay) _controller.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {


      return ClipRect(
        child: Align(
          alignment: Alignment.center,
          heightFactor: 0.91, // crops a bit vertically (adjust 0.98~0.995)
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: Image.asset(widget.thumbnailPath,),
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {


        return ClipRect(
          child: Align(
            alignment: Alignment.center,
            heightFactor: 0.98, // crops a bit vertically (adjust 0.98~0.995)
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          ),
        );

      },
    );
  }
}
