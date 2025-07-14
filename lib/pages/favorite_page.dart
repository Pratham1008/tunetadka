import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../model/models.dart';
import '../services/track_services.dart';
import '../widgets/mini_player.dart';
import '../widgets/skeletoncard.dart';
import '../widgets/trackcard.dart';
import '../services/audio_manager.dart';

class FavoritesPage extends StatefulWidget {
  final String userEmail;
  const FavoritesPage({super.key, required this.userEmail});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final audioManager = AudioManager();
  List<Track> favoriteTracks = [];
  List<Favorite> favorite = [];
  bool loading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    loadFavoriteTracks();
  }

  Future<void> loadFavoriteTracks() async {
    try {
      final favorites = await TrackService.getFavorites(widget.userEmail);
      final tracks = await Future.wait(
        favorites.map((fav) => TrackService.getTrack(fav.trackId)),
      );

      setState(() {
        favorite = favorites;
        favoriteTracks = tracks;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load favorite tracks\n$e';
        loading = false;
      });
    }
  }

  void handleAddFavorite(String trackId) async {
    try {
      await TrackService.addToFavorites(trackId, widget.userEmail);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to favorites')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add favorite')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Favorites"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Main list content with padding at bottom for MiniPlayer space
          Padding(
            padding: const EdgeInsets.only(bottom: 90), // Leave space for MiniPlayer
            child: loading
                ? ListView.builder(
              itemCount: 5,
              itemBuilder: (_, i) => const Padding(
                padding: EdgeInsets.all(12.0),
                child: SkeletonCard(),
              ),
            )
                : error.isNotEmpty
                ? Center(
              child: Text(
                error,
                style: const TextStyle(color: Colors.redAccent),
              ),
            )
                : favoriteTracks.isEmpty
                ? const Center(
              child: Text("No favorite tracks yet.",
                  style: TextStyle(color: Colors.white70)),
            )
                : RefreshIndicator(
              onRefresh: loadFavoriteTracks,
              child: AnimationLimiter(
                child: ListView.builder(
                  itemCount: favoriteTracks.length,
                  padding: const EdgeInsets.only(bottom: 100),
                  itemBuilder: (context, index) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 500),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: TrackCard(
                            tracks: favoriteTracks,
                            userEmail: widget.userEmail,
                            onFavorite: handleAddFavorite,
                            initialIndex: index, favorites: favorite,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Persistent MiniPlayer aligned bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: MiniPlayer(userEmail: widget.userEmail),
          ),
        ],
      ),
    );
  }
}
