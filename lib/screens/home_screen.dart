import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _selectedImage;
  String? _prediction;
  bool _loading = false;

  Future<void> selectImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedImage = File(result.files.single.path!);
        _prediction = null;
      });
    }
  }

  Future<void> sendToModel() async {
    if (_selectedImage == null) return;

    setState(() {
      _loading = true;
      _prediction = null;
    });

    try {
      var req = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:8000/predict'), // Replace with LAN IP if needed
      );
      req.files.add(await http.MultipartFile.fromPath('file', _selectedImage!.path));

      var response = await req.send();
      var body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(body);
        final preds = data['predictions'] as List?;
        setState(() {
          _prediction = (preds == null || preds.isEmpty)
              ? (data['message'] ?? 'No prediction')
              : preds
                  .map((p) =>
                      "${p['label']}: ${(p['confidence'] * 100).toStringAsFixed(1)}%")
                  .join("\n");
        });
      } else {
        setState(() => _prediction = 'Server error: $body');
      }
    } catch (e) {
      setState(() => _prediction = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ZemedicAI Desktop')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "Form-like" file input field
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    enabled: false,
                    controller: TextEditingController(
                        text: _selectedImage?.path.split(Platform.pathSeparator).last ?? ''),
                    decoration: const InputDecoration(
                      labelText: 'Selected Image',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: selectImage,
                  child: const Text('Choose File'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Image preview
            if (_selectedImage != null)
              Center(
                child: Image.file(
                  _selectedImage!,
                  height: 240,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: (_selectedImage == null || _loading) ? null : sendToModel,
              icon: _loading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: Text(_loading ? 'Predicting...' : 'Predict'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
            const SizedBox(height: 24),

            if (_prediction != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _prediction!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
