import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:An_Smart_Farm_IOT/constants.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  List<dynamic> sensorData = [];
  bool isLoading = true;
  String selectedTimeframe = 'Hour';
  String selectedSensor = 'Distance';

  @override
  void initState() {
    super.initState();
    fetchSensorData();
  }

  Future<void> fetchSensorData() async {
    setState(() {
      isLoading = true;
    });

    try {
      String filterValue;

      if (selectedTimeframe.toLowerCase() == 'day') {
        filterValue = DateTime.now().toIso8601String().split('T').first;
      } else if (selectedTimeframe.toLowerCase() == 'hour') {
        filterValue = DateTime.now().toIso8601String();
      } else if (selectedTimeframe.toLowerCase() == 'month') {
        filterValue = DateTime.now().toIso8601String().substring(0, 7) + '-01';
      } else {
        throw Exception('Invalid filter type');
      }

      String hostname = await getMdnsHostname();
      final response = await http.get(Uri.parse(
          '$hostname/statistics?filter_type=${selectedTimeframe.toLowerCase()}&filter_value=$filterValue'));
      if (response.statusCode == 200) {
        sensorData = json.decode(response.body);
      } else {
        showError("Failed to load sensor data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      showError("An error occurred: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  List<FlSpot> getChartData() {
    return List<FlSpot>.generate(
      sensorData.length,
          (i) => FlSpot(i.toDouble(), sensorData[i][selectedSensor.toLowerCase()]?.toDouble() ?? 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sensor Data Statistics'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchSensorData,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedTimeframe,
                    decoration: InputDecoration(
                      labelText: 'Timeframe',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedTimeframe = newValue!;
                        fetchSensorData();
                      });
                    },
                    items: ['Hour', 'Day', 'Month', 'Week', 'Year']
                        .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                        .toList(),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedSensor,
                    decoration: InputDecoration(
                      labelText: 'Sensor',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSensor = newValue!;
                      });
                    },
                    items: [
                      'Distance',
                      'Humidity',
                      'Temperature',
                      'Soil Moisture',
                      'Light',
                      'Rain Status',
                      'Sound Status',
                      'Water Level Status',
                      'Fan Status',
                      'Curtain Status',
                      'Automatic Fan',
                      'Automatic Pump',
                      'Automatic Curtain',
                    ].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            isLoading
                ? Expanded(child: Center(child: CircularProgressIndicator()))
                : sensorData.isEmpty
                ? Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, size: 64, color: Colors.grey),
                    SizedBox(height: 10),
                    Text('No data available.', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            )
                : Expanded(
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: getChartData(),
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 4,
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                          ),
                        ),
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: true),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    flex: 3,
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                      ),
                      itemCount: sensorData.length,
                      itemBuilder: (context, index) {
                        final item = sensorData[index];
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Timestamp: ${item['timestamp']}', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text('Distance: ${item['distance']} cm'),
                                  Text('Humidity: ${item['humidity']}%'),
                                  Text('Temperature: ${item['temperature']}°C'),
                                  Text('Soil Moisture: ${item['soil_moisture']}%'),
                                  Text('Pump Status: ${item['pump_status']}'),
                                  Text('Light: ${item['light']}'),
                                  Text('Rain Status: ${item['rain_status']}'),
                                  Text('Sound Status: ${item['sound_status']}'),
                                  Text('Water Level Status: ${item['waterLevelStatus']}'),
                                  Text('Fan Status: ${item['fanStatus']}'),
                                  Text('Curtain Status: ${item['curtainStatus']}'),
                                  Text('Automatic Fan: ${item['automaticFan']}'),
                                  Text('Automatic Pump: ${item['automaticPump']}'),
                                  Text('Automatic Curtain: ${item['automaticCurtain']}'),
                                ]
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
