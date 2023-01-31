// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable
import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';

import 'package:flutter_bluetooth_serial_example/screen/privacyPolicy.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final InAppReview inAppReview = InAppReview.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff000000),
        centerTitle: true,
        title: Text("Settings"),
      ),
      body: Container(
        width: double.infinity,
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
        child: Column(
          children: [
            SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.info_outline, color: Colors.white),
              title: Text(
                "Version",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              trailing: Text("1.0.0", style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return BlurryDialog(
                      content:
                          "With purchasing this item all adds from application will be removed",
                      continueCallBack: () {
                        Navigator.of(context).pop();
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return Container(
                              height: 200,
                              child: Column(
                                children: [
                                  Text("Google pay"),
                                  Divider(),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  ListTile(
                                    leading: Image.asset(
                                      "assets/logo.png",
                                      height: 50,
                                    ),
                                    title: Text("ad.free_remove.ads"),
                                    subtitle: Text("Bluetooth Device Manager"),
                                    trailing: Text("₹350.00"),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Divider(),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 1.1,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        closeFunnction();
                                      },
                                      child: Text("Buy"),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Color.fromARGB(255, 0, 124, 5)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      title: "Confirm your In-App Purchase",
                      continueText: "Purchase",
                    );
                  },
                );
              },
              leading: Icon(Icons.payments, color: Colors.white),
              title: Text(
                "Pay for ad-free version",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
            ),
            ListTile(
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (context) {
                    return BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: AlertDialog(
                          title: new Text(
                            "Rate us",
                          ),
                          content: RatingBar.builder(
                            itemSize: 30,
                            initialRating: 0,
                            minRating: 1,
                            itemPadding: EdgeInsets.only(left: 5),
                            glow: false,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              print(rating);
                            },
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text("Cancel"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: new Text("Rate us"),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ));
                    //  BlurryDialog(
                    //   content:
                    //       "If you enjoy this app,would you mind taking a moment to rate it?\nThanks for your support!",
                    //   title: "Rate App",
                    //   continueCallBack: () async {
                    //     if (await inAppReview.isAvailable()) {
                    //       inAppReview.requestReview();
                    //       Navigator.pop(context);
                    //     }
                    //   },
                    //   continueText: "Rate Now",
                    // );
                  },
                );
              },
              leading: Icon(Icons.star, color: Colors.white),
              title: Text(
                "Rate the app",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
            ),
            ListTile(
              onTap: () async {
                await Share.share(
                    'https://play.google.com/store/apps/details?id=com.dword.bluetooth_device_manager');
              },
              leading: Icon(Icons.share, color: Colors.white),
              title: Text(
                "Share the app",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => RefundPolicy(),
                ));
              },
              leading: Icon(Icons.newspaper, color: Colors.white),
              title: Text(
                "Privacy Policy",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void closeFunnction() async {
    Timer(Duration(seconds: 2), () {
      CircularProgressIndicator();
    });
    Navigator.pop(context);
    SnackBar(content: Text("sds"));
  }
}

class BlurryDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback continueCallBack;
  final String continueText;

  BlurryDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.continueCallBack,
    required this.continueText,
  }) : super(key: key);
  TextStyle textStyle = TextStyle(color: Colors.black);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: AlertDialog(
        title: new Text(
          title,
          style: textStyle,
        ),
        content: new Text(
          content,
          style: textStyle,
        ),
        actions: <Widget>[
          new TextButton(
            child: new Text(continueText),
            onPressed: () {
              continueCallBack();
            },
          ),
          new TextButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
