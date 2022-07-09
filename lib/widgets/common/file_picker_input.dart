import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:polyglot/widgets/common/custom_icon_button.dart';

enum PICKER_TYPE { FILE, DIRECTORY }

class FilePickerInput extends StatefulWidget {
  final String label;
  final String? path;
  final List<String> allowedExtensions;
  final PICKER_TYPE type;
  final void Function(dynamic pickResult) onFilePicked;

  const FilePickerInput({
    required this.label,
    required this.onFilePicked,
    this.path,
    this.allowedExtensions = const <String>[],
    this.type = PICKER_TYPE.FILE,
    Key? key,
  }) : super(key: key);

  @override
  State<FilePickerInput> createState() => _FilePickerInputState();
}

class _FilePickerInputState extends State<FilePickerInput> {
  final _controller = TextEditingController();

  Future<void> _pickFile() async {
    dynamic result;
    if (widget.type == PICKER_TYPE.FILE) {
      final files = await FilePicker.platform.pickFiles(
          allowedExtensions: widget.allowedExtensions, type: FileType.custom);
      result = files?.paths.first;
    } else {
      result = await FilePicker.platform.getDirectoryPath();
    }

    if (result != null) {
      _controller.text = result ?? '';
      widget.onFilePicked(result);
    }
  }

  @override
  initState() {
    super.initState();
    _controller.text = widget.path ?? '';
    _controller.addListener(() {
      widget.onFilePicked(_controller.text);
    });
  }

  @override
  dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              labelText: widget.label,
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 0.0),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            controller: _controller,
          ),
        ),
        CustomIconButton(
          iconData: Icons.folder,
          onPressed: _pickFile,
        ),
      ],
    );
  }
}
