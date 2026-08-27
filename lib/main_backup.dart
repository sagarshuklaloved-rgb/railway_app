import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RailSaathi',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const TrainScreen(),
    );
  }
}

class TrainScreen extends StatefulWidget {
  const TrainScreen({super.key});

  @override
  State<TrainScreen> createState() => _TrainScreenState();
}

class _TrainScreenState extends State<TrainScreen> {
  // Live Django API
  final String apiUrl =
      "https://railway-app-m4hs.onrender.com/api/trains/";

  Map<String, dynamic> trainData = {};
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchTrains();
  }

  Future<void> fetchTrains() async {
    try {
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        setState(() {
          trainData = json.decode(response.body);
          isLoading = false;
          errorMessage = "";
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage =
              "Server Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "API Connection Failed";
      });

      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RailSaathi Live"),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 50,
                      ),
                      const SizedBox(height: 15),
                      Text(errorMessage),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                            errorMessage = "";
                          });
                          fetchTrains();
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        trainData['message'] ?? "",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount:
                              trainData['trains']?.length ?? 0,
                          itemBuilder:
                              (context, index) {
                            final train =
                                trainData['trains'][index];

                            return Card(
                              child: ListTile(
                                leading: const Icon(
                                  Icons.train,
                                ),
                                title: Text(
                                  "${train['train_no']} - ${train['name']}",
                                ),
                                subtitle: Text(
                                  "Time: ${train['time']} | "
                                  "Status: ${train['status']}",
                                ),
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