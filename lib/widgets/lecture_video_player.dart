import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../models/lecture.dart';

class LectureVideoPlayer extends StatefulWidget {
  final Lecture lecture;

  const LectureVideoPlayer({super.key, required this.lecture});

  @override
  State<LectureVideoPlayer> createState() => _LectureVideoPlayerState();
}

class _LectureVideoPlayerState extends State<LectureVideoPlayer> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  @override
  void didUpdateWidget(LectureVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lecture.id != widget.lecture.id) {
      _dispose();
      _initPlayer();
    }
  }

  Future<void> _initPlayer() async {
    if (widget.lecture.videoUrl.isEmpty) {
      setState(() => _hasError = true);
      return;
    }

    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.lecture.videoUrl),
      );
      await _videoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: false,
        aspectRatio: 16 / 9,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        placeholder: _buildPlaceholder(),
      );

      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  void _dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    _chewieController = null;
    _videoController = null;
    _hasError = false;
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: const Color(0xFF0F172A),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white60, size: 48),
              const SizedBox(height: 8),
              const Text(
                '動画を読み込めませんでした',
                style: TextStyle(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                widget.lecture.videoUrl.isEmpty ? 'URLが設定されていません' : widget.lecture.videoUrl,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_chewieController == null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Chewie(controller: _chewieController!),
    );
  }
}