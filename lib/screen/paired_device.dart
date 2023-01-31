import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PairedPage extends StatefulWidget {
  final bool start;

  const PairedPage({this.start = true});

  @override
  _PairedPage createState() => new _PairedPage();
}

class _PairedPage extends State<PairedPage> {
  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  List<BluetoothDiscoveryResult> results =
      List<BluetoothDiscoveryResult>.empty(growable: true);
  bool isDiscovering = false;
  List<BluetoothDiscoveryResult?> unPair = [];

  _PairedPage();

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
      unPair.clear();
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

        unPair = results.map((e) {
          if (e.device.isBonded == true) {
            return e;
          } else {
            return null;
          }
        }).toList();
        unPair.removeWhere((value) => value == null);
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
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xff000000),
        title: Text('Paired devices'),
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
            itemCount: unPair.length,
            itemBuilder: (BuildContext context, index) {
              log(unPair[index].toString());
              BluetoothDiscoveryResult? result = unPair[index];
              final device = result?.device;
              final address = device?.address;
              return DeviceList(
                device: device,
                result: result,
                onTap: () async {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('UnPairing device'),
                        content: Text("Do you want to UnPair ${device?.name}"),
                        actions: [
                          TextButton(
                            child: Text("UnPair"),
                            onPressed: () async {
                              final pref =
                                  await SharedPreferences.getInstance();
                              try {
                                bool bonded = false;
                                if (device!.isBonded) {
                                  await FlutterBluetoothSerial.instance
                                      .removeDeviceBondWithAddress(address!);
                                  _restartDiscovery();
                                  Navigator.of(context).pop();
                                } else {
                                  bonded = (await FlutterBluetoothSerial
                                      .instance
                                      .bondDeviceAtAddress(address!))!;
                                  await pref.setBool("getPairedDevice",
                                      device.isBonded == true);
                                }
                                setState(
                                  () {
                                    results[results.indexOf(result!)] =
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
                                  },
                                );
                              } catch (ex) {
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
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class DeviceList extends StatelessWidget {
  const DeviceList({
    Key? key,
    this.device,
    this.result,
    required this.onTap,
  }) : super(key: key);
  final Function() onTap;
  final BluetoothDevice? device;
  final BluetoothDiscoveryResult? result;

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
                  device?.name ?? "Unknown device",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  device?.address ?? "Unknown address",
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
                      device?.isBonded ?? false ? 'Un Pair' : 'Pair',
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
