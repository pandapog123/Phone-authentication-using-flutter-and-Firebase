import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OTPInput extends StatefulWidget {
  const OTPInput({super.key, required this.onInput});

  final Function(String input) onInput;

  @override
  State<OTPInput> createState() => _OTPInputState();
}

class _OTPInputState extends State<OTPInput> {
  String currentInput = "";
  late List<TextEditingController> textEditingControllers;
  late List<FocusNode> focusNodes;
  late List<String> inputs;

  FocusNode keyFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    textEditingControllers =
        List.filled(6, null).map((_) => TextEditingController()).toList();

    focusNodes = textEditingControllers.map((_) {
      return FocusNode();
    }).toList();

    inputs = textEditingControllers.map((_) => "").toList();

    for (int i = 0; i < textEditingControllers.length; i++) {
      final controller = textEditingControllers[i];

      controller.addListener(() {
        if (controller.value.text.isNotEmpty &&
            i != textEditingControllers.length - 1) {
          setState(() {
            inputs[i] = controller.value.text;

            focusNodes[i + 1].requestFocus();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();

    for (var controller in textEditingControllers) {
      controller.dispose();
    }

    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: textEditingControllers.asMap().entries.map((entry) {
        final controller = entry.value;
        final i = entry.key;

        return Expanded(
          child: TextField(
            // readOnly: i > 0 ? inputs[i - 1].isEmpty : false,
            autofocus: i == 0,

            controller: controller,
            focusNode: focusNodes[i],
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp("\\d{1}")),
            ],
          ),
        );
      }).toList(),
    );
  }
}
