import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/form/labels/label_bloc.dart';
import 'package:spl_front/bloc/ui_management/product/form/labels/label_event.dart';
import 'package:spl_front/bloc/ui_management/product/form/labels/label_state.dart';
import 'package:spl_front/models/data/label.dart';

Future<Label?> showNewLabelDialog(BuildContext context) async {
  final maxLabelNameLength = 45;
  TextEditingController labelNameController = TextEditingController();
  
  // Get or create the LabelBloc
  final labelBloc = context.read<LabelBloc>();

  return await showDialog<Label>(
    context: context,
    builder: (ctx) {
      return BlocProvider.value(
        value: labelBloc,
        child: BlocListener<LabelBloc, LabelState>(
          listener: (context, state) {
            if (state is LabelCreated) {
              Navigator.pop(ctx, state.label);
            }
          },
          child: StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text("Añadir etiqueta"),
                backgroundColor: Colors.white,
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: labelNameController,
                        maxLength: maxLabelNameLength,
                        decoration: const InputDecoration(
                          hintText: "Nombre etiqueta",
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        cursorColor: Colors.blue,
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      "Cancelar",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  BlocBuilder<LabelBloc, LabelState>(
                    builder: (context, state) {
                      return TextButton(
                        onPressed: state is LabelLoading 
                          ? null 
                          : () {
                            if (labelNameController.text.trim().isNotEmpty) {
                              context.read<LabelBloc>().add(
                                CreateLabel(name: labelNameController.text.trim())
                              );
                            }
                          },
                        child: state is LabelLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              "Crear",
                              style: TextStyle(color: Colors.blue),
                            ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}