import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/widgets/logic_widgets/products_widgets/view/labels/product_new_label_dialog.dart';

import '../../../../../bloc/product_blocs/product_form/labels/label_bloc.dart';
import '../../../../../bloc/product_blocs/product_form/labels/label_event.dart';
import '../../../../../bloc/product_blocs/product_form/labels/label_state.dart';
import '../../../../../models/product_models/labels/label.dart';

Future<Label?> showLabelDialog(BuildContext context) async {
  // Get the LabelBloc from the context
  final labelBloc = context.read<LabelBloc>();
  labelBloc.add(LoadLabels());

  // Get screen size to make dialog responsive
  final screenSize = MediaQuery.of(context).size;
  final isSmallScreen = screenSize.height < 600;

  return await showDialog<Label>(
    context: context,
    builder: (ctx) {
      final searchController = TextEditingController();
      String searchQuery = '';

      return BlocProvider.value(
        value: labelBloc,
        child: StatefulBuilder(
          builder: (context, setState) {
            void updateSearch(String query) {
              setState(() {
                searchQuery = query.toLowerCase();
              });
            }

            return Dialog(
              backgroundColor: Colors.white,
              insetPadding: EdgeInsets.symmetric(
                  horizontal: 20, vertical: isSmallScreen ? 10 : 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: screenSize.width * 0.9,
                // Use percentage of screen height instead of fixed height
                height: isSmallScreen
                    ? screenSize.height * 0.7
                    : screenSize.height * 0.6,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with dismiss button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Elegir etiqueta",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints.tight(const Size(24, 24)),
                        ),
                      ],
                    ),

                    // Compact search field
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Buscar etiqueta",
                        prefixIcon: const Icon(Icons.search,
                            color: Colors.grey, size: 20),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  searchController.clear();
                                  updateSearch('');
                                },
                                padding: EdgeInsets.zero,
                                constraints:
                                    BoxConstraints.tight(const Size(32, 32)),
                              )
                            : null,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      onChanged: updateSearch,
                    ),
                    const SizedBox(height: 8),

                    // Main content - Label list (takes all remaining space)
                    Expanded(
                      child: BlocBuilder<LabelBloc, LabelState>(
                        builder: (context, state) {
                          if (state is LabelLoading) {
                            return const Center(
                                child: CircularProgressIndicator(
                                    backgroundColor: Colors.blue));
                          } else if (state is LabelError) {
                            return Center(
                                child: Text("Error: ${state.message}"));
                          } else if (state is LabelsLoaded) {
                            final allLabels = state.labels;
                            final filteredLabels = searchQuery.isEmpty
                                ? allLabels
                                : allLabels
                                    .where((label) =>
                                        label.name
                                            .toLowerCase()
                                            .contains(searchQuery) ||
                                        label.description
                                            .toLowerCase()
                                            .contains(searchQuery))
                                    .toList();

                            return filteredLabels.isEmpty
                                ? Center(
                                    child: Text(
                                      searchQuery.isEmpty
                                          ? "No hay etiquetas disponibles"
                                          : "No se encontraron etiquetas",
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                  )
                                : GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: isSmallScreen ? 2 : 3,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                      childAspectRatio: 3,
                                    ),
                                    itemCount: filteredLabels.length,
                                    itemBuilder: (context, index) {
                                      final label = filteredLabels[index];
                                      return GestureDetector(
                                        onTap: () => Navigator.pop(ctx, label),
                                        child: Container(
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.blue.shade300),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            label.name,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.blue.shade700),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                          }
                          return const Center(
                              child: Text("Error cargando etiquetas"));
                        },
                      ),
                    ),

                    // Action row at bottom
                    Row(
                      children: [
                        // New label button
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              final newLabel =
                                  await showNewLabelDialog(context);
                              if (newLabel != null) {
                                labelBloc.add(LoadLabels());
                              }
                            },
                            icon: const Icon(Icons.add,
                                color: Colors.blue, size: 18),
                            label: const Text(
                              "Nueva etiqueta",
                              style: TextStyle(color: Colors.blue),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                            ),
                          ),
                        ),

                        // Cancel button
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                          ),
                          child: const Text(
                            "Cancelar",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
