import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:window_manager/window_manager.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String title;
  final String videoUrl;
  final String quality;

  const VideoPlayerScreen({
    super.key,
    required this.title,
    required this.videoUrl,
    required this.quality,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final Player _player;
  late final VideoController _controller;
  bool _isControlsVisible = true;
  bool _isPlaying = false;
  bool _isBuffering = false;
  bool _isFullScreen = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _volume = 1.0;
  double _playbackSpeed = 1.0;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _startHideTimer();
  }

  void _initializePlayer() {
    _player = Player();
    _controller = VideoController(_player);

    _player.stream.playing.listen((playing) {
      if (mounted) {
        setState(() => _isPlaying = playing);
      }
    });

    _player.stream.buffering.listen((buffering) {
      if (mounted) {
        setState(() => _isBuffering = buffering);
      }
    });

    _player.stream.duration.listen((duration) {
      if (mounted) {
        setState(() => _duration = duration);
      }
    });

    _player.stream.position.listen((position) {
      if (mounted) {
        setState(() => _position = position);
      }
    });

    _player.stream.volume.listen((volume) {
      if (mounted) {
        setState(() => _volume = volume / 100);
      }
    });

    _player.open(Media(widget.videoUrl));
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _player.dispose();
    if (_isFullScreen) {
      _exitFullScreen();
    }
    super.dispose();
  }

  Future<void> _enterFullScreen() async {
    try {
      await windowManager.setFullScreen(true);
      setState(() => _isFullScreen = true);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } catch (e) {
      debugPrint('Error entering fullscreen: $e');
    }
  }

  Future<void> _exitFullScreen() async {
    try {
      await windowManager.setFullScreen(false);
      setState(() => _isFullScreen = false);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } catch (e) {
      debugPrint('Error exiting fullscreen: $e');
    }
  }

  void _togglePlayPause() {
    _player.playOrPause();
    _showControlsTemporarily();
  }

  void _seek(Duration position) {
    _player.seek(position);
  }

  void _seekRelative(Duration offset) {
    final newPosition = _position + offset;
    if (newPosition >= Duration.zero && newPosition <= _duration) {
      _seek(newPosition);
    }
  }

  void _setVolume(double volume) {
    _player.setVolume(volume * 100);
  }

  void _setPlaybackSpeed(double speed) {
    _player.setRate(speed);
    setState(() => _playbackSpeed = speed);
    Navigator.pop(context);
  }

  void _toggleControls() {
    setState(() => _isControlsVisible = !_isControlsVisible);
    if (_isControlsVisible) {
      _startHideTimer();
    } else {
      _hideTimer?.cancel();
    }
  }

  void _showControlsTemporarily() {
    setState(() => _isControlsVisible = true);
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (_isPlaying && mounted) {
        setState(() => _isControlsVisible = false);
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Video(
              controller: _controller,
              controls: NoVideoControls,
            ),
          ),
          if (_isBuffering)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          GestureDetector(
            onTap: _toggleControls,
            onDoubleTapDown: (details) {
              final width = MediaQuery.of(context).size.width;
              if (details.localPosition.dx < width / 2) {
                _seekRelative(const Duration(seconds: -10));
              } else {
                _seekRelative(const Duration(seconds: 10));
              }
              _showControlsTemporarily();
            },
            behavior: HitTestBehavior.translucent,
            child: Container(color: Colors.transparent),
          ),
          if (_isControlsVisible)
            AnimatedOpacity(
              opacity: _isControlsVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.9),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.95),
                    ],
                    stops: const [0.0, 0.2, 0.8, 1.0],
                  ),
                ),
                child: Column(
                  children: [
                    _buildTopControls(),
                    const Spacer(),
                    _buildCenterControls(),
                    const Spacer(),
                    _buildBottomControls(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopControls() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            _buildIconButton(
              icon: Icons.arrow_back,
              onPressed: () async {
                if (_isFullScreen) {
                  await _exitFullScreen();
                } else {
                  Navigator.pop(context);
                }
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.quality,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            _buildIconButton(
              icon: Icons.speed,
              onPressed: () => _showSpeedMenu(),
            ),
            const SizedBox(width: 8),
            _buildIconButton(
              icon: _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
              onPressed: () async {
                if (_isFullScreen) {
                  await _exitFullScreen();
                } else {
                  await _enterFullScreen();
                }
                _showControlsTemporarily();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 24),
        onPressed: onPressed,
      ),
    );
  }

  void _showSpeedMenu() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Playback Speed',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ...[0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
                return _buildSpeedOption(speed);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedOption(double speed) {
    final isSelected = _playbackSpeed == speed;
    return InkWell(
      onTap: () => _setPlaybackSpeed(speed),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${speed}x',
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, color: Colors.black, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCenterButton(
          icon: Icons.replay_10,
          onPressed: () {
            _seekRelative(const Duration(seconds: -10));
            _showControlsTemporarily();
          },
        ),
        const SizedBox(width: 60),
        _buildCenterButton(
          icon: _isPlaying ? Icons.pause : Icons.play_arrow,
          onPressed: _togglePlayPause,
          size: 80,
        ),
        const SizedBox(width: 60),
        _buildCenterButton(
          icon: Icons.forward_10,
          onPressed: () {
            _seekRelative(const Duration(seconds: 10));
            _showControlsTemporarily();
          },
        ),
      ],
    );
  }

  Widget _buildCenterButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 60,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        iconSize: size,
        onPressed: onPressed,
        padding: EdgeInsets.all(size * 0.25),
      ),
    );
  }

  Widget _buildBottomControls() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  _formatDuration(_position),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                      thumbColor: Colors.white,
                      overlayColor: Colors.white.withValues(alpha: 0.2),
                    ),
                    child: Slider(
                      value: _duration.inMilliseconds > 0
                          ? _position.inMilliseconds.toDouble()
                          : 0,
                      min: 0,
                      max: _duration.inMilliseconds.toDouble(),
                      onChanged: (value) {
                        _seek(Duration(milliseconds: value.toInt()));
                        _showControlsTemporarily();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  _formatDuration(_duration),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    _volume > 0.5 ? Icons.volume_up : _volume > 0 ? Icons.volume_down : Icons.volume_off,
                    color: Colors.white,
                  ),
                  onPressed: () => _setVolume(_volume > 0 ? 0 : 1),
                ),
                SizedBox(
                  width: 100,
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                      thumbColor: Colors.white,
                    ),
                    child: Slider(
                      value: _volume,
                      onChanged: _setVolume,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_playbackSpeed}x',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
