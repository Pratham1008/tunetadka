import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../model/models.dart';
import '../services/track_services.dart';
import '../widgets/mini_player.dart';
import '../widgets/skeletoncard.dart';
import '../widgets/trackcard.dart';
import '../services/audio_manager.dart';

class HistoryPage extends StatefulWidget {
  final String userEmail;
  const HistoryPage({super.key, required this.userEmail});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final audioManager = AudioManager();

  List<History> histories = [];
  List<Track> historyTracks = [];
  List<Favorite> favorite = [];
  bool loading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    loadHistoryTracks();
    loadFavoriteTracks();
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

  Future<void> loadHistoryTracks() async {
    try {
      final fetchedHistories = await TrackService.getHistory(widget.userEmail);
      final tracks = await Future.wait(
        fetchedHistories.map((h) => TrackService.getTrack(h.trackId)),
      );

      setState(() {
        histories = fetchedHistories;
        historyTracks = tracks;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load history tracks\n$e';
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
        title: const Text("History"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 90),
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
                : RefreshIndicator(
              onRefresh: loadHistoryTracks,
              child: AnimationLimiter(
                child: ListView.builder(
                  itemCount: historyTracks.length,
                  padding: const EdgeInsets.only(bottom: 100),
                  itemBuilder: (context, index) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 500),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: TrackCard(
                            tracks: historyTracks,
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

          Align(
            alignment: Alignment.bottomCenter,
            child: MiniPlayer(userEmail: widget.userEmail),
          ),
        ],
      ),
    );
  }
}
