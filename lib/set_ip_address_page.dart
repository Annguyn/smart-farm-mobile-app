import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetIpAddressPage extends StatefulWidget {
  @override
  _SetIpAddressPageState createState() => _SetIpAddressPageState();
}

class _SetIpAddressPageState extends State<SetIpAddressPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadIpAddress();
  }

  _loadIpAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? ipAddress = prefs.getString('mdnsHostname');
    if (ipAddress != null) {
      _controller.text = ipAddress;
    }
  }

  _saveIpAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('mdnsHostname', _controller.text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('IP Address saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set IP Address'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Flask Server IP Address',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveIpAddress,
              child: Text('Save'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),
          ],
        ),
      ),
    );
  }
}