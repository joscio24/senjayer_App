import 'package:get/get.dart';

class NotificationController extends GetxController {
  var notifications = <Map<String, dynamic>>[].obs;

  void ajouterNotification(String message) {
    notifications.add({
      'title': 'Nouvelle notification',
      'body': message,
      'isRead': false,
    });
  }

  void fetchNotifications() {
    notifications.addAll([
      {
        'title': 'Événement créé',
        'body': 'Votre événement "Tech Conference" a été créé avec succès !',
        'isRead': false,
      },
      {
        'title': 'Invitation acceptée',
        'body': 'John Doe a accepté votre invitation à l\'événement.',
        'isRead': false,
      },
      {
        'title': 'Pack d\'événement acheté',
        'body': 'Vous avez acheté avec succès le pack Event Pro.',
        'isRead': true,
      },
      {
        'title': 'Expiration de l\'événement',
        'body': 'Votre événement "Tech Conference" expirera dans 3 jours !',
        'isRead': true,
      },
    ]);
  }
}
