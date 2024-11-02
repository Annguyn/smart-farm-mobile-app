import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Our Mission',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Our mission is to leverage technology to enhance agricultural practices and promote sustainability. We aim to provide innovative solutions that empower farmers and gardeners to monitor and manage their plants effectively.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Our Story',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Founded by a passionate group of agricultural enthusiasts and tech innovators, our project began with the vision of creating smart garden solutions. We believe that with the right tools and information, everyone can grow their own food sustainably.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'What We Offer',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'We offer a variety of smart gardening tools and applications, including:\n'
                  '1. Real-time monitoring of plant health\n'
                  '2. Automated watering systems\n'
                  '3. Data analytics for better crop management\n'
                  '4. Remote control of garden devices\n'
                  '5. Community support and resources for gardeners',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Get Involved',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Join us in our journey towards smarter and more sustainable gardening. Whether you are a hobbyist, a professional farmer, or simply curious about gardening technology, there is a place for you in our community!',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
