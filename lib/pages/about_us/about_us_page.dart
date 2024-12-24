import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us - An Smart Farm IoT'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              _buildSectionTitle('Our Mission'),
              _buildCard(
                context,
                'At An Smart Farm IoT, we strive to revolutionize agriculture through cutting-edge technology. Our mission is to empower farmers and gardeners by providing innovative solutions to monitor, manage, and optimize their crops efficiently and sustainably.',
              ),
              SizedBox(height: 20),
              _buildSectionTitle('Our Story'),
              _buildCard(
                context,
                'Founded by a team of agricultural enthusiasts and tech innovators, An Smart Farm IoT was born out of a passion for smart farming. We envisioned a future where technology simplifies agriculture, enabling sustainable practices and maximizing productivity.',
              ),
              SizedBox(height: 20),
              _buildSectionTitle('What We Offer'),
              _buildCard(
                context,
                'We provide an array of smart farming solutions tailored for modern agriculture:\n'
                    '- Automated Water Pumping Systems\n'
                    '- Intelligent Lighting Control\n'
                    '- Live Camera Monitoring\n'
                    '- Smart Ventilation and Shade Management\n'
                    '- AI-powered Leaf Disease Prediction\n'
                    '- Comprehensive Analytics for Optimal Crop Health\n'
                    '- IoT-Enabled Device Control',
              ),
              SizedBox(height: 20),
              _buildSectionTitle('Get Involved'),
              _buildCard(
                context,
                'Join our journey towards smarter and more sustainable farming. Whether you are a hobbyist, professional farmer, or technology enthusiast, you can become part of our vibrant community and contribute to the future of agriculture!',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.teal,
      ),
    );
  }

  Widget _buildCard(BuildContext context, String description) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          description,
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}
