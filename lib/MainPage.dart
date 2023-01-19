import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_bluetooth_serial_example/DiscoveryPage.dart';
import 'package:flutter_bluetooth_serial_example/screen/bluetooth_info.dart';
import 'package:flutter_bluetooth_serial_example/screen/paired_device.dart';
import 'package:flutter_bluetooth_serial_example/screen/settings.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bi.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:iconify_flutter/icons/ph.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPage createState() => new _MainPage();
}

class _MainPage extends State<MainPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  Timer? _discoverableTimeoutTimer;

  @override
  void initState() {
    super.initState();

    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {});

    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        _discoverableTimeoutTimer = null;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  Future<bool?> onExitPress() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Are you sure"),
          content: Text("Do you want to exit from the app?"),
          actions: [
            TextButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: Text("Yes")),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text("No")),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        onExitPress();
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.black,
          title: Text("Bluetooth Device Manager"),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SettingsView()),
                );
              },
              icon: Icon(Icons.settings),
            ),
          ],
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xff000000),
                Color(0xFF2C2B2B),
                Color(0xff000000),
              ],
            ),
          ),
          child: Column(
            children: <Widget>[
              SizedBox(height: 40),
              SizedBox(height: 30),
              Stack(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xff393939),
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xff000000),
                          Color(0xff000000),
                          Color(0xFFC9943B),
                          Color(0xFFFEFCA3),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 2,
                    right: 2,
                    bottom: 2,
                    top: 2,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      height: 55,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color(0xFF000000),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Iconify(
                            Bi.bluetooth,
                            color: Color(0xFFFEFCA3),
                          ),
                          SizedBox(width: 15),
                          Text(
                            "Bluetooth Status",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w300),
                          ),
                          Spacer(),
                          CupertinoSwitch(
                            activeColor: Color(0xffE9E242),
                            value: _bluetoothState.isEnabled,
                            onChanged: (value) {
                              future() async {
                                if (value){
                                  await FlutterBluetoothSerial.instance
                                      .requestEnable();
                                      print("enable");}
                                else
                                  await FlutterBluetoothSerial.instance
                                      .requestDisable();
                              }

                              future().then((_) {
                                setState(() {});
                              });
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return BluetoothInfo();
                      },
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color(0xff393939),
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [
                            Color(0xff000000),
                            Color(0xff000000),
                            Color(0xFFC9943B),
                            Color(0xFFFEFCA3),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 2,
                      right: 2,
                      bottom: 2,
                      top: 2,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        height: 55,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xFF000000),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Iconify(
                              Bi.info_circle,
                              color: Color(0xFFFEFCA3),
                            ),
                            SizedBox(width: 15),
                            Text(
                              "Bluetooth Info",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w300),
                            ),
                            Spacer(),
                            Iconify(
                              Ic.baseline_keyboard_arrow_right,
                              color: Color(0xFFFEFCA3),
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return PairedPage();
                      },
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color(0xff393939),
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [
                            Color(0xff000000),
                            Color(0xff000000),
                            Color(0xFFC9943B),
                            Color(0xFFFEFCA3),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 2,
                      right: 2,
                      bottom: 2,
                      top: 2,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        height: 55,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xFF000000),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Iconify(
                              Ph.device_mobile_camera_thin,
                              color: Color(0xFFFEFCA3),
                            ),
                            SizedBox(width: 15),
                            Text(
                              "Paired Devices",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w300),
                            ),
                            Spacer(),
                            Iconify(
                              Ic.baseline_keyboard_arrow_right,
                              color: Color(0xFFFEFCA3),
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return DiscoveryPage();
                      },
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color(0xff393939),
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [
                            Color(0xff000000),
                            Color(0xff000000),
                            Color(0xFFC9943B),
                            Color(0xFFFEFCA3),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 2,
                      right: 2,
                      bottom: 2,
                      top: 2,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        height: 55,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xFF000000),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Iconify(
                              Ph.device_mobile_camera_thin,
                              color: Color(0xFFFEFCA3),
                            ),
                            SizedBox(width: 15),
                            Text(
                              "Find Devices",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w300),
                            ),
                            Spacer(),
                            Iconify(
                              Ic.baseline_keyboard_arrow_right,
                              color: Color(0xFFFEFCA3),
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BlueButtons extends StatelessWidget {
  final Function() onPressed;
  final String text;
  final String icon1;
  const BlueButtons({
    Key? key,
    required this.onPressed,
    required this.text,
    required this.icon1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6),
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xff393939),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 16),
                      FittedBox(
                        child: Text(
                          text,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: -20,
              right: 25,
              left: 25,
              child: Stack(
                children: [
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xFF949292),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xffFFD700),
                          Color(0xFF494848),
                          Color(0xFF494848),
                          Color(0xff000000),
                          Color(0xFF494848),
                          Color(0xFF494848),
                          Color(0xffFFD700),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 3,
                    bottom: 3,
                    right: 0,
                    left: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xff000000),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF494848),
                            Color(0xff000000),
                            Color(0xFF494848),
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Iconify(
                            icon1,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
