import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceInputWidget extends StatefulWidget {
  const VoiceInputWidget({super.key});

  @override
  State<VoiceInputWidget> createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends State<VoiceInputWidget> {
  bool isRecording = false;
  double dragDistance = 0.0;
  late DateTime recordingStartTime;

  Future<void> _requestMicPermission() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      _startRecording();
    } else if (status.isDenied) {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Mic Permission Denied"),
        content: const Text(
            "Please enable microphone permission to use voice input."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.of(context).pop();
            },
            child: const Text("Settings"),
          ),
        ],
      ),
    );
  }

  void _startRecording() {
    setState(() {
      isRecording = true;
      recordingStartTime = DateTime.now();
    });
  }

  void _cancelRecording() {
    setState(() {
      isRecording = false;
      dragDistance = 0;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      dragDistance += details.delta.dx;
      if (dragDistance > 100) {
        _cancelRecording(); // Cancel if dragged too far
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Input Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.mic), // Voice input
              onPressed: () {
                _requestMicPermission();
              },
            ),
            if (isRecording)
              GestureDetector(
                onLongPress: () {
                  _startRecording();
                },
                onLongPressUp: () {
                  setState(() {
                    isRecording = false;
                    // Handle recording completion
                  });
                },
                onHorizontalDragUpdate: _onDragUpdate,
                child: Container(
                  width: double.infinity,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Text("Recording... Drag to cancel →",
                        style: TextStyle(color: Colors.red)),
                  ),
                ),
              ),
            if (isRecording)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  "Recording Time: ${DateTime.now().difference(recordingStartTime).inSeconds}s",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
