import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:tunetadka/pages/login_page.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.music.mp3_player.channel.audio',
    androidNotificationChannelName: 'Audio Playback',
    androidNotificationOngoing: true,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "TuneTadka",
      theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Color(0xFF2E6FF3),
          scaffoldBackgroundColor: Colors.white,
          cardColor: Color(0xFFF6F6F6),
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: Colors.black),
            bodyMedium: TextStyle(color: Colors.black87),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Color(0xFFF6F6F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: Color(0xFF2E6FF3),
            unselectedItemColor: Colors.grey,
          ),
          iconTheme: IconThemeData(color: Colors.black),
          useMaterial3: true),
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Color(0xFF2E6FF3),
          scaffoldBackgroundColor: Color(0xFF121212),
          cardColor: Color(0xFF2B3037),
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white70),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Color(0xFF2B3037),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade700),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade700),
            ),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF121212),
            selectedItemColor: Color(0xFF2E6FF3),
            unselectedItemColor: Colors.grey,
          ),
          iconTheme: IconThemeData(color: Colors.white),
          useMaterial3: true),
      themeMode: ThemeMode.system,
      home: const LoginPage(),
    );
  }
}
