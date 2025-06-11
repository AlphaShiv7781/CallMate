import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class CallScreen extends StatefulWidget {
  final String channelName;
  const CallScreen({super.key, required this.channelName});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  static const String appId = "a70ec598314c4b4898e8dd7da60add0f";

  int? _remoteUid;
  late RtcEngine _engine;
  bool _isJoined = false;
  bool _isEngineReady = false;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    // Request camera and mic permission
    await [Permission.camera, Permission.microphone].request();

    // Initialize engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: appId));

    // Register event handlers
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          print('✅ Local user joined: ${connection.channelId} | UID: ${connection.localUid}');
          setState(() {
            _isJoined = true;
          });
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          print('👤 Remote user joined: $remoteUid');
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (connection, remoteUid, reason) {
          print('❌ Remote user left: $remoteUid | Reason: $reason');
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );

    // Enable local video
    await _engine.enableVideo();
    await _engine.startPreview();

    // Generate unique UID per device
    final uid = DateTime.now().millisecondsSinceEpoch % 100000;

    // Join channel with media options
    await _engine.joinChannel(
      token: '', // 🔐 Use a temp token if your project requires it
      channelId: widget.channelName,
      uid: uid,
      options: const ChannelMediaOptions(
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );

    setState(() {
      _isEngineReady = true;
    });
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isEngineReady) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Channel: ${widget.channelName}"),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          // Remote video view
          if (_remoteUid != null)
            AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _engine,
                canvas: VideoCanvas(uid: _remoteUid),
                connection: RtcConnection(channelId: widget.channelName),
              ),
            )
          else
            Center(
              child: Text(
                _isJoined ? "Waiting for friend to join..." : "Joining channel...",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),

          // Local video view
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 120,
              height: 160,
              child: AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: _engine,
                  canvas: const VideoCanvas(uid: 0),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: const Icon(Icons.call_end),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
