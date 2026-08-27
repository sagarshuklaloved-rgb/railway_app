import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const RailSaathiApp());
}

class RailSaathiApp extends StatelessWidget {
  const RailSaathiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RailSaathi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
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
  final String apiUrl =
      "https://railway-app-m4hs.onrender.com/api/trains/";

  final TextEditingController searchController =
      TextEditingController();

  List<dynamic> trains = [];
  List<dynamic> filteredTrains = [];

  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();

    fetchTrains();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showWelcomePopup();
    });

    searchController.addListener(() {
      filterTrains(searchController.text);
    });
  }

  // Welcome Popup
  void showWelcomePopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Welcome to RailSaathi 🚆",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),

              Text(
                "Your Smart Railway Companion",
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 20),

              Text(
                "Powered by Dhirit ❤️",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Fetch Live Trains
  Future<void> fetchTrains() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(
            const Duration(seconds: 20),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          trains = data['trains'] ?? [];
          filteredTrains = trains;
          isLoading = false;
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
        errorMessage =
            "Unable to connect to RailSaathi server.";
      });

      debugPrint("API Error: $e");
    }
  }

  // Search Trains
  void filterTrains(String query) {
    final search = query.toLowerCase().trim();

    setState(() {
      if (search.isEmpty) {
        filteredTrains = trains;
      } else {
        filteredTrains = trains.where((train) {
          final number =
              (train['train_no'] ?? '')
                  .toString()
                  .toLowerCase();

          final name =
              (train['name'] ?? '')
                  .toString()
                  .toLowerCase();

          return number.contains(search) ||
              name.contains(search);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Status Color
  Color statusColor(String status) {
    if (status.toLowerCase().contains("delayed")) {
      return Colors.red;
    }

    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "RailSaathi",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: fetchTrains,
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh",
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            // Search Box
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText:
                    "Search Train Number or Train Name",

                prefixIcon: const Icon(
                  Icons.search,
                ),

                suffixIcon:
                    searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              searchController.clear();
                            },
                            icon: const Icon(
                              Icons.clear,
                            ),
                          )
                        : null,

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Live Connection
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(12),
                color:
                    Colors.green.withOpacity(0.1),
              ),

              child: const Row(
                children: [
                  Icon(
                    Icons.wifi,
                    color: Colors.green,
                  ),

                  SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      "RailSaathi Live Data Connected!",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Main Content
            Expanded(
              child: isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(),
                    )
                  : errorMessage.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 50,
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              Text(errorMessage),

                              const SizedBox(
                                height: 15,
                              ),

                              ElevatedButton(
                                onPressed:
                                    fetchTrains,
                                child:
                                    const Text(
                                  "Retry",
                                ),
                              ),
                            ],
                          ),
                        )
                      : filteredTrains.isEmpty
                          ? const Center(
                              child: Text(
                                "No trains found",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount:
                                  filteredTrains.length,

                              itemBuilder:
                                  (context, index) {
                                final train =
                                    filteredTrains[
                                        index];

                                final status =
                                    train['status']
                                            ?.toString() ??
                                        "";

                                return Card(
                                  margin:
                                      const EdgeInsets
                                          .only(
                                    bottom: 12,
                                  ),

                                  child: ListTile(
                                    // Train Details Popup
                                    onTap: () {
                                      showDialog(
                                        context:
                                            context,
                                        builder:
                                            (context) {
                                          return AlertDialog(
                                            title:
                                                Text(
                                              "${train['train_no']} - ${train['name']}",
                                            ),

                                            content:
                                                Column(
                                              mainAxisSize:
                                                  MainAxisSize
                                                      .min,

                                              crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,

                                              children: [
                                                Text(
                                                  "Train Number: ${train['train_no']}",
                                                ),

                                                const SizedBox(
                                                  height:
                                                      8,
                                                ),

                                                Text(
                                                  "Train Name: ${train['name']}",
                                                ),

                                                const SizedBox(
                                                  height:
                                                      8,
                                                ),

                                                Text(
                                                  "Time: ${train['time']}",
                                                ),

                                                const SizedBox(
                                                  height:
                                                      8,
                                                ),

                                                Text(
                                                  "Status: ${train['status']}",
                                                ),
                                              ],
                                            ),

                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () {
                                                  Navigator.pop(
                                                    context,
                                                  );
                                                },
                                                child:
                                                    const Text(
                                                  "Close",
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },

                                    leading:
                                        const CircleAvatar(
                                      child: Icon(
                                        Icons.train,
                                      ),
                                    ),

                                    title: Text(
                                      "${train['train_no']} - ${train['name']}",
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),

                                    subtitle:
                                        Padding(
                                      padding:
                                          const EdgeInsets
                                              .only(
                                        top: 6,
                                      ),

                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,

                                        children: [
                                          Text(
                                            "Departure: ${train['time']}",
                                          ),

                                          const SizedBox(
                                            height: 4,
                                          ),

                                          Text(
                                            status,
                                            style:
                                                TextStyle(
                                              color:
                                                  statusColor(
                                                      status),
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                          ),
                                        ],
                                      ),
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