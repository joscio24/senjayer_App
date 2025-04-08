import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TitleText_1 extends StatelessWidget {
  final String text;

  const TitleText_1({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Text(
      text,
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    );
  }
}

class TitleText_2 extends StatelessWidget {
  final String text;

  const TitleText_2({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
    );
  }
}

class MenuTexts extends StatelessWidget {
  final String text;

  const MenuTexts({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
    );
  }
}

class CustomTextField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final Function(String)? onChange;
  final TextInputType inputType;

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.controller,
    this.hintText = "",
    this.isPassword = false,
    this.inputType = TextInputType.text,
    this.onChange,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  String? errorText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  _validateInput(String value) {
    String? validationMessage;
    if (widget.inputType == TextInputType.emailAddress) {
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
      if (!emailRegex.hasMatch(value)) {
        validationMessage = "Entrez une adresse e-mail valide";
      }
    } else if (widget.isPassword) {
      if (value.length < 8) {
        validationMessage = "Au moins 8 caractères requis";
      } else if (!RegExp(r'[0-9]').hasMatch(value)) {
        validationMessage = "Inclure au moins un chiffre";
      } else if (!RegExp(r'[A-Za-z]').hasMatch(value)) {
        validationMessage = "Inclure au moins une lettre";
      }
    }
    setState(() {
      errorText = validationMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
      keyboardType: widget.inputType,
      validator: (value) => value != null ? _validateInput(value) : null,
      onChanged:
          (value) => {
            _validateInput(value), // Validate on each input
            if (widget.onChange != null)
              {
                widget.onChange!(value), // Call external callback if provided
              },
          },
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        errorText: errorText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        suffixIcon:
            widget.isPassword
                ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
                : null,
      ),
    );
  }
}
