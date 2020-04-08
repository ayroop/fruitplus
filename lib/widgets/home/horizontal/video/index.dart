import 'package:flutter/material.dart';
import 'player_video.dart';

class VideoLayout extends StatelessWidget {
  final config;

  VideoLayout({this.config});

  @override
  Widget build(BuildContext context) {
    if ((config['url'] as String).lastIndexOf('youtu') == -1) {
      return PlayerVideo(
        config: config,
      );
    }
    return null;
  }
}
