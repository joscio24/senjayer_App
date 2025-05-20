import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  final List<Map<String, String>> faqs = [
    {
      'question': 'À quoi sert cette application ?',
      'answer': 'Cette application vous permet d’inviter vos contacts personnels à des événements. Vous pouvez créer des événements, envoyer des invitations et partager la localisation de manière privée.'
    },
    {
      'question': 'Qui peut voir mes événements ?',
      'answer': 'Seuls les contacts que vous avez invités peuvent voir les détails de vos événements. Les événements ne sont pas publics.'
    },
    {
      'question': 'Comment inviter quelqu’un à mon événement ?',
      'answer': 'Lors de la création ou de la modification d’un événement, vous pouvez sélectionner des contacts depuis votre liste et leur envoyer une invitation.'
    },
    {
      'question': 'Puis-je envoyer la localisation avec l’invitation ?',
      'answer': 'Oui. Vous pouvez ajouter une adresse ou une position sur la carte lors de la configuration de l’événement.'
    },
    {
      'question': 'Qui puis-je inviter ?',
      'answer': 'Vous pouvez inviter n’importe quel contact enregistré sur votre téléphone. L’application n’accède à vos contacts que si vous les sélectionnez manuellement.'
    },
    {
      'question': 'Les invités reçoivent-ils des notifications ?',
      'answer': 'Oui, les invités reçoivent les détails de l’événement par SMS, email ou notification dans l’application, selon votre configuration.'
    },
    {
      'question': 'Puis-je modifier un événement après avoir invité des contacts ?',
      'answer': 'Oui, vous pouvez modifier le nom, la date, l’heure et la localisation. Les invités recevront automatiquement les mises à jour.'
    },
    {
      'question': 'Mes données sont-elles sécurisées ?',
      'answer': 'Oui. Nous ne partageons jamais vos données. Les informations sont chiffrées et accessibles uniquement par vous et vos invités.'
    },
    {
      'question': 'Les invités doivent-ils installer l’application ?',
      'answer': 'Pas obligatoirement. Ils peuvent recevoir un lien sécurisé. Toutefois, l’installation de l’application permet de répondre à l’invitation et recevoir les mises à jour.'
    },
    {
      'question': 'Comment annuler un événement ?',
      'answer': 'Allez dans la liste de vos événements, sélectionnez-en un, puis cliquez sur “Annuler l’événement”. Tous les invités seront notifiés.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FAQ',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                title: Text(
                  faq['question'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                iconColor: Colors.blueAccent,
                collapsedIconColor: Colors.grey,
                children: [
                  Text(
                    faq['answer'] ?? '',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
