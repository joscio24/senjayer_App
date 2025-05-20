import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:senjayer/widgets/custom_button.dart';
import 'package:flutter/services.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _cardFormKey = GlobalKey<FormState>();
  final _mobileFormKey = GlobalKey<FormState>();
  final _electronicFormKey = GlobalKey<FormState>();

  final cardNumber = TextEditingController();
  final cardName = TextEditingController();
  final expiryDate = TextEditingController();
  final cvv = TextEditingController();
  final mobileNumber = TextEditingController();
  final email = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  Future<void> _confirmPayment() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('premium_paid', true);
    setState(() => isLoading = false);
    Get.snackbar("Paiement validé", "Merci pour votre souscription Premium !");
    Get.offNamed("/user_events_create");
  }

  void _validateAndPay() {
    final currentTab = _tabController.index;
    final isValid = [
      _cardFormKey.currentState?.validate(),
      _mobileFormKey.currentState?.validate(),
      _electronicFormKey.currentState?.validate(),
    ][currentTab] ?? false;

    if (isValid) {
      _confirmPayment();
    } else {
      Get.snackbar("Erreur", "Veuillez compléter les champs requis.");
    }
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paiement Premium", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.credit_card), text: "Carte"),
            Tab(icon: Icon(Icons.phone_android), text: "Mobile Money"),
            Tab(icon: Icon(Icons.language), text: "Électronique"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildCardPaymentForm(),
          _buildMobileMoneyForm(),
          _buildElectronicPaymentForm(),
        ],
      ),
      bottomNavigationBar: isLoading
          ? null
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: MainButtons(
          text: "Payer maintenant",
          icon: const Icon(Icons.lock, color: Colors.white),
          onPressed: _validateAndPay,
        ),
      ),
    );
  }

  Widget _buildCardPaymentForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _cardFormKey,
        child: Column(
          children: [
            TextFormField(
              controller: cardNumber,
              decoration: _inputDecoration("Numéro de carte"),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _CardNumberInputFormatter(),
              ],
              validator: (value) => value!.replaceAll(' ', '').length < 12 ? "Numéro invalide" : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: cardName,
              maxLength: 12,
              decoration: _inputDecoration("Nom du titulaire"),
              validator: (value) => value!.isEmpty ? "Champ requis" : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: expiryDate,
                    decoration: _inputDecoration("MM/AA"),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                      _ExpiryDateInputFormatter(),
                    ],
                    validator: (value) => value!.length != 5 ? "Date invalide" : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: cvv,
                    decoration: _inputDecoration("CVV"),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: [LengthLimitingTextInputFormatter(4)],
                    validator: (value) => value!.length < 3 ? "CVV invalide" : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Icon(Icons.lock_outline, color: Colors.green),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Votre paiement est sécurisé et crypté. Nous ne stockons aucune information de carte.",
                      style: TextStyle(fontSize: 13, color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String selectedNetwork = '';

  Widget _buildMobileMoneyForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _mobileFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Choisissez un réseau :", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                  _networkCard("MTN", Colors.yellow.shade700, 'assets/images/mtn.png'),
                _networkCard("Moov", Colors.orange, 'assets/images/moov.png'),
                _networkCard("Celtis", 
                    Color.fromARGB(255, 4, 44, 81),
                    'assets/images/celtis.png'),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: mobileNumber,
              decoration: _inputDecoration("Numéro Mobile Money"),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (selectedNetwork.isEmpty) return "Sélectionnez un réseau";
                if (value == null || value.length < 8) return "Numéro invalide";
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }



  Widget _networkCard(String name, Color color, String imagePath) {
    final isSelected = selectedNetwork == name;

    return GestureDetector(
      onTap: () => setState(() => selectedNetwork = name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        width: 100,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Image.asset(imagePath, height: 40),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? color : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildElectronicPaymentForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _electronicFormKey,
        child: TextFormField(
          controller: email,
          decoration: _inputDecoration("Adresse email"),
          keyboardType: TextInputType.emailAddress,
          validator: (value) =>
          value!.isEmpty || !value.contains("@") ? "Email invalide" : null,
        ),
      ),
    );
  }
}

class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue now) {
    // Supprimer tout sauf les chiffres
    String digitsOnly = now.text.replaceAll(RegExp(r'\D'), '');

    // Limiter à 12 chiffres max
    if (digitsOnly.length > 16) {
      digitsOnly = digitsOnly.substring(0, 16);
    }

    // Ajouter un espace toutes les 4 chiffres
    String spaced = digitsOnly.replaceAllMapped(RegExp(r".{1,4}"), (m) => "${m.group(0)} ").trimRight();

    // Calculer une position de curseur sûre
    final offset = spaced.length.clamp(0, spaced.length);

    return TextEditingValue(
      text: spaced,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}


class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue now) {
    var text = now.text.replaceAll("/", "");
    if (text.length > 4) text = text.substring(0, 4);

    if (text.length > 2) {
      text = "${text.substring(0, 2)}/${text.substring(2)}";
    }

    final newOffset = text.length.clamp(0, text.length);

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }
}
