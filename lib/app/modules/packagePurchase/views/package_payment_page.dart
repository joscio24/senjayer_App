import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senjayer/api/api_routes.dart';
import 'package:senjayer/api/api_services.dart';
import 'package:senjayer/widgets/custom_loader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:senjayer/widgets/custom_button.dart';
import 'package:flutter/services.dart';

import 'package:dio/dio.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage>
    with SingleTickerProviderStateMixin {
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
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  int userIdfetch = 0;
  final Map<String, dynamic> selectedPackage = Get.arguments;

  final Dio _dio = Dio();
  bool isLoading = false;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    // selectedPackage = Get.arguments;
    _getUserId();
    super.initState();
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

  Future<Map<String, dynamic>?> checkTransactionStatus({
    required String referenceId,
    required String client,
    required String packageId,
  }) async {
    final url = "${ApiRoutes.baseUrl}/v1/transactions/$referenceId/$client";

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    print("🔁 Checking status at: $url");
    print("📦 Query parameters: package_id=$packageId");
    print("🔐 Using token: $token");

    try {
      final response = await _dio.get(
        url,
        queryParameters: {'package_id': packageId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print("✅ Response status code: ${response.statusCode}");
      print("📝 Response data: ${response.data}");

      final data = response.data;

      if (response.statusCode == 200) {
        if (data['responsecode'] == "00") {
          print("🎉 Payment confirmed.");
          return data;
        } else {
          print("⚠️ Response code not 00: ${data['responsecode']}");
        }
      } else {
        print("❌ Unexpected status code: ${response.statusCode}");
      }
    } catch (e, stack) {
      print("💥 Exception during transaction check: $e");
      print("📚 Stack trace: $stack");
    }

    return null;
  }

  Future<void> _confirmPayment(String type) async {
    setState(() => isLoading = true);

    final name = firstName.text.trim();
    final surname = lastName.text.trim();
    final phone = mobileNumber.text.trim();
    final double amount =
        double.tryParse(selectedPackage['price'].toString()) ?? 0.0;
    final int userId = userIdfetch;

    try {
      final api = ApiService();

      // Step 1: Create the transaction
      final result = await api.createTransaction(
        userId: userId,
        firstName: name,
        lastName: surname,
        phone: phone,
        amount: amount,
        operator: selectedNetwork,
        items: [
          {
            'package_id': selectedPackage['id'],
            'name': selectedPackage['name'],
            'price': selectedPackage['price'],
          },
        ],
      );

      print("Transaction creation response: $result");

      if (result == null ||
          result['success'] != true ||
          result['data'] == null) {
        setState(() => isLoading = false);
        Get.snackbar(
          "Erreur",
          result?['message'] ?? "Échec de la transaction.",
        );
        return;
      }

      final data = result['data']['data'];
      final referenceId = data['reference'];
      final client = selectedNetwork;
      final packageId = selectedPackage['id'].toString();

      // Step 2: Poll for status
      const int maxRetries = 15;
      int attempt = 0;
      bool isPaid = false;

      while (attempt < maxRetries && !isPaid) {
        await Future.delayed(Duration(seconds: 4));
        final statusResult = await checkTransactionStatus(
          referenceId: referenceId,
          client: client,
          packageId: packageId,
        );

        print("Polling attempt $attempt: statusResult = $statusResult");

        if (statusResult != null) {
          isPaid = true;
          print("Payment confirmed!");
          break;
        }

        attempt++;
      }

      setState(() => isLoading = false);

      if (isPaid) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('premium_paid', true);

        Get.snackbar(
          "Paiement validé",
          "Merci pour votre souscription Premium via $type !",
        );
        Get.offNamed("/user_events_create");
      } else {
        Get.snackbar("Temps écoulé", "Aucune confirmation de paiement reçue.");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error in _confirmPayment: $e");
      Get.snackbar("Erreur", "Une erreur est survenue : $e");
    }
  }

  // void _validateAndPay() {
  //   final currentTab = _tabController.index;
  //   final isValid =
  //       [
  //         _cardFormKey.currentState?.validate(),
  //         _mobileFormKey.currentState?.validate(),
  //         _electronicFormKey.currentState?.validate(),
  //       ][currentTab] ??
  //       false;

  //   if (isValid) {
  //     _confirmPayment();
  //   } else {
  //     Get.snackbar("Erreur", "Veuillez compléter les champs requis.");
  //   }
  // }

  void _validateAndPay() {
    final currentTab = _tabController.index;
    final formKeys = [_cardFormKey, _mobileFormKey, _electronicFormKey];
    final paymentTypes = ["card", "mobile", "electronic"];

    final currentKey = formKeys[currentTab];
    final paymentType = paymentTypes[currentTab];

    if (currentKey.currentState?.validate() ?? false) {
      _confirmPayment(paymentType);
    } else {
      Get.snackbar(
        "Erreur",
        "Veuillez compléter les champs requis pour $paymentType.",
      );
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
        title: const Text(
          "Paiement Premium",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
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
      body:
          isLoading
              ? const CustomLoader()
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildCardPaymentForm(),
                  _buildMobileMoneyForm(),
                  _buildElectronicPaymentForm(),
                ],
              ),
      bottomNavigationBar:
          isLoading
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_border, color: Colors.blue),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "${selectedPackage['name']} - Prix: ${selectedPackage['price']}",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            TextFormField(
              controller: firstName,
              decoration: _inputDecoration("Prénom"),
              validator: (value) => value!.isEmpty ? "Champ requis" : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: lastName,
              decoration: _inputDecoration("Nom"),
              validator: (value) => value!.isEmpty ? "Champ requis" : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: cardNumber,
              decoration: _inputDecoration("Numéro de carte"),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _CardNumberInputFormatter(),
              ],
              validator:
                  (value) =>
                      value!.replaceAll(' ', '').length < 12
                          ? "Numéro invalide"
                          : null,
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
                    validator:
                        (value) => value!.length != 5 ? "Date invalide" : null,
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
                    validator:
                        (value) => value!.length < 3 ? "CVV invalide" : null,
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_border, color: Colors.blue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "${selectedPackage['name']} - Prix: ${selectedPackage['price']}",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              const Text(
                "Choisissez un réseau :",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _networkCard(
                    "MTN",
                    Colors.yellow.shade700,
                    'assets/images/mtn.png',
                  ),
                  _networkCard("MOOV", Colors.orange, 'assets/images/moov.png'),
                  _networkCard(
                    "CELTIS",
                    Color.fromARGB(255, 4, 44, 81),
                    'assets/images/celtis.png',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: firstName,
                decoration: _inputDecoration("Prénom"),
                validator: (value) => value!.isEmpty ? "Champ requis" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: lastName,
                decoration: _inputDecoration("Nom"),
                validator: (value) => value!.isEmpty ? "Champ requis" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: mobileNumber,
                decoration: InputDecoration(
                  labelText: "Numéro Mobile Money",
                  hintText: "22901XXXXXXXX",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (selectedNetwork.isEmpty) return "Sélectionnez un réseau";
                  if (value == null || value.length < 11)
                    return "Numéro invalide";
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _networkCard(String name, Color color, String imagePath) {
    final isSelected = selectedNetwork == name;

    return GestureDetector(
      onTap: () => setState(() => selectedNetwork = name.toUpperCase()),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        width: 100,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
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
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_border, color: Colors.blue),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "${selectedPackage['name']} - Prix: ${selectedPackage['price']}",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Form(
              key: _electronicFormKey,
              child: TextFormField(
                controller: email,
                decoration: _inputDecoration("Adresse email"),
                keyboardType: TextInputType.emailAddress,
                validator:
                    (value) =>
                        value!.isEmpty || !value.contains("@")
                            ? "Email invalide"
                            : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue old,
    TextEditingValue now,
  ) {
    // Supprimer tout sauf les chiffres
    String digitsOnly = now.text.replaceAll(RegExp(r'\D'), '');

    // Limiter à 12 chiffres max
    if (digitsOnly.length > 16) {
      digitsOnly = digitsOnly.substring(0, 16);
    }

    // Ajouter un espace toutes les 4 chiffres
    String spaced =
        digitsOnly
            .replaceAllMapped(RegExp(r".{1,4}"), (m) => "${m.group(0)} ")
            .trimRight();

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
  TextEditingValue formatEditUpdate(
    TextEditingValue old,
    TextEditingValue now,
  ) {
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
