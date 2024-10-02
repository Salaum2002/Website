import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:smart_waste_web/widgets/text_widget.dart';

class UsersGraphTab extends StatefulWidget {
  const UsersGraphTab({super.key});

  @override
  State<UsersGraphTab> createState() => _UsersGraphTabState();
}

class _UsersGraphTabState extends State<UsersGraphTab> {
  late List<_ChartData> data;

  int total = 0;
  bool isLoaded = false;

  @override
  Widget build(BuildContext context) {
    data = [
      _ChartData('Jan', 0),
      _ChartData('Feb', 0),
      _ChartData('Mar', 0),
      _ChartData('Apr', 0),
      _ChartData('May', 0),
      _ChartData('Jun', 0),
      _ChartData('Jul', 0),
      _ChartData('Aug', 0),
      _ChartData('Sep', 0),
      _ChartData('Oct', 0),
      _ChartData('Nov', 0),
      _ChartData('Dec', 0),
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          TextWidget(
            text: 'Number of Users ($total)',
            fontSize: 18,
            fontFamily: 'Bold',
          ),
          const SizedBox(height: 10),
          // Real-time Bar Graph Widget for Users' Points
          StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('Users').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Center(
                        child: CircularProgressIndicator(color: Colors.black)),
                  );
                }

                // Initialize monthly user count map
                Map<int, int> monthlyUserCounts = {};

                // Get user data from Firestore snapshot
                final userData = snapshot.requireData;

                if (!isLoaded) {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (timeStamp) {
                      setState(() {
                        total = userData.docs.length;
                        isLoaded = true;
                      });
                    },
                  );
                }
                for (var doc in userData.docs) {
                  Timestamp timestamp =
                      doc['dateTime']; // Assuming 'dateTime' field exists
                  DateTime date = timestamp.toDate();

                  int month = date.month; // Get the month (1-12)

                  // Update the user count for the corresponding month
                  if (monthlyUserCounts.containsKey(month)) {
                    monthlyUserCounts[month] = monthlyUserCounts[month]! + 1;
                  } else {
                    monthlyUserCounts[month] = 1;
                  }
                }

                // Update the chart data with the user counts
                for (int i = 0; i < data.length; i++) {
                  data[i].y = monthlyUserCounts[i + 1]?.toDouble() ?? 0;
                }

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SizedBox(
                        height: 400,
                        child: SfCartesianChart(
                            primaryXAxis: const CategoryAxis(),
                            primaryYAxis: const NumericAxis(
                                minimum: 0, maximum: 20, interval: 5),
                            series: <CartesianSeries<_ChartData, String>>[
                              ColumnSeries<_ChartData, String>(
                                  dataLabelSettings: const DataLabelSettings(
                                    color: Colors.blue,
                                    isVisible: true, // Make the labels visible
                                    labelAlignment: ChartDataLabelAlignment
                                        .top, // Show labels on top
                                  ),
                                  dataSource: data,
                                  xValueMapper: (_ChartData data, _) => data.x,
                                  yValueMapper: (_ChartData data, _) => data.y,
                                  name: 'Users',
                                  color: const Color.fromRGBO(8, 142, 255, 1))
                            ])),
                  ),
                );
              }),
        ],
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  double y;
}
