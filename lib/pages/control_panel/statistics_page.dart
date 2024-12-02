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
        filterValue = DateTime.now().toIso8601String().split('T').first; // Get current date
      } else if (selectedTimeframe.toLowerCase() == 'hour') {
        filterValue = DateTime.now().toIso8601String(); // Get current date and time
      } else if (selectedTimeframe.toLowerCase() == 'month') {
        filterValue = DateTime.now().toIso8601String().substring(0, 7) + '-01'; // Get first day of the current month
      } else {
        throw Exception('Invalid filter type');
      }

      String hostname = await getMdnsHostname();
      final response = await http.get(Uri.parse(
          '$hostname/statistics?filter_type=${selectedTimeframe.toLowerCase()}&filter_value=$filterValue'));
      print("Url : " + Uri.parse('$hostname/statistics?filter_type=${selectedTimeframe.toLowerCase()}&filter_value=$filterValue').toString());

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
          yValue = sensorData[i]['distance'].toDouble();
          break;
        case 'Humidity':
          yValue = sensorData[i]['humidity'].toDouble();
          break;
        case 'Temperature':
          yValue = sensorData[i]['temperature'].toDouble();
          break;
        case 'Soil Moisture':
          yValue = sensorData[i]['soil_moisture'].toDouble();
          break;
        case 'Light':
          yValue = sensorData[i]['light'].toDouble();
          break;
        case 'Rain Status':
          yValue = sensorData[i]['rain_status'].toDouble();
          break;
        case 'Sound Status':
          yValue = sensorData[i]['sound_status'].toDouble();
          break;
        case 'Water Level Status':
          yValue = sensorData[i]['waterLevelStatus'].toDouble();
          break;
        case 'Fan Status':
          yValue = sensorData[i]['fanStatus'].toDouble();
          break;
        case 'Curtain Status':
          yValue = sensorData[i]['curtainStatus'].toDouble();
          break;
        case 'Automatic Fan':
          yValue = sensorData[i]['automaticFan'].toDouble();
          break;
        case 'Automatic Pump':
          yValue = sensorData[i]['automaticPump'].toDouble();
          break;
        case 'Automatic Curtain':
          yValue = sensorData[i]['automaticCurtain'].toDouble();
          break;
        default:
          yValue = sensorData[i]['distance'].toDouble();
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
              items: <String>['Hour', 'Day', 'Month', 'Week', 'Year']
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
                'Soil Moisture',
                'Light',
                'Rain Status',
                'Sound Status',
                'Water Level Status',
                'Fan Status',
                'Curtain Status',
                'Automatic Fan',
                'Automatic Pump',
                'Automatic Curtain'
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
                        'Timestamp: ${item['timestamp']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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