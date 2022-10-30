import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

typedef void StreamStateCallback(MediaStream stream);

class TabSharingInterface {
  RTCPeerConnection? peerConnection;
  ValueNotifier<MediaStream?> localStream = ValueNotifier(null);
  MediaStreamTrack? screenshotStream;

  Future<void> openUserMedia(
      RTCVideoRenderer localVideo,
      ) async {
    var stream = await navigator.mediaDevices
        .getDisplayMedia({'video': true, 'audio': true}, );
    localVideo.srcObject = stream;
    localStream.value = stream;
    screenshotStream = stream.getVideoTracks().first;
  }

  void registerPeerConnectionListeners() {
    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      print('ICE gathering state changed: $state');
    };

    peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      print('Connection state change: $state');
    };

    peerConnection?.onSignalingState = (RTCSignalingState state) {
      print('Signaling state change: $state');
    };

    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      print('ICE connection state change: $state');
    };

    peerConnection?.onAddStream = (MediaStream stream) {
      print("Add remote stream");
    };
  }
}
