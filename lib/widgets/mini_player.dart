import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tunetadka/widgets/visualizerbar.dart';
import 'dart:math';
import '../services/audio_manager.dart';
import '../pages/player_screen.dart';

class MiniPlayer extends StatefulWidget {
  final String userEmail;

  const MiniPlayer({super.key, required this.userEmail});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> with SingleTickerProviderStateMixin {
  final audioManager = AudioManager();
  late AnimationController _controller;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..repeat();

    audioManager.audioPlayer.playerStateStream.listen((state) {
      if (state.playing) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
      setState(() {});
    });

    // Listen to position and duration updates
    audioManager.audioPlayer.positionStream.listen((pos) {
      setState(() {
        _position = pos;
      });
    });

    audioManager.audioPlayer.durationStream.listen((dur) {
      setState(() {
        _duration = dur ?? Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  Widget _buildVisualizerBar(double height) {
    return Container(
      width: 3,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      decoration: BoxDecoration(
        color: Colors.greenAccent,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final track = audioManager.currentTrack;
    if (track == null) return const SizedBox.shrink();

    // Progress as fraction for Slider
    final progress = (_duration.inMilliseconds == 0)
        ? 0.0
        : _position.inMilliseconds / _duration.inMilliseconds;

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => PlayerScreen(
            tracks: audioManager.playlist,
            initialIndex: audioManager.currentIndex,
            userEmail: widget.userEmail,
          ),
        ));
      },
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress bar
            Slider(
              value: progress.clamp(0.0, 1.0),
              onChanged: (value) {
                final newPos = _duration * value;
                audioManager.seek(newPos);
              },
              activeColor: Colors.greenAccent,
              inactiveColor: Colors.white24,
            ),

            // Main controls row
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: 'https://mp3-backend-ut8t.onrender.com/api/tracks/${track.id}/cover',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    track.title,
                    style: const TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),

                // Prev button
                IconButton(
                  icon: const Icon(Icons.skip_previous, color: Colors.white),
                  onPressed: () {
                    audioManager.playPrevious();
                  },
                ),

                // Play/pause button
                IconButton(
                  icon: Icon(
                    audioManager.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    audioManager.isPlaying ? audioManager.pause() : audioManager.play();
                  },
                ),

                // Next button
                IconButton(
                  icon: const Icon(Icons.skip_next, color: Colors.white),
                  onPressed: () {
                    audioManager.playNext();
                  },
                ),

                const SizedBox(width: 8),

                if (audioManager.isPlaying)
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (_, __) {
                      final rand = Random();
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          VisualizerBars(
                            barCount: 5,
                            maxHeight: 40,
                            color: Colors.redAccent,
                            animate: true,
                          )
                        ]
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
