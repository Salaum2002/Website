import 'dart:convert';
import 'dart:io' as io;
import 'dart:html' as html; // Import dart:html for web
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';
import 'package:path_provider/path_provider.dart'; // For getting application directory
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw; // Import pdf package
import 'package:printing/printing.dart'; // Import printing package
import 'package:fl_chart/fl_chart.dart'; // Import fl_chart package for graph
import 'package:table_calendar/table_calendar.dart'; // Import for Calendar

import '../utlis/colors.dart'; // Ensure this file exists
import 'login_screen.dart';
import 'tabs/items_tab.dart';
import 'tabs/records_tab.dart';
import '../widgets/text_widget.dart';
import 'tabs/users_records_tab.dart'; // Import the new tab
import 'tabs/dashboard_tab.dart'; // Import the new DashboardTab file

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool inrecords = true;
  bool initems = false;
  bool inqrcode = false;
  bool intickets = false;
  bool inusers = false;
  bool indashboard = false; // State variable for Dashboard

  final _qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();
  String? code;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Card(
              child: SizedBox(
                width: 300,
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      child: Image.asset(
                        'assets/images/logos.png',
                        height: 200,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 90.0),
                      child: TextWidget(
                        text: 'Administrator',
                        fontFamily: 'Bold',
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildMenuTile('Logs', inrecords, () {
                      setState(() {
                        inrecords = true;
                        initems = false;
                        inqrcode = false;
                        intickets = false;
                        inusers = false;
                        indashboard = false;
                      });
                    }),
                    const SizedBox(height: 20),
                    _buildMenuTile('Dashboard', indashboard, () {
                      setState(() {
                        inrecords = false;
                        initems = false;
                        inqrcode = false;
                        intickets = false;
                        inusers = false;
                        indashboard = true;
                      });
                    }),
                    const SizedBox(height: 20),
                    _buildMenuTile('Users Records', inusers, () {
                      setState(() {
                        inrecords = false;
                        initems = false;
                        inqrcode = false;
                        intickets = false;
                        inusers = true;
                        indashboard = false;
                      });
                    }),
                    const SizedBox(height: 20),
                    _buildMenuTile('Items', initems, () {
                      setState(() {
                        inrecords = false;
                        initems = true;
                        inqrcode = false;
                        intickets = false;
                        inusers = false;
                        indashboard = false;
                      });
                    }),
                    const SizedBox(height: 20),
                    _buildMenuTile('QR Code', inqrcode, () async {
                      _qrBarCodeScannerDialogPlugin.getScannedQrBarCode(
                        context: context,
                        onCode: (code) async {
                          await FirebaseFirestore.instance
                              .collection('Records')
                              .doc(code!.split('= ')[1])
                              .get()
                              .then((DocumentSnapshot documentSnapshot) async {
                            print('My code ${code.split('= ')[1]}');
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return AlertDialog(
                                  content: TextWidget(
                                    text: 'QR Code Scanned Successfully!',
                                    fontSize: 48,
                                    fontFamily: 'Bold',
                                  ),
                                  actions: <Widget>[
                                    MaterialButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                      },
                                      child: const Text(
                                        'Close',
                                        style: TextStyle(
                                            fontFamily: 'QRegular',
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    MaterialButton(
                                      onPressed: () async {
                                        showReceipt(documentSnapshot.data()
                                            as Map<String, dynamic>);
                                      },
                                      child: const Text(
                                        'Generate Receipt',
                                        style: TextStyle(
                                            fontFamily: 'QRegular',
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          }).catchError((error) {
                            print('Error fetching data: $error');
                          });
                        },
                      );
                    }),
                    const SizedBox(height: 20),
                    ListTile(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text(
                              'Logout Confirmation',
                              style: TextStyle(
                                  fontFamily: 'QBold',
                                  fontWeight: FontWeight.bold),
                            ),
                            content: const Text(
                              'Are you sure you want to Logout?',
                              style: TextStyle(fontFamily: 'QRegular'),
                            ),
                            actions: <Widget>[
                              MaterialButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text(
                                  'Close',
                                  style: TextStyle(
                                      fontFamily: 'QRegular',
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              MaterialButton(
                                onPressed: () async {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Continue',
                                  style: TextStyle(
                                      fontFamily: 'QRegular',
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      title: TextWidget(
                        text: 'Logout',
                        fontSize: 18,
                        color: Colors.grey,
                        fontFamily: 'Bold',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 50),
                      Align(
                        alignment: Alignment.topRight,
                        child: TextWidget(
                          text: DateFormat('MMMM dd, yyyy | hh:mm a')
                              .format(DateTime.now()),
                          fontSize: 14,
                          fontFamily: 'Bold',
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: inrecords
                        ? const RecordsTab()
                        : inusers
                            ? const UsersRecordsTab()
                            : initems
                                ? const ItemsTab()
                                : indashboard
                                    ? const UsersGraphTab() // Refers to the new DashboardTab file
                                    : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ListTile _buildMenuTile(String text, bool selected, VoidCallback onTap) {
    return ListTile(
      tileColor: selected ? primary : Colors.transparent,
      onTap: onTap,
      title: TextWidget(
        text: text,
        fontSize: 18,
        color: selected ? Colors.white : Colors.grey,
        fontFamily: 'Bold',
      ),
    );
  }

  Future<void> showReceipt(Map<String, dynamic>? data) async {
    // The implementation of this function stays the same as your original code
  }
}
