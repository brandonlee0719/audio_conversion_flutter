import 'package:audio_conversion/video_stream_controller.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Conversion Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Audio Conversion Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void dispose() {

    VideoStreamController().dispose();
    super.dispose();
  }

  VideoStreamController streamController = VideoStreamController();
  int timer = 0;
  bool streamActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            !streamActive ? TextButton(
              child: const Text('Share Tab'),
              onPressed: () {
                streamController.shareTab();
                streamController.streamActive.addListener(() {
                  setState(() {
                    streamActive = streamController.streamActive.value;
                    print('streamActive: $streamActive');
                  });
                });
              },
            ) : Container(),
            streamActive ? TextButton(
              child: const Text('Save Audio Chunk'),
              onPressed: () {
                streamController.saveAudioChunk();
                streamController.timer.addListener(() {
                  setState(() {
                    timer = streamController.timer.value;
                  });
                });
              },
            ) : Container(),
            Text('Time Elapsed: $timer'),
          ],
        ),
      ),
    );
  }
}
