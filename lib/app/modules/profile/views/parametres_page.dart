import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ParametresPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.purple),
        title: Text('Paramètres', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          GestureDetector(
            onTap: ()=> Get.toNamed("/notifications"),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Stack(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.purple.shade100,
                    child: Icon(Icons.notifications, color: Colors.purple),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 5,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [
          SizedBox(height: 20,),
          _buildTile(Icons.person, 'Editer le profil', '/edit-profile'),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Divider(thickness: 0.4,),
          ),
          _buildTile(Icons.notifications, 'Notifications', '/notifications'),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Divider(thickness: 0.4,),
          ),
          _buildTile(Icons.info, 'FAQ', '/faq'),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Divider(thickness: 0.4,),
          ),
          _buildTile(Icons.remove_red_eye, 'A propos de Priv8', '/about'),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Divider(thickness: 0.4,),
          ),
          _buildTile(Icons.logout, 'Supprimer son compte', '/delete-account', iconColor: Colors.red),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Row(
          children: [
            Icon(Icons.home, color: Colors.purple.shade200, size: 40),
            Spacer(),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed("/user_events_packs"),
              icon: Icon(Icons.add, size: 32),
              label: Text('Créer un event', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.black,
                shape: StadiumBorder(side: BorderSide(color: Colors.black)),
                elevation: 5,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTile(IconData icon, String label, String route, {Color? iconColor}) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.purple.shade50,
        child: Icon(icon, color: iconColor ?? Colors.purple),
      ),
      title: Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
      onTap: () => Get.toNamed(route),
    );
  }
}
