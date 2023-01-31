import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiscoveryPage extends StatefulWidget {
  final bool start;

  const DiscoveryPage({this.start = true});

  @override
  _DiscoveryPage createState() => new _DiscoveryPage();
}

class _DiscoveryPage extends State<DiscoveryPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  int _pairingIndex = 0;
  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  List<BluetoothDiscoveryResult> results =
      List<BluetoothDiscoveryResult>.empty(growable: true);
  bool isDiscovering = false;

  _DiscoveryPage();

  String infoText({BluetoothDevice? device, required int index}) {
    if (index == 0) {
      return "Do you want to ${device?.isBonded ?? true ? "UnPair" : "Pair"} with ${device?.name ?? 'Unknown device'}";
    } else {
      return "Please accept the pairing request on the other device";
    }
  }

  @override
  void initState() {
    super.initState();

    isDiscovering = widget.start;
    if (isDiscovering) {
      _startDiscovery();
    }
  }

  Future<void> check() async {
    if (isDiscovering) {
      Fluttertoast.showToast(
        msg: "Please wait for the discovery to finish",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 14.0,
      );
    } else {
      _restartDiscovery();
    }
  }

  Future<void> _restartDiscovery() async {
    setState(() {
      results.clear();
      isDiscovering = true;
    });

    _startDiscovery();
  }

  void _startDiscovery() {
    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        final existingIndex = results.indexWhere(
            (element) => element.device.address == r.device.address);
        if (existingIndex >= 0)
          results[existingIndex] = r;
        else
          results.add(r);
        results.removeWhere((element) =>
            element.device.name == null || element.device.name == "");
      });
    });

    _streamSubscription!.onDone(() {
      setState(() {
        isDiscovering = false;
      });
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xff000000),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('List of devices'),
            Text(
              "Device count ${results.length}",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          isDiscovering
              ? FittedBox(
                  child: Container(
                    margin: new EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.replay),
                  onPressed: _restartDiscovery,
                )
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
              Color(0xff212121),
              Color(0xff242323),
              Color(0xff000000),
            ],
          ),
        ),
        child: RefreshIndicator(
          color: Color(0xff393939),
          onRefresh: check,
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (BuildContext context, index) {
              BluetoothDiscoveryResult result = results[index];
              final device = result.device;
              final address = device.address;
              return DeviceList(
                device: device,
                result: result,
                onTap: () async {
                  await newMethod(device, address, result);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  newMethod(
    BluetoothDevice device,
    String address,
    BluetoothDiscoveryResult result,
  ) async {
    showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(device.isBonded ? "UnPair" : "Pair"),
          content: Text(
            infoText(device: device, index: _pairingIndex),
          ),
          actions: [
            TextButton(
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text(device.isBonded ? "UnPair" : "Pair"),
              onPressed: () async {
                final pref = await SharedPreferences.getInstance();
                try {
                  bool bonded = false;
                  if (device.isBonded) {
                    await FlutterBluetoothSerial.instance
                        .removeDeviceBondWithAddress(address);
                  } else {
                    Navigator.of(context).pop();
                    _pairingIndex = 1;
                    bonded = (await FlutterBluetoothSerial.instance
                        .bondDeviceAtAddress(address))!;
                    await pref.setBool(
                        "getPairedDevice", device.isBonded == true);
                  }
                  setState(
                    () {
                      results[results.indexOf(result)] =
                          BluetoothDiscoveryResult(
                        device: BluetoothDevice(
                          name: device.name ?? '',
                          address: address,
                          type: device.type,
                          bondState: bonded
                              ? BluetoothBondState.bonded
                              : BluetoothBondState.none,
                        ),
                        rssi: result.rssi,
                      );

                      _pairingIndex = 0;
                      _isLoading = false;
                    },
                  );
                  Navigator.of(context).pop();
                } catch (ex) {
                  setState(() {
                    _pairingIndex = 0;
                  });
                  log(ex.toString());
                }
              },
            ),
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class DeviceList extends StatelessWidget {
  const DeviceList({
    Key? key,
    required this.device,
    required this.result,
    required this.onTap,
  }) : super(key: key);
  final Function() onTap;
  final BluetoothDevice device;
  final BluetoothDiscoveryResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(vertical: 10),
      height: 75,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xff4B4646),
            Color(0xFF2E2D2D),
            Color(0xFF2E2D2D),
            Color(0xff4B4646),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xffFFD700),
                      Color(0xFF807C7C),
                      Color(0xFF575454),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 2,
                left: 2,
                bottom: 2,
                right: 2,
                child: Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                  child: Center(
                    child: Iconify(
                      Ph.device_mobile_thin,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name ?? "Unknown device",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  device.address,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Container(
                height: 40,
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xffFFD700),
                      Color(0xFF807C7C),
                      Color(0xFF575454),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 2,
                left: 2,
                bottom: 2,
                right: 2,
                child: Container(
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black,
                  ),
                  child: TextButton(
                    onPressed: onTap,
                    child: Text(
                      device.isBonded ? 'Un Pair' : 'Pair',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 10),
        ],
      ),
    );
  }
}
