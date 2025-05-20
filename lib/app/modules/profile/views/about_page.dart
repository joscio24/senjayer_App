import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'À propos',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Senjayer Priv8',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Senjayer Priv8 est une application privée qui vous permet de créer des événements personnels et d’inviter vos contacts de manière sécurisée et confidentielle.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Fonctionnalités principales :',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              BulletPoint(text: 'Création d’événements personnalisés'),
              BulletPoint(text: 'Sélection manuelle de vos contacts'),
              BulletPoint(text: 'Envoi d’invitations avec la localisation'),
              BulletPoint(text: 'Mises à jour et annulations en temps réel'),
              BulletPoint(text: 'Confidentialité et sécurité des données'),
              SizedBox(height: 16),
              Text(
                'Senjayer Priv8 respecte votre vie privée. Toutes les données sont stockées en toute sécurité et ne sont accessibles qu’à vous et aux invités concernés.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Version : 1.0.0',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 8),
              Text(
                'Développé par l’équipe Senjayer.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;
  const BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("• ", style: TextStyle(fontSize: 16)),
        Expanded(child: Text(text, style: TextStyle(fontSize: 16))),
      ],
    );
  }
}
