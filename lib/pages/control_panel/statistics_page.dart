import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  List<dynamic> sensorData = [];
  bool isLoading = true;
  String selectedTimeframe = 'Hour';
  String selectedSensor = 'Humidity';

  @override
  void initState() {
    super.initState();
    fetchSensorData();
  }

  Future<void> fetchSensorData() async {
    await Future.delayed(Duration(seconds: 1));
    sensorData = [
      {
        'timestamp': '2024-11-01 10:00:00',
        'humidity': 45,
        'temperature': 25,
        'soil_moisture': 30,
        'pump_status': 'On',
      },
      {
        'timestamp': '2024-11-01 11:00:00',
        'humidity': 50,
        'temperature': 26,
        'soil_moisture': 28,
        'pump_status': 'Off',
      },
      {
        'timestamp': '2024-11-01 12:00:00',
        'humidity': 48,
        'temperature': 27,
        'soil_moisture': 35,
        'pump_status': 'On',
      },
    ];

    setState(() {
      isLoading = false;
    });
  }

  List<FlSpot> getChartData() {
    List<FlSpot> spots = [];
    for (int i = 0; i < sensorData.length; i++) {
      double xValue = i.toDouble();
      double yValue;

      switch (selectedSensor) {
        case 'Humidity':
          yValue = sensorData[i]['humidity'].toDouble();
          break;
        case 'Temperature':
          yValue = sensorData[i]['temperature'].toDouble();
          break;
        case 'Soil Moisture':
          yValue = sensorData[i]['soil_moisture'].toDouble();
          break;
        default:
          yValue = sensorData[i]['humidity'].toDouble();
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
              items: <String>['Humidity', 'Temperature', 'Soil Moisture']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(fontSize: 16)),
                );
              }).toList(),
              isExpanded: true,
            ),
            SizedBox(height: 20),
            // Line chart
            Expanded(
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
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
              child: ListView.builder(
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
                          Text('Humidity: ${item['humidity']}%'),
                          Text('Temperature: ${item['temperature']}°C'),
                          Text('Soil Moisture: ${item['soil_moisture']}%'),
                          Text('Pump Status: ${item['pump_status']}'),
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
