import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../model/models.dart';
import '../services/audio_manager.dart';

class PlayerScreen extends StatefulWidget {
  final List<Track> tracks;
  final int initialIndex;
  final String userEmail;

  const PlayerScreen({
    super.key,
    required this.tracks,
    required this.initialIndex,
    required this.userEmail,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with TickerProviderStateMixin {
  final audioManager = AudioManager();
  late PageController _pageController;
  late AnimationController _rotationController;
  late AnimationController _blurPulseController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.initialIndex,
      viewportFraction: 0.7,
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _blurPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    audioManager.audioPlayer.playerStateStream.listen((state) {
      if (state.playing) {
        _rotationController.repeat();
        _blurPulseController.repeat(reverse: true);
      } else {
        _rotationController.stop();
        _blurPulseController.stop();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _blurPulseController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (index != audioManager.currentIndex) {
      audioManager.init(audioManager.playlist, index, widget.userEmail);
      setState(() {});
    }
  }

  String formatTime(Duration d) {
    return d.toString().split('.').first.padLeft(8, "0").substring(3);
  }

  @override
  Widget build(BuildContext context) {
    final currentTrack = audioManager.currentTrack;
    if (currentTrack == null) return const SizedBox();

    return Scaffold(
      backgroundColor: const Color(0xFF0C0B20),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF0C0B20),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 320,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: _onPageChanged,
                        itemCount: audioManager.playlist.length,
                        itemBuilder: (context, index) {
                          final track = audioManager.playlist[index];
                          final imageUrl =
                              'https://mp3-backend-ut8t.onrender.com/api/tracks/${track.id}/cover';
                          final isCurrent = index == audioManager.currentIndex;

                          return AnimatedScale(
                            scale: isCurrent ? 1.0 : 0.9,
                            duration: const Duration(milliseconds: 300),
                            child: Opacity(
                              opacity: isCurrent ? 1 : 0.6,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  width: 300,
                                  height: 300,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    width: 300,
                                    height: 300,
                                    color: Colors.grey[900],
                                    child: const Icon(
                                      Icons.music_note,
                                      color: Colors.grey,
                                      size: 60,
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    width: 300,
                                    height: 300,
                                    color: Colors.grey[900],
                                    child: const Icon(
                                      Icons.music_off,
                                      color: Colors.grey,
                                      size: 60,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      currentTrack.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentTrack.artist,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Progress slider with StreamBuilder
                    StreamBuilder<Duration>(
                      stream: audioManager.audioPlayer.positionStream,
                      builder: (context, snapshot) {
                        final position = snapshot.data ?? Duration.zero;
                        final duration = audioManager.audioPlayer.duration ?? Duration.zero;
                        final max = duration.inSeconds > 0 ? duration.inSeconds.toDouble() : 1.0;
                        final value = position.inSeconds.toDouble().clamp(0, max);

                        return Column(
                          children: [
                            Slider(
                              value: value.floorToDouble(),
                              max: max,
                              onChanged: (val) => audioManager.seek(Duration(seconds: val.toInt())),
                              activeColor: Colors.white,
                              inactiveColor: Colors.white30,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formatTime(position),
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  Text(
                                    formatTime(duration),
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.skip_previous,
                            size: 40,
                            color: Colors.white,
                          ),
                          onPressed: () => audioManager.playPrevious(),
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          icon: Icon(
                            audioManager.isPlaying
                                ? Icons.pause_circle
                                : Icons.play_circle,
                            size: 72,
                            color: Colors.white,
                          ),
                          onPressed: () => audioManager.isPlaying
                              ? audioManager.pause()
                              : audioManager.play(),
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          icon: const Icon(
                            Icons.skip_next,
                            size: 40,
                            color: Colors.white,
                          ),
                          onPressed: () => audioManager.playNext(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
