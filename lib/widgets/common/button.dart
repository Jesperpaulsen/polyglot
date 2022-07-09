import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String label;
  final Color color;
  final bool large;
  final bool loading;
  final void Function()? onPressed;

  const Button({
    required this.label,
    this.large = false,
    this.color = Colors.orange,
    this.onPressed,
    bool? loading,
    Key? key,
  })  : loading = loading ?? false,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        fixedSize: Size.fromHeight(large ? 40 : 30),
        backgroundColor: onPressed != null ? color : Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            large ? 35.0 : 20.0,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: large ? 12.0 : 10.0),
        child: loading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 1,
                  color: Theme.of(context).primaryColor,
                ),
              )
            : Text(
                label,
                style:
                    TextStyle(color: Colors.black, fontSize: large ? 18 : 14),
              ),
      ),
    );
  }
}
