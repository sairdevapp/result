import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResultScreen extends StatelessWidget {
  final String rollNumber;

  const ResultScreen({super.key, required this.rollNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Result'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
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

          // 1. Logic to filter out empty/nil subjects dynamically
          List<DataRow> subjectRows = [];
          
          // The keys on the right MUST exactly match the field names in your Firestore database.
          // If a field is still missing, check your Firestore document to see exactly how it is spelled!
          Map<String, List<String>> subjectsMap = {
            'Thajveed': ['Thajveed'],
            'Kithabath': ['Kithabath'],
            'Fiqh': ['Fiqh'],
            'Thazkiya': ['Thazkiya'],
            'Thareekh': ['Thareekh'],
            'Duroos': ['Duroos'],
            'Duroos 1': ['Duroos_1'],
            'Duroos 2': ['Duroos_2'],
            'Aqaeda': ['Aqaeda'],
            'Quran & Hifz': ['Quran_&Hifz', 'Quran_&_Hifz'], // Checking common variations
            'Practical': ['Practical', 'Practical_'], // Accounts for trailing spaces in sheet
            'Project': ['Project', 'Project_'],
            'Thafheem': ['Thafheem'],
            'Hifz': ['Hifz'],
            'Thazkiya & Thajweed': ['Thazkiya_&_Thajweed'],
            'Attendance': ['Attendance'],
            'Total Mark': ['Total_Mark', 'Total', 'Total_Marks'], // Added Total Mark
          };

          subjectsMap.forEach((displayName, dbKeys) {
            String? mark;
            
            // Look through the possible database keys for this subject
            for (String key in dbKeys) {
              if (data.containsKey(key) && data[key].toString().trim().isNotEmpty) {
                mark = data[key].toString().trim();
                break; // Stop looking once we find the value
              }
            }

            // Only add the row if the mark exists and is not "nil"
            if (mark != null && mark.toLowerCase() != 'nil') {
              subjectRows.add(
                DataRow(
                  cells: [
                    DataCell(Text(displayName, style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text(mark)),
                  ],
                ),
              );
            }
          });
          // Check Pass/Fail status
          String passOrFailStr = data['Pass_or_fail']?.toString().trim().toLowerCase() ?? '';
          bool isPassed = passOrFailStr == 'pass';

          return SingleChildScrollView(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                padding: const EdgeInsets.all(20),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        
                        // --- NEW HEADERS ---
                        const Text(
                          "ISLAMIC EDUCATIONAL BOARD",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.indigo),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Al Madrasathul Irshadhiyya",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.indigo.shade400),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Examination Result",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, decoration: TextDecoration.underline),
                        ),
                        const SizedBox(height: 24),

                        // --- STUDENT INFO ---
                        Text(
                          data['Name']?.toString() ?? 'Unknown Name',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),

                        // Regno and Class Row
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Regno: ${data['Register_Number']?.toString() ?? '-'}",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Class: ${data['Class']?.toString() ?? '-'}",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Optional: Rank and Attendance (if you still want them displayed)
                        if (data['Rank'] != null && data['Rank'].toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Rank: ${data['Rank'] ?? '-'}", 
                                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
                              ],
                            ),
                          ),

                        // --- CONGRATULATIONS BANNER ---
                        if (isPassed)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green),
                            ),
                            child: const Text(
                              "🎉 CONGRATULATIONS! You have passed! 🎉",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                          ),

                        // --- MARKS TABLE ---
                        // Only renders the subjects that had marks
                        if (subjectRows.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(Colors.indigo.shade50),
                              columns: const [
                                DataColumn(label: Text('Subject Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                                DataColumn(label: Text('Mark', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                              ],
                              rows: subjectRows,
                            ),
                          )
                        else
                          const Center(
                            child: Text(
                              "No marks recorded for this student.",
                              style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}