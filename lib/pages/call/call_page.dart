import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

const String agoraAppId = 'c15eb6cd2b704bfeab5cfbf53c5a13f5';

class CallPage extends StatefulWidget {
  final String channelName;
  final String token;

  const CallPage({
    super.key,
    required this.channelName,
    required this.token,
  });

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  late RtcEngine _engine;
  bool _isInitialized = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: agoraAppId));

    _engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (connection, elapsed) {
        debugPrint("✅ Joined channel: ${widget.channelName}");
      },
      onUserJoined: (connection, remoteUid, elapsed) {
        debugPrint("👤 Remote user joined: $remoteUid");
      },
      onUserOffline: (connection, remoteUid, reason) {
        debugPrint("❌ Remote user left: $remoteUid");
        Navigator.pop(context);
      },
    ));

    await _engine.enableVideo();
    await _engine.startPreview();

    await _engine.joinChannel(
      token: widget.token,
      channelId: widget.channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );

    setState(() {
      _isInitialized = true;
    });
  }

  void _flipCamera() async {
    await _engine.switchCamera();
  }

  void _toggleMute() async {
    setState(() {
      _isMuted = !_isMuted;
    });
    await _engine.muteLocalAudioStream(_isMuted);
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: _engine,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 20,
                  child: Text(
                    'Channel: ${widget.channelName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 32,
                  left: 24,
                  child: Row(
                    children: [
                      FloatingActionButton(
                        heroTag: 'flipCamera',
                        backgroundColor: Colors.white24,
                        onPressed: _flipCamera,
                        child: const Icon(Icons.flip_camera_ios, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      FloatingActionButton(
                        heroTag: 'muteMic',
                        backgroundColor: _isMuted ? Colors.red : Colors.white24,
                        onPressed: _toggleMute,
                        child: Icon(
                          _isMuted ? Icons.mic_off : Icons.mic,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 32,
                  right: 32,
                  child: FloatingActionButton(
                    heroTag: 'endCall',
                    backgroundColor: Colors.red,
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(Icons.call_end),
                  ),
                ),
              ],
            ),
    );
  }
}
