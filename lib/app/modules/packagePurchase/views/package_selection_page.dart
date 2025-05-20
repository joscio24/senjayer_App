import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senjayer/app/core/theme.dart';
import 'package:senjayer/widgets/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PackageSelectionPage extends StatefulWidget {
  const PackageSelectionPage({Key? key}) : super(key: key);

  @override
  State<PackageSelectionPage> createState() => _PackageSelectionPageState();
}

class _PackageSelectionPageState extends State<PackageSelectionPage> {
  String selectedPackage = '';

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

  @override
  void initState() {
    super.initState();
    _loadSelectedPackage();
  }

  Future<void> _loadSelectedPackage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedPackage = prefs.getString('selected_package') ?? '';
    });
  }

  Future<void> _saveSelectedPackage(String package) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_package', package);
    setState(() {
      selectedPackage = package;
    });
    Get.snackbar("Choix enregistré", "Vous avez sélectionné l’offre $package");
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

  Widget _buildPackageCard({
    required String title,
    required String tag,
    required Color color,
    required List<String> included,
    required List<String> excluded,
  }) {
    final isSelected = selectedPackage == tag;

    return GestureDetector(
      onTap: () => _saveSelectedPackage(tag),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(tag == 'starter' ? Icons.star_border : Icons.workspace_premium, color: color),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
                ),
                const Spacer(),
                if (isSelected) const Icon(Icons.check_circle, color: Colors.green, size: 24),
              ],
            ),
            const SizedBox(height: 16),
            ...included.map((f) => _buildFeatureRow(f, included: true)),
            ...excluded.map((f) => _buildFeatureRow(f, included: false)),
          ],
        ),
      ),
    );
  }

  void _validateAndNavigate() {
    if (selectedPackage.isEmpty) {
      Get.snackbar("Erreur", "Veuillez sélectionner une offre");
      return;
    }

    if (selectedPackage == "starter") {
      Get.offNamed("/user_events_create");
    } else if (selectedPackage == "premium") {
      Get.toNamed("/user_events_packs_payment");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Choisir un package"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildPackageCard(
              title: "Offre Starter",
              tag: 'starter',
              color: Colors.blueAccent,
              included: starterIncluded,
              excluded: premiumOnly,
            ),
            _buildPackageCard(
              title: "Offre Premium",
              tag: 'premium',
              color: Colors.purple,
              included: [...starterIncluded, ...premiumOnly],
              excluded: [],
            ),
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
