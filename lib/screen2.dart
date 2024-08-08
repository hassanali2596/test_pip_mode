import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

class Screen2 extends StatefulWidget {
  const Screen2({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<Screen2> createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> with WidgetsBindingObserver {
  bool isPIPActive = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      HMSAndroidPIPController.setup(autoEnterPip: true, aspectRatio: [9, 16]);
    } else {
      HMSIOSPIPController.setup(autoEnterPip: true, aspectRatio: [9, 16]);
    }
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      if (!isPIPActive) {
        enterPiPMode();
        // The app is now in the background
        print('App inactive');
      }
    } else if (state == AppLifecycleState.resumed) {
      updatePIPState();
    }
  }

  updatePIPState() async {
    isPIPActive = await HMSAndroidPIPController.isActive();
  }

  enterPiPMode() {
    if (Platform.isAndroid) {
      HMSAndroidPIPController.start();
      isPIPActive = true;
    } else if (Platform.isIOS) {
      HMSIOSPIPController.start();
      HMSIOSPIPController.changeText(text: "Screen 2");
    }
  }

  Future<bool> destroyPip() async {
    bool isPIPDestroyed = false;
    if (Platform.isAndroid) {
      isPIPDestroyed = await HMSAndroidPIPController.destroy();
    } else if (Platform.isIOS) {
      isPIPDestroyed = await HMSIOSPIPController.destroy();
    }
    isPIPActive = false;
    return isPIPDestroyed;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (_) {
        destroyPip();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Screen 2',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(
                height: 40,
              ),
              ElevatedButton(
                  onPressed: () async {
                    bool isPIPDestroyed = await destroyPip();
                    log("PIP Destroyed: $isPIPDestroyed");

                    Navigator.pop(context);
                  },
                  child: const Text("End Call And Back"))
            ],
          ),
        ),
      ),
    );
  }
}