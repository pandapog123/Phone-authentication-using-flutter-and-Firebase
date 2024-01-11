import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OTPInput extends StatefulWidget {
  const OTPInput({
    super.key,
    required this.onInput,
    required this.disabled,
  });

  final Function(String input) onInput;
  final bool disabled;

  @override
  State<OTPInput> createState() => _OTPInputState();
}

class _OTPInputState extends State<OTPInput> {
  String currentInput = "";
  TextEditingController inputController = TextEditingController();
  FocusNode inputFocus = FocusNode();
  bool inputFocused = false;

  @override
  void initState() {
    super.initState();

    inputController.addListener(() {
      if (inputController.value.text != currentInput) {
        if (inputController.value.text.length == 6) {
          inputFocus.unfocus();
        }

        setState(() {
          currentInput = inputController.value.text;

          widget.onInput(inputController.value.text);
        });
      }
    });

    inputFocus.addListener(() {
      setState(() {
        inputFocused = inputFocus.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();

    inputController.dispose();
    inputFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Visibility(
          maintainInteractivity: true,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          visible: false,
          child: TextField(
            enabled: !widget.disabled,
            controller: inputController,
            focusNode: inputFocus,
            autofillHints: const [
              AutofillHints.oneTimeCode,
            ],
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              LengthLimitingTextInputFormatter(6),
              FilteringTextInputFormatter.digitsOnly,
            ],
            style: const TextStyle(
              fontSize: 0,
            ),
            decoration: const InputDecoration.collapsed(
              hintText: "",
            ),
          ),
        ),
        LayoutBuilder(builder: (context, constraints) {
          final boxWidth = (constraints.maxWidth / 6) - 8;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.filled(6, "").indexed.map((entry) {
              final index = entry.$1;
              final selected = inputFocused &&
                  ((index == currentInput.length) ||
                      (currentInput.length == 6 && index == 5));

              return AnimatedContainer(
                duration: Durations.short4,
                height: boxWidth,
                width: boxWidth,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                decoration: BoxDecoration(
                  color: selected || widget.disabled
                      ? theme.colorScheme.outlineVariant
                      : theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (!inputFocus.hasFocus) {
                        inputFocus.requestFocus();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: AnimatedContainer(
                        duration: Durations.short4,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              width: selected ? 2 : 0,
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ),
                        child: Text(
                            index < currentInput.length
                                ? currentInput[index]
                                : "",
                            style: theme.textTheme.titleLarge),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}
