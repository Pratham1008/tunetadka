import 'package:flutter/material.dart';
import 'package:tunetadka/pages/home_page.dart';
import 'package:tunetadka/pages/upload_track_page.dart';

import 'favorite_page.dart';
import 'history_page.dart';

class MainPage extends StatefulWidget {
  final String userEmail;
  const MainPage({super.key, required this.userEmail});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  static const allowedUploaders = {
    "prathamesh10082004@gmail.com",
    "prathameshcorporations@gmail.com",
    "prathamesh16052003@gmail.com",
  };

  @override
  Widget build(BuildContext context) {
    final canUpload = allowedUploaders.contains(widget.userEmail.toLowerCase());

    final tabs = [
      HomePage(userEmail: widget.userEmail),
      FavoritesPage(userEmail: widget.userEmail),
      HistoryPage(userEmail: widget.userEmail),
      if (canUpload) UploadTrackPage(userEmail: widget.userEmail),
    ];

    final items = [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      const BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorites"),
      const BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
      if (canUpload) const BottomNavigationBarItem(icon: Icon(Icons.upload_file), label: "Upload"),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E1E2E),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: items,
      ),
    );
  }
}

