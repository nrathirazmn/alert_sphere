import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Change this to your backend address (if running locally, use your machine IP or 10.0.2.2 for emulator)
const String backendBase = 'http://10.0.2.2:8000';

void main() {
  runApp(AlerSphereApp());
}

class AlerSphereApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlerSphere',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List reports = [];
  bool loading = false;
  final _descCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future fetchReports() async {
    setState(() => loading = true);
    try {
      final res = await http.get(Uri.parse('\$backendBase/reports'));
      if (res.statusCode == 200) {
        setState(() {
          reports = jsonDecode(res.body);
        });
      }
    } catch (e) {
      print('Error: \$e');
    } finally {
      setState(() => loading = false);
    }
  }

  Future submitReport() async {
    final desc = _descCtrl.text.trim();
    final title = _titleCtrl.text.trim();
    if (desc.isEmpty) return;
    final payload = {'description': desc, 'title': title};
    try {
      final res = await http.post(Uri.parse('\$backendBase/reports'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload));
      if (res.statusCode == 200 || res.statusCode == 201) {
        _descCtrl.clear();
        _titleCtrl.clear();
        fetchReports();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Report submitted')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: \$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AlerSphere')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleCtrl,
                  decoration: InputDecoration(labelText: 'Title (optional)'),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _descCtrl,
                  decoration: InputDecoration(labelText: 'Describe the incident'),
                  maxLines: 3,
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: submitReport,
                      child: Text('Submit Report'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: fetchReports,
                      child: Text('Refresh'),
                    ),
                  ],
                )
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: loading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: reports.length,
                    itemBuilder: (context, i) {
                      final r = reports[i];
                      return ListTile(
                        title: Text(r['title'] != '' ? r['title'] : r['category']),
                        subtitle: Text(r['description'] + '\n' + (r['created_at'] ?? '')),
                        isThreeLine: true,
                        trailing: Text(r['severity'].toString()),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
