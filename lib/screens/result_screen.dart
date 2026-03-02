import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResultScreen extends StatelessWidget {
  final String rollNumber;

  const ResultScreen({super.key, required this.rollNumber});

  // Helper widget to generate rows for the DataTable easily
  DataRow _buildDataRow(String subjectName, Map<String, dynamic> data, String dbKey) {
    return DataRow(
      cells: [
        DataCell(Text(subjectName, style: const TextStyle(fontWeight: FontWeight.w600))),
        DataCell(Text(data[dbKey]?.toString() ?? '-')),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Result'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      // We use FutureBuilder because we only need to read the result once when the page loads
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('results').doc(rollNumber).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                "No result found for Register Number: $rollNumber",
                style: const TextStyle(fontSize: 18, color: Colors.red),
              ),
            );
          }

          // Extract data
          var data = snapshot.data!.data() as Map<String, dynamic>;
          
          // Check Pass/Fail status (handles uppercase/lowercase variations from sheets)
          String passOrFailStr = data['Pass_or_fail']?.toString().trim().toLowerCase() ?? '';
          bool isPassed = passOrFailStr == 'pass';

          return SingleChildScrollView(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    
                    // 1. Congratulations Banner
                    if (isPassed)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green),
                        ),
                        child: const Text(
                          "🎉 CONGRATULATIONS! You have passed! 🎉",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 22, color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ),

                    // 2. Student Info Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(data['Name']?.toString() ?? 'Unknown Name', 
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            const Divider(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _InfoItem(title: "Register No", value: data['Register_Number']?.toString() ?? '-'),
                                _InfoItem(title: "Class", value: data['Class']?.toString() ?? '-'),
                                _InfoItem(title: "Rank", value: data['Rank']?.toString() ?? '-'),
                                _InfoItem(title: "Attendance", value: data['Attendance']?.toString() ?? '-'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 3. Marks Table
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(Colors.indigo.shade50),
                          columns: const [
                            DataColumn(label: Text('Subject', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                            DataColumn(label: Text('Marks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                          ],
                          rows: [
                            _buildDataRow('Thajveed', data, 'Thajveed'),
                            _buildDataRow('Kithabath', data, 'Kithabath'),
                            _buildDataRow('Fiqh', data, 'Fiqh'),
                            _buildDataRow('Thazkiya', data, 'Thazkiya'),
                            _buildDataRow('Thareekh', data, 'Thareekh'),
                            _buildDataRow('Duroos', data, 'Duroos'),
                            _buildDataRow('Duroos 1', data, 'Duroos_1'),
                            _buildDataRow('Duroos 2', data, 'Duroos_2'),
                            _buildDataRow('Aqaeda', data, 'Aqaeda'),
                            _buildDataRow('Quran & Hifz', data, 'Quran_&Hifz'),
                            _buildDataRow('Practical', data, 'Practical'),
                            _buildDataRow('Project', data, 'Project'),
                            _buildDataRow('Thafheem', data, 'Thafheem'),
                            _buildDataRow('Hifz', data, 'Hifz'),
                            _buildDataRow('Thazkiya & Thajweed', data, 'Thazkiya_&_Thajweed'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Small UI helper widget for the top card
class _InfoItem extends StatelessWidget {
  final String title;
  final String value;
  const _InfoItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}