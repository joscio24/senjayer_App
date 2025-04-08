import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends StatelessWidget {
  final OnboardingController controller = Get.put(OnboardingController());

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/splash1.png",
      "title": "Prenez d’avantage le contrôle",
      "description":
          "Organiser désormais vos événements tout en bénéficiant des avantages de livraison de vos invitations.",
    },
    {
      "image": "assets/splash2.png",
      "title": "Organiser vos événements",
      "description":
          "Vos anniversaires, vos festivités, commémorations, désormais à votre portée en quelques clics.",
    },
    {
      "image": "assets/splash3.jpg",
      "title": "Enjaillez vous avec vos proches",
      "description":
          "Apprenez-en davantage sur les événements à venir et découvrez quels amis y participent.",
    },
  ];

   OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              onPageChanged: controller.updateIndex,
              itemCount: onboardingData.length,
              itemBuilder: (context, index) {
                return OnboardingPage(
                  image: onboardingData[index]["image"]!,
                  title: onboardingData[index]["title"]!,
                  description: onboardingData[index]["description"]!,
                );
              },
            ),
          ),
          Obx(() => buildBottomNavigation(controller)),
        ],
      ),
    );
  }

  Widget buildBottomNavigation(OnboardingController controller) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            onboardingData.length,
            (index) =>
                Obx(() => buildDot(index, controller.currentIndex.value)),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              TextButton(
                onPressed: () => controller.completeOnboarding(),
                child: Text("Passer"),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (controller.currentIndex.value ==
                        onboardingData.length - 1) {
                      controller.completeOnboarding();
                    } else {
                      controller.updateIndex(controller.currentIndex.value + 1);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 58, 0, 120),
                    //rgba(58, 0, 120, 1)
                    minimumSize: Size(300, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    controller.currentIndex.value == onboardingData.length - 1
                        ? "Se connecter"
                        : "Suivant",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildDot(int index, int currentIndex) {
    return Container(
      margin: EdgeInsets.only(right: 7),
      height: 8,
      width: currentIndex == index ? 8 : 8,
      decoration: BoxDecoration(
        color:
            currentIndex == index
                ? Color.fromARGB(255, 58, 0, 120)
                : Colors.grey,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String image, title, description;

  const OnboardingPage({super.key, 
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: Image.asset(image, fit: BoxFit.cover)),

        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              SizedBox(height: 30),
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
