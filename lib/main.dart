import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TrainScreen(),
    );
  }
}

class TrainScreen extends StatefulWidget {
  const TrainScreen({super.key});

  @override
  State<TrainScreen> createState() => _TrainScreenState();
}

class _TrainScreenState extends State<TrainScreen> {
  // नोट: अगर आप Android Emulator चला रहे हैं, तो 127.0.0.1 की जगह 10.0.2.2 लिखें
  final String apiUrl = "http://127.0.0.1:8000/api/trains/";
  
  Map<String, dynamic> trainData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTrains();
  }

  Future<void> fetchTrains() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          trainData = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("RailSaathi Live")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trainData['message'] ?? "",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: trainData['trains']?.length ?? 0,
                      itemBuilder: (context, index) {
                        var train = trainData['trains'][index];
                        return Card(
                          child: ListTile(
                            title: Text("${train['train_no']} - ${train['name']}"),
                            subtitle: Text("Time: ${train['time']} | Status: ${train['status']}"),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}