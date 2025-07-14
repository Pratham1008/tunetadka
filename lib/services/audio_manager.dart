import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';

import '../model/models.dart';

class AudioManager extends ChangeNotifier {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;

  AudioManager._internal() {
    _init();
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  final ValueNotifier<Track?> currentTrackNotifier = ValueNotifier(null);
  List<Track> _playlist = [];
  int _currentIndex = 0;
  String? _userEmail;

  List<Track> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  Track? get currentTrack => (_playlist.isNotEmpty) ? _playlist[_currentIndex] : null;
  AudioPlayer get audioPlayer => _audioPlayer;
  bool get isPlaying => _audioPlayer.playing;
  Duration get position => _audioPlayer.position;
  Duration get duration => _audioPlayer.duration ?? Duration.zero;

  Future<void> _init() async {

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());


    _audioPlayer.playerStateStream.listen((playerState) {
      notifyListeners();
    });


    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null && index < _playlist.length) {
        _currentIndex = index;
        currentTrackNotifier.value = _playlist[index];
        notifyListeners();
      }
    });
  }

  Future<void> init(List<Track> tracks, int index, String userEmail) async {
    _playlist = tracks;
    _currentIndex = index;
    _userEmail = userEmail;
    currentTrackNotifier.value = _playlist[index];

    await _loadTracks();
  }

  Future<void> _loadTracks() async {
    final sources = _playlist.map((track) {
      final url = 'https://mp3-backend-ut8t.onrender.com/api/tracks/audio?trackId=${track.id}&email=${Uri.encodeComponent(_userEmail!)}';

      return AudioSource.uri(
        Uri.parse(url),
        tag: MediaItem(
          id: track.id,
          album: track.album,
          title: track.title,
          artist: track.artist,
          artUri: Uri.parse('https://mp3-backend-ut8t.onrender.com/api/tracks/${track.id}/cover'),
        ),
      );
    }).toList();

    await _audioPlayer.setAudioSource(
      ConcatenatingAudioSource(children: sources),
      initialIndex: _currentIndex,
    );

    await _audioPlayer.setLoopMode(LoopMode.off);
  }

  void play() => _audioPlayer.play();
  void pause() => _audioPlayer.pause();

  void seek(Duration position) => _audioPlayer.seek(position);

  Future<void> playNext() async {
    if (_currentIndex < _playlist.length - 1) {
      _currentIndex++;
      await _audioPlayer.seekToNext();
      play();
    }
  }

  Future<void> playPrevious() async {
    if (_currentIndex > 0) {
      _currentIndex--;
      await _audioPlayer.seekToPrevious();
      play();
    }
  }

  void disposePlayer() {
    _audioPlayer.dispose();
  }
}
