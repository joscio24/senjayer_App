import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:senjayer/app/modules/events/views/events_view.dart';
import 'package:senjayer/widgets/custom_button.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AddTicketPage extends StatefulWidget {
  final int eventId;

  const AddTicketPage({Key? key, required this.eventId}) : super(key: key);

  @override
  State<AddTicketPage> createState() => _AddTicketPageState();
}

class _AddTicketPageState extends State<AddTicketPage> {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  String _description = '';
  String? _imageUrl; 
  int? _quantity;
  double? _price;
  int? _validityDays;

  bool _isLoading = false;

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    final body = {
      'event_id': widget.eventId,
      'name': _name,
      'description': _description,
      if (_imageUrl != null && _imageUrl!.isNotEmpty) 'image_url': _imageUrl,
      'quantity': _quantity,
      'price': 0, 
      'validity_days': _validityDays,
    };

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    final url = Uri.parse('https://api.senjayer.com/api/v1/tickets');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Ticket created successfully
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ticket created successfully!')));
       Get.to(() => EventsView()); // Return success
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${error['message'] ?? 'Failed to create ticket'}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String? _validateNotEmpty(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? _validateNumber(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'This field is required';
    }
    final n = num.tryParse(val);
    if (n == null) return 'Enter a valid number';
    // if (n <= 0) return 'Must be greater than zero';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ajouter un ticket')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Ticket Name'),
                        validator: _validateNotEmpty,
                        onSaved: (val) => _name = val!.trim(),
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Description'),
                        validator: _validateNotEmpty,
                        onSaved: (val) => _description = val!.trim(),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Image URL (optional)',
                        ),
                        onSaved: (val) => _imageUrl = val?.trim(),
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Quantity'),
                        keyboardType: TextInputType.number,
                        validator: _validateNumber,
                        onSaved: (val) => _quantity = int.tryParse(val!),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Price (e.g., 20.00)',
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: _validateNumber,
                        onSaved: (val) => _price = double.tryParse(val!),
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Validity Days'),
                        keyboardType: TextInputType.number,
                        validator: _validateNumber,
                        onSaved: (val) => _validityDays = int.tryParse(val!),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MainButtons(
                          onPressed: _submitTicket,
                          text:'Create Ticket',
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
