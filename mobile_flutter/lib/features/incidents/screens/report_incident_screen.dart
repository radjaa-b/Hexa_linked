import 'package:flutter/material.dart';

class ReportIncidentScreen extends StatelessWidget {
  const ReportIncidentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Alert'),
      ),
      body: const Center(
        child: Text('Report incident screen'),
      ),
    );
  }
}