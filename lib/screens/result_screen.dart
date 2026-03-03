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

          // ==========================================
          // 1. ALL LOGIC AND DATA EXTRACTION GOES HERE
          // ==========================================
          var data = snapshot.data!.data() as Map<String, dynamic>;

          // Subject Filtering Logic
          List<DataRow> subjectRows = [];
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
            'Quran & Hifz': ['Quran_&Hifz', 'Quran_&_Hifz'],
            'Practical': ['Practical', 'Practical_'],
            'Project': ['Project', 'Project_'],
            'Thafheem': ['Thafheem'],
            'Hifz': ['Hifz'],
            'Thazkiya & Thajweed': ['Thazkiya_&_Thajweed'],
            'Total Mark': ['Total_Mark_', 'Total', 'Total_Marks'],
            'Attendance': ['Attendance'],
          };

          subjectsMap.forEach((displayName, dbKeys) {
            String? mark;
            for (String key in dbKeys) {
              if (data.containsKey(key) && data[key].toString().trim().isNotEmpty) {
                mark = data[key].toString().trim();
                break;
              }
            }
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

          // Pass/Fail and Rank Logic
          String passOrFailStr = data['Pass_or_fail']?.toString().trim().toLowerCase() ?? '';
          bool isPassed = passOrFailStr == 'pass';
          
          String rankStr = data['Rank']?.toString().trim() ?? '';
          bool hasRank = rankStr.isNotEmpty && rankStr.toLowerCase() != 'nil';

          // ==========================================
          // 2. THE UI WIDGETS START HERE
          // ==========================================
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
                        
                        // Headings
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

                        // Student Name
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

                        // --- NEW: HIGHLIGHTED RANK BANNER ---
                        if (hasRank)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.amber.shade200, Colors.amber.shade500],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.4), 
                                  blurRadius: 10, 
                                  offset: const Offset(0, 4)
                                )
                              ],
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.emoji_events, color: Colors.deepOrange, size: 48),
                                const SizedBox(height: 8),
                                Text(
                                  "Rank: $rankStr",
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.brown,
                                    letterSpacing: 1.5,
                                  ),
                                ),
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
                        if (subjectRows.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(Colors.indigo.shade50), // Updated for newer Flutter versions
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