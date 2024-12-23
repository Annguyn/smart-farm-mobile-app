import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SetIpAddressPage extends StatefulWidget {
  @override
  _SetIpAddressPageState createState() => _SetIpAddressPageState();
}

class _SetIpAddressPageState extends State<SetIpAddressPage> {
  final TextEditingController _ipController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _thresholdType = 'soilMoisture';
  double _value = 0.0;

  int lightThreshold = 2000;
  int soilMoistureThreshold = 2400;
  int temperatureHighThreshold = 35;
  int temperatureLowThreshold = 20;
  int waterLevelThreshold = 2400;

  @override
  void initState() {
    super.initState();
    _loadIpAddress();
    _value = _getDefaultThreshold(_thresholdType);
  }

  _loadIpAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? ipAddress = prefs.getString('mdnsHostname');
    if (ipAddress != null) {
      ipAddress = ipAddress.replaceFirst('http://', '').replaceFirst(':5000', '');
      _ipController.text = ipAddress;
    }
  }

  _saveIpAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ipAddress = _ipController.text;
    if (!ipAddress.startsWith('http://')) {
      ipAddress = 'http://' + ipAddress;
    }
    if (!ipAddress.endsWith(':5000')) {
      ipAddress = ipAddress + ':5000';
    }
    await prefs.setString('mdnsHostname', ipAddress);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('IP Address saved successfully!')),
    );
  }

  double _getDefaultThreshold(String type) {
    switch (type) {
      case 'soilMoisture':
        return soilMoistureThreshold.toDouble();
      case 'temperatureHigh':
        return temperatureHighThreshold.toDouble();
      case 'temperatureLow':
        return temperatureLowThreshold.toDouble();
      case 'waterLevel':
        return waterLevelThreshold.toDouble();
      case 'light':
        return lightThreshold.toDouble();
      default:
        return 0.0;
    }
  }

  Future<void> _setThreshold() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? ipAddress = prefs.getString('mdnsHostname');
    if (ipAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('IP Address not set')),
      );
      return;
    }

    final url = '$ipAddress/setThreshold';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'type': _thresholdType, 'value': _value}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Threshold set successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to set threshold: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set IP Address and Threshold'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ipController,
              decoration: InputDecoration(
                labelText: 'Flask Server IP Address',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveIpAddress,
              child: Text('Save IP Address'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),
            SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _thresholdType,
                    onChanged: (value) {
                      setState(() {
                        _thresholdType = value!;
                        _value = _getDefaultThreshold(_thresholdType);
                      });
                    },
                    items: [
                      DropdownMenuItem(value: 'soilMoisture', child: Text('Soil Moisture')),
                      DropdownMenuItem(value: 'temperatureHigh', child: Text('Temperature High')),
                      DropdownMenuItem(value: 'temperatureLow', child: Text('Temperature Low')),
                      DropdownMenuItem(value: 'waterLevel', child: Text('Water Level')),
                      DropdownMenuItem(value: 'light', child: Text('Light')),
                    ],
                    decoration: InputDecoration(labelText: 'Threshold Type'),
                  ),
                  TextFormField(
                    initialValue: _value.toString(),
                    decoration: InputDecoration(labelText: 'Value'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _value = double.parse(value);
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _setThreshold();
                      }
                    },
                    child: Text('Set Threshold'),
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