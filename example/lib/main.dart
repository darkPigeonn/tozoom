import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tozoom/tozoom.dart';
import 'package:tozoom/tozoom_options.dart';
import 'package:tozoom/tozoom_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  TextEditingController meetingIdController = TextEditingController();
  late Timer timer;
  final _tozoomPlugin = Tozoom();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _tozoomPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Center(
              child: Text('Running on: $_platformVersion\n'),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextField(
                controller: meetingIdController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Meeting ID',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Builder(
                builder: (context) {
                  // The basic Material Design action button.
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue, // background
                      onPrimary: Colors.white, // foreground
                    ),
                    onPressed: () => {
                      {joinMeeting(context)}
                    },
                    child: const Text('Join'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  joinMeeting(BuildContext context) {
    if (meetingIdController.text.isNotEmpty) {
      print('hai');
      bool _isMeetingEnded(String status) {
        var result = false;

        if (Platform.isAndroid) {
          result = status == "MEETING_STATUS_DISCONNECTING" ||
              status == "MEETING_STATUS_FAILED";
        } else {
          result = status == "MEETING_STATUS_IDLE";
        }

        return result;
      }

      ZoomOptions zoomOptions = ZoomOptions(
        domain: "zoom.us",
        appKey: "fUjmn4sIrkO5Xr2fTmI8K4Priyi1TxEd4BlK", //API KEY FROM ZOOM
        appSecret:
            "Ty2SXmxJyTJQGdJELUbrzyCuqVEbDH32M55K", //API SECRET FROM ZOOM
      );
      var meetingOptions = ZoomMeetingOptions(
          userId: 'username',

          /// pass username for join meeting only --- Any name eg:- EVILRATT.
          meetingId: meetingIdController.text,

          /// pass meeting password for join meeting only
          disableDialIn: "true",
          disableDrive: "true",
          disableInvite: "true",
          disableShare: "true",
          disableTitlebar: "false",
          viewOptions: "true",
          noAudio: "false",
          noDisconnectAudio: "false");

      var zoom = ZoomView();

      zoom.initZoom(zoomOptions).then((result) {
        print("result");
        if (result[0] == 0) {
          zoom.joinMeeting(meetingOptions).then((joinMeetingResult) {
            timer = Timer.periodic(const Duration(seconds: 2), (timer) {
              zoom.meetingStatus(meetingOptions.meetingId!).then((status) {
                if (kDebugMode) {
                  print("[Meeting Status Polling] : " +
                      status[0] +
                      " - " +
                      status[1]);
                }
              });
            });
          });
        }
      });
    } else {
      if (meetingIdController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Fill Meeting ID!"),
        ));
      }
    }
  }
}
