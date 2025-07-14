import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:marquee/marquee.dart';
import 'package:tunetadka/widgets/visualizerbar.dart';
import '../model/models.dart';
import '../services/audio_manager.dart';

class TrackCard extends StatelessWidget {
  final List<Track> tracks;
  final int initialIndex;
  final String userEmail;
  final Function(String) onFavorite;
  final List<Favorite> favorites;

  const TrackCard({
    super.key,
    required this.tracks,
    required this.userEmail,
    required this.onFavorite,
    required this.initialIndex, required this.favorites,
  });

  @override
  Widget build(BuildContext context) {
    final track = tracks[initialIndex];
    final audioManager = AudioManager();
    final isPlaying = track.id == audioManager.currentTrack?.id;
    final isFavorite = favorites.any((fav) => fav.trackId == track.id);

    return GestureDetector(
      onTap: () {
        audioManager.init(tracks, initialIndex, userEmail);
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 75),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Album Art
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: 'https://mp3-backend-ut8t.onrender.com/api/tracks/${track.id}/cover',
                width: 55,
                height: 55,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 55,
                  height: 55,
                  color: Colors.grey[800],
                  child: const Icon(Icons.music_note, color: Colors.grey),
                ),
                errorWidget: (_, __, ___) => const Icon(Icons.music_off, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 14),

            // Title & Artist expanded area
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                    child: isPlaying
                        ? Marquee(
                      text: track.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      velocity: 25,
                      blankSpace: 50,
                      pauseAfterRound: const Duration(seconds: 1),
                    )
                        : Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 18,
                    child: isPlaying
                        ? Marquee(
                      text: track.artist,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12.5,
                      ),
                      velocity: 10,
                      blankSpace: 20,
                      pauseAfterRound: const Duration(seconds: 1),
                    )
                        : Text(
                      track.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Animated visual bar if playing
            if (isPlaying)
              Container(
                margin: const EdgeInsets.only(left: 12),
                alignment: Alignment.bottomCenter,
                height: 40,
                child: const VisualizerBars(
                  barCount: 3,
                  maxHeight: 30,
                  color: Colors.lightGreenAccent,
                  animate: true,
                ),
              ),

            // Favorite button
            IconButton(
              onPressed: () {
                onFavorite(track.id);
              },
              icon: isFavorite ? Icon(
                Icons.favorite,
                color: Colors.redAccent,
              ) : Icon(
                Icons.favorite_outline_outlined,
                color: Colors.white70,
              ),
              splashRadius: 20,
              tooltip: 'Add to Favorites',
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 300.ms)
          .moveY(begin: 10, duration: 300.ms, curve: Curves.easeOut),
    );
  }
}
