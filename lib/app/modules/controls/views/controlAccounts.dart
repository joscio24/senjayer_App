import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class Controlaccounts extends StatefulWidget {
  const Controlaccounts({super.key});

  @override
  State<Controlaccounts> createState() => _ControlaccountsState();
}

class _ControlaccountsState extends State<Controlaccounts> {
  List<Map<String, dynamic>> userSubscriptions = [];
  bool isLoading = true;
  int userId = 0;

  final Dio _dio = Dio(); // Add your custom interceptor if needed

  @override
  void initState() {
    super.initState();
    fetchSubscriptions();
  }

  Future<void> fetchSubscriptions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    userId = prefs.getInt("user_id") ?? 0;

    try {
      final response = await _dio.get(
        'https://api.senjayer.com/api/v1/packages',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('📦 Packages Response: ${response.data}');
      if (response.statusCode == 200) {
        final List packages = response.data['data'];
        final List<Map<String, dynamic>> filteredSubscriptions = [];

        for (var package in packages) {
          final List subs = package['subscriptions'];
          for (var sub in subs) {
            
              filteredSubscriptions.add({
                'package_name': package['name'],
                'description': package['description'],
                'event_limit': sub['event_limit'],
                'price': package['price'],
                'subscribed_at': sub['created_at'],
              });
              break; // Add once per package
            
          }
        }

        setState(() {
          userSubscriptions = filteredSubscriptions;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching packages: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mes abonnements")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : userSubscriptions.isEmpty
              ? const Center(child: Text("Aucun abonnement trouvé."))
              : ListView.builder(
                itemCount: userSubscriptions.length,
                itemBuilder: (context, index) {
                  final item = userSubscriptions[index];
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(item['package_name']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['description']),
                          Text("Limite d'évènements: ${item['event_limit']}"),
                          Text("Prix: ${item['price']} F"),
                          Text("Souscrit le: ${item['subscribed_at']}"),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
