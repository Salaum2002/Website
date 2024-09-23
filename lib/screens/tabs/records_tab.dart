import 'dart:typed_data'; // Import for Uint8List
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_waste_web/screens/tabs/user_records_page.dart';
import 'package:smart_waste_web/widgets/text_widget.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class RecordsTab extends StatefulWidget {
  const RecordsTab({super.key});

  @override
  _RecordsTabState createState() => _RecordsTabState();
}

class _RecordsTabState extends State<RecordsTab> {
  String searchQuery = '';
  String? selectedMonth;
  List<QueryDocumentSnapshot> filteredDocs = []; // Define filteredDocs

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Search by User Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<String>(
            hint: Text('Select Month'),
            value: selectedMonth,
            items: [
              DropdownMenuItem(
                value: null,
                child: Text('Reset'),
              ),
              DropdownMenuItem(
                value: '01',
                child: Text('Month 1 (January)'),
              ),
              DropdownMenuItem(
                value: '02',
                child: Text('Month 2 (February)'),
              ),
              DropdownMenuItem(
                value: '03',
                child: Text('Month 3 (March)'),
              ),
              DropdownMenuItem(
                value: '04',
                child: Text('Month 4 (April)'),
              ),
              DropdownMenuItem(
                value: '05',
                child: Text('Month 5 (May)'),
              ),
              DropdownMenuItem(
                value: '06',
                child: Text('Month 6 (June)'),
              ),
              DropdownMenuItem(
                value: '07',
                child: Text('Month 7 (July)'),
              ),
              DropdownMenuItem(
                value: '08',
                child: Text('Month 8 (August)'),
              ),
              DropdownMenuItem(
                value: '09',
                child: Text('Month 9 (September)'),
              ),
              DropdownMenuItem(
                value: '10',
                child: Text('Month 10 (October)'),
              ),
              DropdownMenuItem(
                value: '11',
                child: Text('Month 11 (November)'),
              ),
              DropdownMenuItem(
                value: '12',
                child: Text('Month 12 (December)'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                selectedMonth = value;
              });
            },
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            final pdf = await _generatePdf(filteredDocs);
            await Printing.layoutPdf(
                onLayout: (PdfPageFormat format) async => pdf);
          },
          child: Text('Download Report'),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('Records').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                print(snapshot.error);
                return const Center(child: Text('Error'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  ),
                );
              }

              final data = snapshot.data;
              if (data == null) {
                return const Center(child: Text('No Data'));
              }

              filteredDocs = data.docs.where((doc) {
                final record = doc.data() as Map<String, dynamic>;
                final name = record['myname']?.toString().toLowerCase() ?? '';
                final timestamp = record['dateTime'] as Timestamp;
                final date = timestamp.toDate();
                final monthMatches = selectedMonth == null ||
                    date.month.toString().padLeft(2, '0') == selectedMonth;
                return name.contains(searchQuery.toLowerCase()) && monthMatches;
              }).toList();

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, top: 50),
                    child: DataTable(
                      showCheckboxColumn: false,
                      border: TableBorder.all(),
                      columnSpacing: 100,
                      columns: [
                        DataColumn(
                          label: TextWidget(
                            text: 'ID Number',
                            fontSize: 18,
                            fontFamily: 'Bold',
                          ),
                        ),
                        DataColumn(
                          label: TextWidget(
                            text: 'Name',
                            fontSize: 18,
                            fontFamily: 'Bold',
                          ),
                        ),
                        DataColumn(
                          label: TextWidget(
                            text: 'Item Name',
                            fontSize: 18,
                            fontFamily: 'Bold',
                          ),
                        ),
                        DataColumn(
                          label: TextWidget(
                            text: 'Equivalent Points',
                            fontSize: 18,
                            fontFamily: 'Bold',
                          ),
                        ),
                        DataColumn(
                          label: TextWidget(
                            text: 'Date & Time',
                            fontSize: 18,
                            fontFamily: 'Bold',
                          ),
                        ),
                      ],
                      rows: [
                        for (int i = 0; i < filteredDocs.length; i++)
                          DataRow(
                            //onSelectChanged: (value) {
                            // Navigator.of(context).push(
                            // MaterialPageRoute(
                            // builder: (context) => const UserRecordsPage(),
                            // ),
                            //);
                            // },
                            color: MaterialStateColor.resolveWith(
                              (states) => i % 2 == 0
                                  ? Colors.white
                                  : const Color.fromARGB(255, 255, 255, 255)!,
                            ),
                            cells: [
                              DataCell(
                                TextWidget(
                                  text: '${i + 1}',
                                  fontSize: 14,
                                  fontFamily: 'Medium',
                                  color: Colors.black,
                                ),
                              ),
                              DataCell(
                                TextWidget(
                                  text: (filteredDocs[i].data()
                                          as Map<String, dynamic>)['myname'] ??
                                      'N/A',
                                  fontSize: 14,
                                  fontFamily: 'Medium',
                                  color: Colors.black,
                                ),
                              ),
                              DataCell(
                                TextWidget(
                                  text: (filteredDocs[i].data()
                                          as Map<String, dynamic>)['name'] ??
                                      'N/A',
                                  fontSize: 14,
                                  fontFamily: 'Medium',
                                  color: Colors.black,
                                ),
                              ),
                              DataCell(
                                TextWidget(
                                  text:
                                      '${(filteredDocs[i].data() as Map<String, dynamic>)['pts']?.toString() ?? 'N/A'} pts',
                                  fontSize: 14,
                                  fontFamily: 'Medium',
                                  color: Colors.black,
                                ),
                              ),
                              DataCell(
                                TextWidget(
                                  text: (filteredDocs[i].data() as Map<String,
                                              dynamic>?)?['dateTime'] !=
                                          null
                                      ? _formatDate((filteredDocs[i].data()
                                          as Map<String, dynamic>)['dateTime'])
                                      : 'N/A',
                                  fontSize: 14,
                                  fontFamily: 'Medium',
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    final formattedDate =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final formattedTime =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return '$formattedDate $formattedTime';
  }

  Future<Uint8List> _generatePdf(List<QueryDocumentSnapshot> docs) async {
    final pdf = pw.Document();
    const rowsPerPage = 50; // Number of rows per page

    // Ensure docs is not empty
    if (docs.isEmpty) {
      return Uint8List(0);
    }

    // Loop through the data in chunks of rowsPerPage
    for (int i = 0; i < docs.length; i += rowsPerPage) {
      final end =
          (i + rowsPerPage < docs.length) ? i + rowsPerPage : docs.length;
      final pageData = docs.sublist(i, end);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Table.fromTextArray(
              headers: [
                'ID Number',
                'Name',
                'Item Name',
                'Equivalent Points',
                'Date & Time'
              ],
              data: [
                for (int j = 0; j < pageData.length; j++)
                  [
                    '${i + j + 1}',
                    (pageData[j].data() as Map<String, dynamic>)['myname'] ??
                        'N/A',
                    (pageData[j].data() as Map<String, dynamic>)['name'] ??
                        'N/A',
                    '${(pageData[j].data() as Map<String, dynamic>)['pts']?.toString() ?? 'N/A'} pts',
                    (pageData[j].data()
                                as Map<String, dynamic>?)?['dateTime'] !=
                            null
                        ? _formatDate((pageData[j].data()
                            as Map<String, dynamic>)['dateTime'])
                        : 'N/A',
                  ]
              ],
            );
          },
        ),
      );
    }

    return pdf.save();
  }
}
