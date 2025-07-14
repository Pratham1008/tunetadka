import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:tunetadka/services/audio_manager.dart';
import '../model/models.dart';
import '../services/track_services.dart';
import '../widgets/mini_player.dart';
import '../widgets/skeletoncard.dart';
import '../widgets/trackcard.dart';

class HomePage extends StatefulWidget {
  final String userEmail;
  const HomePage({super.key, required this.userEmail});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final audioManager = AudioManager();
  List<Track> tracks = [];
  List<Favorite> favorite = [];
  bool loading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchTracks();
    loadFavoriteTracks();
  }

  Future<void> fetchTracks() async {
    try {
      final result = await TrackService.getAllTracks();
      setState(() {
        tracks = result;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load tracks';
        loading = false;
      });
    }
  }

  Future<void> loadFavoriteTracks() async {
    try {
      final favorites = await TrackService.getFavorites(widget.userEmail);

      setState(() {
        favorite = favorites;
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
        SnackBar(content: Text('Added to favorites')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add favorite')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/icon/music.png', width: 28, height: 28),
            const SizedBox(width: 8),
            const Text(
              "TuneTadka",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          loading
              ? ListView.builder(
            itemCount: 5,
            itemBuilder: (_, i) => const Padding(
              padding: EdgeInsets.all(12.0),
              child: SkeletonCard(),
            ),
          )
              : error.isNotEmpty
              ? Center(
              child: Text(error,
                  style: const TextStyle(color: Colors.redAccent)))
              : RefreshIndicator(
            onRefresh: fetchTracks,
            child: ValueListenableBuilder<Track?>(
              valueListenable: AudioManager().currentTrackNotifier,
              builder: (context, currentTrack, _) {
                return AnimationLimiter(
                  child: ListView.builder(
                    itemCount: tracks.length,
                    padding: const EdgeInsets.only(bottom: 100),
                    itemBuilder: (context, index) {
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 500),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: TrackCard(
                              tracks: tracks,
                              userEmail: widget.userEmail,
                              onFavorite: handleAddFavorite,
                              initialIndex: index, favorites: favorite,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: MiniPlayer(userEmail: widget.userEmail),
          ),
        ],
      ),
    );
  }

}
