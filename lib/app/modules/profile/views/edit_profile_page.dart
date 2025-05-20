import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:senjayer/widgets/custom_button.dart';
import '../../../../widgets/custom_textfield.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfilePage extends GetView<EditProfileController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Éditer le profil")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: controller.pickImage,
                    child: Obx(() {
                      final image = controller.profileImage.value;

                      return Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[300],
                            backgroundImage:
                            image != null ? FileImage(image) : AssetImage("assets/avatar_placeholder.png") as ImageProvider,
                          ),
                          TextButton.icon(
                            onPressed: controller.pickImage,
                            icon: Icon(Icons.edit),
                            label: Text("Changer la photo"),
                          ),
                          SizedBox(height: 20),
                        ],
                      );
                    }),

                  ),
                  SizedBox(height: 20),
                  CustomTextField(
                    labelText: "Nom",
                    controller: controller.lastName,
                  ),
                  SizedBox(height: 10),
                  CustomTextField(
                    labelText: "Prénom",
                    controller: controller.firstName,
                  ),
                  SizedBox(height: 10),
                  CustomTextField(
                    labelText: "Email",
                    controller: controller.email,
                    inputType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 10),
                  CustomTextField(
                    labelText: "Téléphone",
                    controller: controller.phone,
                    inputType: TextInputType.phone,
                  ),
                  SizedBox(height: 10),
                  _buildGenderSelector(),
                  SizedBox(height: 20),
                  MainButtons(
                    onPressed: controller.updateProfile,
                    text: 'Mettre à jour',
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      children: [
        Text("Genre: "),
        Obx(() => Row(
          children: [
            Radio<String>(
              value: 'M',
              groupValue: controller.gender.value,
              onChanged: (val) => controller.gender.value = val!,
            ),
            Text('Homme'),
            Radio<String>(
              value: 'F',
              groupValue: controller.gender.value,
              onChanged: (val) => controller.gender.value = val!,
            ),
            Text('Femme'),
          ],
        )),
      ],
    );
  }
}
