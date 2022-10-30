import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:js' as js;

import 'package:audio_conversion/tab_sharing_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'package:http/http.dart' as http;


class VideoStreamController {
  RTCVideoRenderer localRenderer = RTCVideoRenderer();
  MediaRecorder _mediaRecorder = MediaRecorder();
  TabSharingInterface signaling = TabSharingInterface();
  ValueNotifier<int> timer = ValueNotifier(0);
  ValueNotifier<bool> streamActive = ValueNotifier(false);
  Timer? _timer;

  void dispose() {
    streamActive.dispose();
    timer.dispose();
    signaling.localStream.dispose();
    signaling.localStream = ValueNotifier(null);
  }

  /// Shares another browser tab (tested on Chrome).
  Future<void> shareTab() async {
    try {
      await signaling.openUserMedia(localRenderer);
      signaling.localStream.addListener(() {
        if (signaling.localStream.value != null) {
          streamActive.value = true;
          print('stream started');
        }
      });
    } catch (e) {}
  }

  /// Saves a 25 second chunk of audio (if the stream from the
  /// shared browser tab is active.
  Future<void> saveAudioChunk() async {
    timer.value = 25;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      this.timer.value--;
      if (this.timer.value == 0) {
        timer.cancel();
      }
    });

    startRecording();
    if (signaling.localStream.value == null) {
      if (_timer != null) _timer!.cancel();
      timer.value = 0;
      return;
    } else {
      streamActive.value = true;
    }
    await Future.delayed(const Duration(seconds: 25));
    await stopRecording();
  }
  /// Starts recording audio from the shared browser tab.
  Future<void> startRecording() async {
    if (signaling.localStream.value == null) {
      print('Stream is not initialized');
      streamActive.value = false;
      return;
    }
    print('startRecording');
    MediaStream stream = signaling.localStream.value!;
    _mediaRecorder = MediaRecorder();
    var videoTracks = stream.getVideoTracks();

    if (videoTracks.isNotEmpty) {
      stream.removeTrack(videoTracks.first);
    }

    try {
      /// We pass in a callback function to the `onDataChunk` property which
      /// will be called when the `MediaRecorder` has a new chunk of audio.
      /// We then pass that chunk to the `getWaveBlob` function which will
      /// convert the audio to a `Blob` object in the wav format.
      _mediaRecorder.startWeb(stream, mimeType: 'audio/webm', onDataChunk: (data, isLastOne) {
        var blob = Blob([data], 'audio/webm');
        var webmBlobUrl = Url.createObjectUrlFromBlob(blob);
        AnchorElement anchorElement = AnchorElement(href: webmBlobUrl);
        anchorElement.download = 'audio.webm';
        anchorElement.click();

        // JS webm to wav conversion. THIS DOESN'T CURRENTLY WORK!
        // It seems to return a 16 byte file every time with no audio in it.
        var jsBlob = js.context.callMethod('getWaveBlob',[blob, false, {'sampleRate': 16000}]);

        print('VideoStreamController - getWaveBlob - got value');

        var wavBlob = Blob([jsBlob], 'audio/wav');
        var wavBlobUrl = Url.createObjectUrlFromBlob(wavBlob);
        print('VideoStreamController - getWaveBlob - got url');


        anchorElement = AnchorElement(href: wavBlobUrl);
        anchorElement.download = 'audio.wav';
        anchorElement.click();
      });

    } catch (e) {

    }
  }

  /// This stops the recording of audio from the shared browser tab.
  /// It seems that when the `MediaRecorder` is stopped, the `onDataChunk`
  /// callback is called one last time with the last chunk of audio.
  Future<void> stopRecording({bool isLast = false}) async {
    if (signaling.localStream.value == null) {
      print('Stream is not initialized');
      streamActive.value = false;
      return;
    }
    // this is guaranteed to fail, but does the job it needs.
    try {
      await _mediaRecorder.stop();
    } catch (e) {

    }
    streamActive.value = false;
  }

  Future<void> sendAudioFile(dynamic objectUrl, bool isLast) async {
    var audioString = await blobUrlImageToBase64(objectUrl);
  }

  Future<String> blobUrlImageToBase64(String imageUrl) async {
    http.Response response = await http.get(Uri.parse(imageUrl));
    final bytes = response.bodyBytes;
    return base64Encode(bytes);
  }
}
