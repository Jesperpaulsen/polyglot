import 'package:flutter/material.dart';

class Input extends StatefulWidget {
  final String? value;
  final String? label;
  final String? error;
  final String? hint;
  final TextInputType? type;
  final bool? password;
  final TextEditingController? controller;
  final void Function(String? value)? onChange;
  final String? Function(String? value, TextEditingController? controller)?
      validator;
  final Function(String? value)? onSubmitted;
  final bool autofocus;
  final FocusNode? focusNode;

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
    this.controller,
    this.autofocus = false,
    this.focusNode,
    Key? key,
  }) : super(key: key);

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  var _textInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _textInputController = widget.controller!;
    }
    if (widget.value != null) {
      _textInputController.text = widget.value!;
    }
  }

  @override
  void didUpdateWidget(Input oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != null) {
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
      focusNode: widget.focusNode,
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
      onFieldSubmitted: (value) => widget.onSubmitted?.call(value),
      onSaved: (v) => onSaved,
      validator: (v) => widget.validator?.call(v, _textInputController),
      controller: _textInputController,
      keyboardType: widget.type,
      obscureText: widget.password ?? false,
      onChanged: widget.onChange,
    );
  }
}
