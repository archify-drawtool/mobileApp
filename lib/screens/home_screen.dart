import 'package:flutter/material.dart';
import 'package:archify_app/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  String _status = 'Loading...';

  @override
  void initState() {
    super.initState();
    _checkHealth();
  }

  Future<void> _checkHealth() async {
    final status = await _apiService.checkHealth();
    setState(() {
      _status = 'API status: $status';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archify'),
      ),
      body: Center(
        child: Text(
          _status,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
