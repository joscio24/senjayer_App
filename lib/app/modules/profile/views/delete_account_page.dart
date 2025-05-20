import 'package:flutter/material.dart';

class DeleteAccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Supprimer le compte', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
      body: Center(child: Text('Page de suppression du profil')),
    );
  }
}
