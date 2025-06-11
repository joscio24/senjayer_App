import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senjayer/app/core/theme.dart';
import 'package:senjayer/widgets/custom_button.dart';
import 'package:senjayer/widgets/custom_loader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:senjayer/api/api_services.dart';

class PackageSelectionPage extends StatefulWidget {
  const PackageSelectionPage({Key? key}) : super(key: key);

  @override
  State<PackageSelectionPage> createState() => _PackageSelectionPageState();
}

class _PackageSelectionPageState extends State<PackageSelectionPage> {
  String selectedPackage = '';
  List<Map<String, dynamic>> availablePackages = [];
  bool loading = true;

  final starterIncluded = [
    'Envoi d\'invitations',
    'Gestion de la liste d\'invités',
    'Suivi des RSVP',
    'Création de plans d\'organisation',
    'Assistance dédiée',
    'Modèles d\'invitation',
  ];

  final premiumOnly = [
    'Options de partage étendues',
    'Personnalisation avancée des invitations',
    'Gestionnaire de budget',
    'Intégrations tierces',
  ];

  int userIdfetch = 0;

  @override
  void initState() {
    super.initState();
    _getUserId();
    _loadSelectedPackage();
    _fetchAndSetPackages();
  }

  Future<void> _loadSelectedPackage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedPackage = prefs.getString('selected_package') ?? '';
    });
  }

  Future<void> _saveSelectedPackage(String packageId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_package', packageId);
    setState(() {
      selectedPackage = packageId;
    });
    Get.snackbar("Choix enregistré", "Vous avez sélectionné l’offre");
  }

  Future<void> _fetchAndSetPackages() async {
    final api = ApiService();
    final response = await api.getPackages();

    if (response != null && response["success"] == true) {
      final res = response["data"];
      final data = res['data'] as List;

      // print(data);

      setState(() {
        availablePackages = data.map((e) => e as Map<String, dynamic>).toList();
        loading = false;
      });
    } else {
      setState(() => loading = false);
      Get.snackbar(
        "Erreur",
        response?["message"] ?? "Impossible de charger les offres",
      );
    }
  }

  void _subscribeToFreePlan(Map<String, dynamic> freePlan) async {
    final firstSubscription = (freePlan["subscriptions"] as List).first;

    final payload = {
      "user_id": firstSubscription["user_id"],
      "package_id": firstSubscription["package_id"],
      "event_limit": firstSubscription["event_limit"],
      "status": 1, // or whatever default
      // add other fields if required
    };

    final response = await ApiService().postSubscription(payload);

    if (response != null && response["success"] == true) {
      Get.snackbar("Succès", "Abonnement effectué avec succès");
    } else {
      Get.snackbar("Erreur", response?["message"] ?? "Échec de l’abonnement");
    }
  }

  void _getUserId() async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve the stored string
    String? userString = prefs.getString("user");

    if (userString != null) {
      // Decode JSON into a Map
      Map<String, dynamic> userData = jsonDecode(userString);

      setState(() {
        userIdfetch = userData["id"] ?? 0; // Get 'id', default to 0 if null
      });
    } else {
      setState(() {
        userIdfetch = 0; // Default value if "user" does not exist
      });
    }
  }

  Widget _buildFeatureRow(String feature, {required bool included}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            included ? Icons.check : Icons.cancel,
            color: included ? Colors.green : Colors.redAccent,
            size: 18,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                color: included ? Colors.black : Colors.grey.shade600,
                decoration: included ? null : TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicPackageCard(
    Map<String, dynamic> package,
    bool isStarter,
  ) {
    final isSelected = selectedPackage == package['id'].toString();

    return GestureDetector(
      onTap: () => _saveSelectedPackage(package['id'].toString()),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isStarter ? Icons.star_border : Icons.workspace_premium,
                  color: Colors.blue,
                ),
                const SizedBox(width: 10),
                Text(
                  package['name'] ?? "Package",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  const Icon(Icons.check_circle, color: Colors.green, size: 24),
              ],
            ),
            const SizedBox(height: 16),
            if ((package['subscriptions'] as List?)?.isNotEmpty == true)
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text(
                  "Déjà souscrit",
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            ...starterIncluded.map((f) => _buildFeatureRow(f, included: true)),
            ...(isStarter
                ? premiumOnly.map((f) => _buildFeatureRow(f, included: false))
                : premiumOnly.map((f) => _buildFeatureRow(f, included: true))),
          ],
        ),
      ),
    );
  }

  Future<bool> _registerSubscription({
    required int userId,
    required int packageId,
    required int eventLimit,
    required bool isFree,
  }) async {
    final api = ApiService();
    final result = await api.subscribeToPackage(
      userId: userId,
      packageId: packageId,
      eventLimit: eventLimit,
    );

    if (result?['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('premium_paid', !isFree);
      await prefs.setInt('event_limit', eventLimit);
      await prefs.setInt('package_id', packageId);
      return true;
    }

    return false;
  }

  // void _validateAndNavigate() async {
  //   if (selectedPackage.isEmpty) {
  //     Get.snackbar("Erreur", "Veuillez sélectionner une offre");
  //     return;
  //   }

  //   final selected = availablePackages.firstWhere(
  //     (p) => p['id'].toString() == selectedPackage,
  //   );

  //   final isFree = selected['price'] == 0;
  //   final userId = userIdfetch;
  //   final packageId = selected['id'];
  //   final eventLimit = selected['event_limit'] ?? 3;

  //   bool success = await _registerSubscription(
  //     userId: userId,
  //     packageId: packageId,
  //     eventLimit: eventLimit,
  //     isFree: isFree,
  //   );

  //   if (success) {
  //     if (isFree) {
  //       Get.offNamed("/user_events_create", arguments: selected);
  //     } else {
  //       Get.toNamed("/user_events_packs_payment", arguments: selected);
  //     }
  //   } else {
  //     Get.snackbar("Erreur", "Échec de la souscription");
  //   }
  // }

  void _validateAndNavigate() async {
    if (selectedPackage.isEmpty) {
      Get.snackbar("Erreur", "Veuillez sélectionner une offre");
      return;
    }

    final selected = availablePackages.firstWhere(
      (p) => p['id'].toString() == selectedPackage,
    );

    final isFree = selected['price'] == 0;
    final userId = userIdfetch;
    final packageId = selected['id'];
    final eventLimit = selected['event_limit'] ?? 3;

    final alreadySubscribed =
        (selected['subscriptions'] as List?)?.isNotEmpty == true;

    if (alreadySubscribed) {
      // No need to subscribe or go to payment
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('premium_paid', !isFree);
      await prefs.setInt('event_limit', eventLimit);
      await prefs.setInt('package_id', packageId);

      Get.offNamed("/user_events_create", arguments: selected);
      return;
    }

    // User is not yet subscribed — continue with normal flow
    bool success = await _registerSubscription(
      userId: userId,
      packageId: packageId,
      eventLimit: eventLimit,
      isFree: isFree,
    );

    if (success) {
      if (isFree) {
        Get.offNamed("/user_events_create", arguments: selected);
      } else {
        Get.toNamed("/user_events_packs_payment", arguments: selected);
      }
    } else {
      Get.snackbar("Erreur", "Échec de la souscription");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choisir un package"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body:
          loading
              ? const CustomLoader()
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    for (int i = 0; i < availablePackages.length; i++)
                      _buildDynamicPackageCard(availablePackages[i], i == 0),
                    const SizedBox(height: 30),
                    MainButtons(
                      text: "Valider mon choix",
                      icon: const Icon(Icons.save, color: appTheme.appWhite),
                      onPressed: _validateAndNavigate,
                    ),
                  ],
                ),
              ),
    );
  }
}
