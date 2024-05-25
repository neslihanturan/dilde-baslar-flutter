import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sexism Detector',
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
  TextEditingController _inputController = TextEditingController();
  String _response = '';
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> _submitInput() async {
    String inputData = _inputController.text;

    var response = await http.post(
      Uri.parse('http://127.0.0.1:8000/process_input/'), // Django backend url
      body: {'input_data': inputData},
    );

    Map<String, dynamic> responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        _response = responseData['processed_data'];
      });
    } else {
      setState(() {
        _response = 'İstek başarısız: ${response.reasonPhrase}';
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hibrit Uygulama'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _inputController,
                  decoration: InputDecoration(
                    hintText: 'Enter the text to detect sexism',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter something';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitInput,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: _isLoading
                      ? SpinKitThreeBounce(
                          color: Colors.white,
                          size: 20.0,
                        )
                      : Text(
                          'Submit',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
                SizedBox(height: 20),
                Text(
                  '$_response',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
