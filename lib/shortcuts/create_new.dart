import 'package:flutter/material.dart';

class CreateNewIntent extends Intent {
  const CreateNewIntent();
}

class CreateNewAction extends Action<CreateNewIntent> {
  final VoidCallback openCreateNewDialog;

  CreateNewAction({required this.openCreateNewDialog});

  @override
  Object? invoke(CreateNewIntent intent) {
    openCreateNewDialog();
    return true;
  }
}
