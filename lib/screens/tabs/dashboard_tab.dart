import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class UsersGraphTab extends StatelessWidget {
  const UsersGraphTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Real-time Bar Graph Widget for Users' Points
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                height: 400,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users') // Listen to the 'users' collection
                      .snapshots(),
                  builder: (context, snapshot) {
                    // Log the snapshot status
                    print("Connection state: ${snapshot.connectionState}");

                    // Check for errors
                    if (snapshot.hasError) {
                      print('Firestore error: ${snapshot.error}');
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    // Check connection state
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Check if data exists
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      print('No data found in Firestore');
                      return const Center(child: Text('No data available'));
                    }

                    print('Documents retrieved: ${snapshot.data!.docs.length}');

                    // Convert Firestore data to BarChartGroupData points
                    List<BarChartGroupData> barGroups = [];
                    int index = 0;

                    // Iterate over the user documents in Firestore
                    snapshot.data!.docs.forEach((doc) {
                      try {
                        print('Processing document: ${doc.id}');

                        String userName = doc['name']; // Fetch user's name
                        double points = (doc['pts'] as num)
                            .toDouble(); // Fetch user's points

                        print('User: $userName, Points: $points');

                        // Create a bar for each user with their points
                        barGroups.add(
                          BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: points,
                                color: Colors.blue,
                                width: 20,
                                borderRadius: BorderRadius.circular(8),
                              )
                            ],
                            showingTooltipIndicators: [0],
                          ),
                        );
                        index++;
                      } catch (e) {
                        print('Error processing document ${doc.id}: $e');
                      }
                    });

                    // Ensure we have data to show in the chart
                    if (barGroups.isEmpty) {
                      return const Center(
                          child: Text('No valid user data available'));
                    }

                    // Create and return the bar chart
                    return BarChart(
                      BarChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 10,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(value.toStringAsFixed(0),
                                    style:
                                        const TextStyle(color: Colors.black));
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final userIndex = value.toInt();
                                if (userIndex < snapshot.data!.docs.length) {
                                  String userName =
                                      snapshot.data!.docs[userIndex]['name'];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5.0),
                                    child: Text(
                                      userName, // Display the user's name
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                              interval: 1,
                              reservedSize: 30,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        barGroups: barGroups,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
