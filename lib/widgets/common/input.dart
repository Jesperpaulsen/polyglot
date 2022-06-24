import 'package:flutter/material.dart';

class Input extends StatefulWidget {
  final String? value;
  final String? label;
  final String? error;
  final String? hint;
  final TextInputType? type;
  final bool? password;
  final void Function(String value)? onChange;
  final String? Function(String? value, TextEditingController? controller)?
      validator;

  const Input({
    this.label,
    this.error,
    this.hint,
    this.type,
    this.password,
    this.onChange,
    this.validator,
    this.value,
    Key? key,
  }) : super(key: key);

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  final _textInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.value != null) {
      _textInputController.text = widget.value!;
    }
  }

  @override
  void dispose() {
    _textInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: widget.error,
        hintText: widget.hint,
        filled: true,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 0.0),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onSaved: (v) => widget.onChange?.call(v ?? ""),
      validator: (v) => widget.validator?.call(v, _textInputController),
      controller: _textInputController,
      keyboardType: widget.type,
      obscureText: widget.password ?? false,
      onChanged: widget.onChange,
    );
  }
}
