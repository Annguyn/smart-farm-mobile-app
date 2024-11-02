import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      isLoading = true; // Show loading indicator when fetching data
    });

    try {
      String filterValue;

      // Determine the filter value based on the selected timeframe
      if (selectedTimeframe.toLowerCase() == 'day') {
        filterValue = DateTime.now().toIso8601String().split('T').first; // Get current date
      } else if (selectedTimeframe.toLowerCase() == 'hour') {
        filterValue = DateTime.now().toIso8601String(); // Get current date and time
      } else if (selectedTimeframe.toLowerCase() == 'month') {
        filterValue = DateTime.now().toIso8601String().substring(0, 7) + '-01'; // Get first day of the current month
      } else {
        throw Exception('Invalid filter type');
      }

      // Construct the request URL
      final response = await http.get(Uri.parse(
          'http://192.168.1.7:5000/statistics?filter_type=${selectedTimeframe.toLowerCase()}&filter_value=$filterValue'));

      if (response.statusCode == 200) {
        sensorData = json.decode(response.body);
      } else {
        showError("Failed to load sensor data. xStatus code: ${response.statusCode}");
      }
    } catch (e) {
      showError("An error occurred: $e");
    }

    setState(() {
      isLoading = false; // Hide loading indicator after data is fetched
    });
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  List<FlSpot> getChartData() {
    List<FlSpot> spots = [];
    for (int i = 0; i < sensorData.length; i++) {
      double xValue = i.toDouble();
      double yValue;

      switch (selectedSensor) {
        case 'Distance':
          yValue = sensorData[i][6].toDouble(); // Adjusted index
          break;
        case 'Humidity':
          yValue = sensorData[i][2].toDouble(); // Adjusted index
          break;
        case 'Temperature':
          yValue = sensorData[i][3].toDouble(); // Adjusted index
          break;
        case 'Soil Moisture':
          yValue = sensorData[i][4].toDouble(); // Adjusted index
          break;
        default:
          yValue = sensorData[i][6].toDouble(); // Adjusted index
      }

      spots.add(FlSpot(xValue, yValue));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sensor Data Statistics'),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButton<String>(
              value: selectedTimeframe,
              onChanged: (String? newValue) {
                setState(() {
                  selectedTimeframe = newValue!;
                  fetchSensorData();
                });
              },
              items: <String>['Hour', 'Day', 'Month']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(fontSize: 16)),
                );
              }).toList(),
              isExpanded: true,
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: selectedSensor,
              onChanged: (String? newValue) {
                setState(() {
                  selectedSensor = newValue!;
                });
              },
              items: <String>[
                'Distance',
                'Humidity',
                'Temperature',
                'Soil Moisture'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(fontSize: 16)),
                );
              }).toList(),
              isExpanded: true,
            ),
            SizedBox(height: 20),
            Expanded(
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: getChartData(),
                      isCurved: true,
                      color: Colors.blue,
                      belowBarData: BarAreaData(show: false),
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Sensor Readings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: sensorData.isEmpty
                  ? Center(child: Text('No data available'))
                  : ListView.builder(
                itemCount: sensorData.length,
                itemBuilder: (context, index) {
                  final item = sensorData[index];
                  return Card(
                    margin: EdgeInsets.all(10),
                    elevation: 4,
                    child: ListTile(
                      title: Text(
                        'Timestamp: ${item[1]}', // Match with your database index
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Distance: ${item[6]} cm'), // Adjusted index
                          Text('Humidity: ${item[2]}%'), // Adjusted index
                          Text('Temperature: ${item[3]}°C'), // Adjusted index
                          Text('Soil Moisture: ${item[4]}%'), // Adjusted index
                          Text('Pump Status: ${item[5]}'), // Adjusted index
                        ],
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
