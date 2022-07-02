import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Input extends StatefulWidget {
  final String? value;
  final String? label;
  final String? error;
  final String? hint;
  final TextInputType? type;
  final bool? password;
  final void Function(String? value)? onChange;
  final String? Function(String? value, TextEditingController? controller)?
      validator;
  final VoidCallback? onSubmitted;
  final bool autofocus;

  const Input({
    this.label,
    this.error,
    this.hint,
    this.type,
    this.password,
    this.onChange,
    this.validator,
    this.value,
    this.onSubmitted,
    this.autofocus = false,
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

  void onSaved(String? value) {
    if (widget.onChange == null) {
      return;
    }
    if (value == null) {
      return widget.onChange!.call(null);
    }
    if (value.isEmpty) {
      return widget.onChange!.call(null);
    }
    return widget.onChange!.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: widget.autofocus,
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
      onFieldSubmitted: (value) => widget.onSubmitted?.call(),
      onSaved: (v) => onSaved,
      validator: (v) => widget.validator?.call(v, _textInputController),
      controller: _textInputController,
      keyboardType: widget.type,
      obscureText: widget.password ?? false,
      onChanged: widget.onChange,
    );
  }
}
