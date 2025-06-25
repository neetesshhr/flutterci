import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LicenseScreen extends StatefulWidget {
  const LicenseScreen({super.key});
  @override
  State<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends State<LicenseScreen> {
  final _keyCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _activate() async {
    if (_keyCtrl.text.isEmpty) return;
    setState(() => _loading = true);
    try {
      final res = await http.post(
        Uri.parse('http://127.0.0.1:8000/activate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'key': _keyCtrl.text}),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Activation failed: ${data['detail'] ?? res.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activate License')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: _keyCtrl,
              decoration: const InputDecoration(labelText: 'Enter License Key'),
            ),
            const SizedBox(height: 24),
            _loading
              ? const CircularProgressIndicator()
              : ElevatedButton(onPressed: _activate, child: const Text('Activate')),
          ]),
        ),
      ),
    );
  }
}
