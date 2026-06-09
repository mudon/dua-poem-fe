import 'package:flutter/material.dart';
import 'create_picker_sheet.dart';
import 'create_dua_sheet.dart';
import 'create_poem_sheet.dart';

enum _FlowStep { picker, duaForm, poemForm }

class CreateFlowSheet extends StatefulWidget {
  final VoidCallback? onDuaCreated;
  final VoidCallback? onPoemCreated;

  const CreateFlowSheet({super.key, this.onDuaCreated, this.onPoemCreated});

  @override
  State<CreateFlowSheet> createState() => _CreateFlowSheetState();
}

class _CreateFlowSheetState extends State<CreateFlowSheet> {
  _FlowStep _step = _FlowStep.picker;

  void _goBack() => setState(() => _step = _FlowStep.picker);

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case _FlowStep.picker:
        return CreatePickerSheet(
          onSelected: (type) {
            setState(() {
              _step = type == 'dua' ? _FlowStep.duaForm : _FlowStep.poemForm;
            });
          },
        );
      case _FlowStep.duaForm:
        return CreateDuaSheet(
          onBack: _goBack,
          onCreated: () {
            widget.onDuaCreated?.call();
          },
        );
      case _FlowStep.poemForm:
        return CreatePoemSheet(
          onBack: _goBack,
          onCreated: () {
            widget.onPoemCreated?.call();
          },
        );
    }
  }
}
